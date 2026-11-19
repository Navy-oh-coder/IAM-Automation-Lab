<#
.SYNOPSIS Applies a standard leaver auto-reply to approved disabled-user mailboxes.
.DESCRIPTION Existing Enabled or Scheduled auto-replies are skipped. The audit CSV
captures the previous state, messages and external audience for the restore script.
.NOTES Input CSV must contain UserPrincipalName. Run with -WhatIf first.
#>
[CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='High')]
param(
 [Parameter(Mandatory)][ValidateScript({Test-Path -LiteralPath $_ -PathType Leaf})][string]$CsvPath,
 [string]$SupportAddress='support@yourdomain.com',
 [string]$AuditDirectory=(Join-Path $PSScriptRoot 'AuditReports')
)
$ErrorActionPreference='Stop'
Import-Module Microsoft.Graph.Users -ErrorAction Stop
Import-Module ExchangeOnlineManagement -ErrorAction Stop
if (-not (Get-MgContext)) { Connect-MgGraph -Scopes 'User.Read.All' }
if (-not (Get-ConnectionInformation)) { Connect-ExchangeOnline }
if (-not (Test-Path -LiteralPath $AuditDirectory)) { New-Item -ItemType Directory -Path $AuditDirectory -Force | Out-Null }
$stamp=Get-Date -Format 'yyyyMMdd-HHmmss'
$auditPath=Join-Path $AuditDirectory "LeaverAutoReply-$stamp.csv"
$targets=Import-Csv -LiteralPath $CsvPath
if (-not $targets -or -not ($targets[0].PSObject.Properties.Name -contains 'UserPrincipalName')) { throw 'Input CSV must contain a UserPrincipalName column and at least one row.' }
$message="<p>Thank you for your email. This person no longer works at the company. Please contact $SupportAddress for further assistance.</p>"
foreach ($target in $targets) {
 $upn=([string]$target.UserPrincipalName).Trim()
 $row=[ordered]@{Timestamp=(Get-Date -Format 'o');UserPrincipalName=$upn;DisplayName='';PreviousAutoReplyState='';PreviousInternalMessage='';PreviousExternalMessage='';PreviousExternalAudience='';NewAutoReplyState='';Status='';Error=''}
 try {
  if ([string]::IsNullOrWhiteSpace($upn)) { throw 'UserPrincipalName is blank.' }
  $user=Get-MgUser -UserId $upn -Property 'displayName,userPrincipalName,accountEnabled' -ErrorAction Stop
  $row.DisplayName=$user.DisplayName
  if ($user.AccountEnabled -ne $false) { $row.Status='Skipped (Entra account is not disabled)' }
  else {
   $config=Get-MailboxAutoReplyConfiguration -Identity $upn -ErrorAction Stop
   $row.PreviousAutoReplyState=[string]$config.AutoReplyState
   $row.PreviousInternalMessage=[string]$config.InternalMessage
   $row.PreviousExternalMessage=[string]$config.ExternalMessage
   $row.PreviousExternalAudience=[string]$config.ExternalAudience
   if ($config.AutoReplyState -ne 'Disabled') { $row.NewAutoReplyState=[string]$config.AutoReplyState; $row.Status="Skipped (Existing auto-reply state: $($config.AutoReplyState))" }
   elseif ($PSCmdlet.ShouldProcess($upn,'Enable standard leaver auto-reply')) {
    Set-MailboxAutoReplyConfiguration -Identity $upn -AutoReplyState Enabled -InternalMessage $message -ExternalMessage $message -ExternalAudience All -ErrorAction Stop
    $verified=Get-MailboxAutoReplyConfiguration -Identity $upn -ErrorAction Stop
    $row.NewAutoReplyState=[string]$verified.AutoReplyState
    if ($verified.AutoReplyState -eq 'Enabled') { $row.Status='Updated (OOH applied)' } else { $row.Status='Failed (Post-change verification did not confirm Enabled state)' }
   } else { $row.NewAutoReplyState=[string]$config.AutoReplyState; $row.Status='WhatIf (No change made)' }
  }
 } catch { $row.Status='Failed'; $row.Error=$_.Exception.Message }
 [pscustomobject]$row | Export-Csv -LiteralPath $auditPath -NoTypeInformation -Append -Encoding UTF8
 Write-Host ("{0}: {1}" -f $upn,$row.Status)
}
Write-Host "Audit report: $auditPath"
