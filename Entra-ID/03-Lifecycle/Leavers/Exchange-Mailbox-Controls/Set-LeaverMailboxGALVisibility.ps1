<#
.SYNOPSIS
Hides approved disabled-user cloud mailboxes from Exchange Online address lists.
.NOTES
Input CSV must contain UserPrincipalName. Hybrid-synchronised recipients are skipped;
manage msExchHideFromAddressLists at the authoritative on-premises AD source.
Run with -WhatIf first. Lab code; test in a non-production tenant.
#>
[CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='High')]
param(
 [Parameter(Mandatory)][ValidateScript({Test-Path -LiteralPath $_ -PathType Leaf})][string]$CsvPath,
 [string]$AuditDirectory=(Join-Path $PSScriptRoot 'AuditReports')
)
$ErrorActionPreference='Stop'
Import-Module Microsoft.Graph.Users -ErrorAction Stop
Import-Module ExchangeOnlineManagement -ErrorAction Stop
if (-not (Get-MgContext)) { Connect-MgGraph -Scopes 'User.Read.All' }
if (-not (Get-ConnectionInformation)) { Connect-ExchangeOnline }
if (-not (Test-Path -LiteralPath $AuditDirectory)) { New-Item -ItemType Directory -Path $AuditDirectory -Force | Out-Null }
$stamp=Get-Date -Format 'yyyyMMdd-HHmmss'
$auditPath=Join-Path $AuditDirectory "GALVisibility-$stamp.csv"
$targets=Import-Csv -LiteralPath $CsvPath
if (-not $targets -or -not ($targets[0].PSObject.Properties.Name -contains 'UserPrincipalName')) { throw 'Input CSV must contain a UserPrincipalName column and at least one row.' }
foreach ($target in $targets) {
 $upn=([string]$target.UserPrincipalName).Trim()
 $row=[ordered]@{Timestamp=(Get-Date -Format 'o');UserPrincipalName=$upn;DisplayName='';PreviousHiddenFromAddressListsEnabled='';NewHiddenFromAddressListsEnabled='';Status='';Error=''}
 try {
  if ([string]::IsNullOrWhiteSpace($upn)) { throw 'UserPrincipalName is blank.' }
  $user=Get-MgUser -UserId $upn -Property 'displayName,userPrincipalName,accountEnabled' -ErrorAction Stop
  $row.DisplayName=$user.DisplayName
  if ($user.AccountEnabled -ne $false) { $row.Status='Skipped (Entra account is not disabled)' }
  else {
   $mailbox=Get-Mailbox -Identity $upn -ErrorAction Stop
   $row.PreviousHiddenFromAddressListsEnabled=[bool]$mailbox.HiddenFromAddressListsEnabled
   if ($mailbox.IsDirSynced -eq $true) { $row.Status='Skipped (Hybrid-synchronised recipient; manage on-premises)' }
   elseif ($mailbox.HiddenFromAddressListsEnabled -eq $true) { $row.NewHiddenFromAddressListsEnabled=$true; $row.Status='Skipped (Already hidden)' }
   elseif ($PSCmdlet.ShouldProcess($upn,'Hide mailbox from Exchange Online address lists')) {
    Set-Mailbox -Identity $upn -HiddenFromAddressListsEnabled $true -ErrorAction Stop
    $verified=Get-Mailbox -Identity $upn -ErrorAction Stop
    $row.NewHiddenFromAddressListsEnabled=[bool]$verified.HiddenFromAddressListsEnabled
    if ($verified.HiddenFromAddressListsEnabled) { $row.Status='Updated (Now hidden)' } else { $row.Status='Failed (Post-change verification did not confirm hidden state)' }
   } else { $row.Status='WhatIf (No change made)'; $row.NewHiddenFromAddressListsEnabled=$row.PreviousHiddenFromAddressListsEnabled }
  }
 } catch { $row.Status='Failed'; $row.Error=$_.Exception.Message }
 [pscustomobject]$row | Export-Csv -LiteralPath $auditPath -NoTypeInformation -Append -Encoding UTF8
 Write-Host ("{0}: {1}" -f $upn,$row.Status)
}
Write-Host "Audit report: $auditPath"
