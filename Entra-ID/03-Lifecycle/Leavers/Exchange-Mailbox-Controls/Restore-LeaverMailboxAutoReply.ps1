<#
.SYNOPSIS Restores auto-reply settings captured by Set-LeaverMailboxAutoReply.ps1.
.NOTES Run with -WhatIf first. Review the audit CSV before rollback.
#>
[CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='High')]
param([Parameter(Mandatory)][ValidateScript({Test-Path -LiteralPath $_ -PathType Leaf})][string]$AuditCsvPath)
$ErrorActionPreference='Stop'
Import-Module ExchangeOnlineManagement -ErrorAction Stop
if (-not (Get-ConnectionInformation)) { Connect-ExchangeOnline }
$entries=Import-Csv -LiteralPath $AuditCsvPath | Where-Object {$_.Status -eq 'Updated (OOH applied)'}
foreach ($entry in $entries) {
 try {
  if ($entry.PreviousAutoReplyState -notin @('Disabled','Enabled','Scheduled')) { throw 'Audit row has an invalid previous auto-reply state.' }
  if ($entry.PreviousExternalAudience -notin @('All','Known','None')) { throw 'Audit row has an invalid previous external-audience value.' }
  if ($PSCmdlet.ShouldProcess($entry.UserPrincipalName,'Restore previous auto-reply configuration')) {
   Set-MailboxAutoReplyConfiguration -Identity $entry.UserPrincipalName -AutoReplyState $entry.PreviousAutoReplyState -InternalMessage $entry.PreviousInternalMessage -ExternalMessage $entry.PreviousExternalMessage -ExternalAudience $entry.PreviousExternalAudience -ErrorAction Stop
   $check=Get-MailboxAutoReplyConfiguration -Identity $entry.UserPrincipalName -ErrorAction Stop
   if ([string]$check.AutoReplyState -ne $entry.PreviousAutoReplyState) { throw 'Rollback verification did not match the recorded previous state.' }
   Write-Host "$($entry.UserPrincipalName): Previous auto-reply state restored and verified."
  }
 } catch { Write-Warning "$($entry.UserPrincipalName): $($_.Exception.Message)" }
}
