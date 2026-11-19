<#
.SYNOPSIS Restores previous GAL visibility values captured by the companion lab script.
.NOTES Run with -WhatIf first. Only rows marked Updated (Now hidden) are considered.
#>
[CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='High')]
param([Parameter(Mandatory)][ValidateScript({Test-Path -LiteralPath $_ -PathType Leaf})][string]$AuditCsvPath)
$ErrorActionPreference='Stop'
Import-Module ExchangeOnlineManagement -ErrorAction Stop
if (-not (Get-ConnectionInformation)) { Connect-ExchangeOnline }
$entries=Import-Csv -LiteralPath $AuditCsvPath | Where-Object {$_.Status -eq 'Updated (Now hidden)'}
foreach ($entry in $entries) {
 try {
  if ($entry.PreviousHiddenFromAddressListsEnabled -notin @('True','False')) { throw 'Audit row has no valid previous visibility value.' }
  $previous=[System.Convert]::ToBoolean($entry.PreviousHiddenFromAddressListsEnabled)
  if ($PSCmdlet.ShouldProcess($entry.UserPrincipalName,"Restore visibility to $previous")) {
   Set-Mailbox -Identity $entry.UserPrincipalName -HiddenFromAddressListsEnabled $previous -ErrorAction Stop
   $check=Get-Mailbox -Identity $entry.UserPrincipalName -ErrorAction Stop
   if ([bool]$check.HiddenFromAddressListsEnabled -ne $previous) { throw 'Rollback verification did not match the recorded value.' }
   Write-Host "$($entry.UserPrincipalName): Restored and verified."
  }
 } catch { Write-Warning "$($entry.UserPrincipalName): $($_.Exception.Message)" }
}
