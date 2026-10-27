# Read-only Exchange Online connection test for Azure Automation.
# Use a PowerShell 7.4 runtime and the Automation Account system-assigned identity.
# Supply the initial onmicrosoft.com domain from your own tenant.

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $OrganizationDomain
)

$ErrorActionPreference = 'Stop'

try {
    Import-Module ExchangeOnlineManagement -ErrorAction Stop
    Write-Output "PowerShell version: $($PSVersionTable.PSVersion)"
    Write-Output "ExchangeOnlineManagement version: $((Get-Module ExchangeOnlineManagement).Version)"

    Connect-ExchangeOnline -ManagedIdentity -Organization $OrganizationDomain -ShowBanner:$false -ErrorAction Stop
    $connection = Get-ConnectionInformation -ErrorAction Stop
    if (-not $connection) { throw 'No Exchange Online connection information was returned.' }

    $connection | Select-Object State, TokenStatus, ConnectionId, AppId | Format-List | Out-String | Write-Output
    if ($connection.State -notcontains 'Connected') { throw 'Exchange Online connection state was not Connected.' }
    Write-Output 'Read-only Exchange Online connection test passed.'
}
catch {
    Write-Error ("Exchange connection test failed: {0}" -f $_.Exception.Message)
    throw
}
finally {
    try { Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue }
    catch { Write-Warning 'Exchange disconnect cleanup failed.' }
}
