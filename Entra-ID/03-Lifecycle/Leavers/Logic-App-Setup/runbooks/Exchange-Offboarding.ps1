# Dry-run-first Exchange Online offboarding runbook template.
# By default, this script performs read-only discovery and reports planned actions.
# Pass -ExecuteChanges only after change approval and independent validation.
# Use a PowerShell 7.4 runtime and the Automation Account system-assigned identity.

[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
param(
    [Parameter(Mandatory = $true)]
    [ValidatePattern('^[^\s@]+@[^\s@]+\.[^\s@]+$')]
    [string] $UserPrincipalName,

    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string] $OrganizationDomain,

    [switch] $ExecuteChanges
)

$ErrorActionPreference = 'Stop'
$runStarted = Get-Date
$results = [System.Collections.Generic.List[object]]::new()
$connected = $false

function Add-ActionResult {
    param(
        [string] $Action,
        [string] $Target,
        [ValidateSet('Planned', 'Succeeded', 'Failed', 'Skipped')]
        [string] $Status,
        [string] $Message
    )
    $results.Add([pscustomobject]@{
        Timestamp = (Get-Date).ToString('o')
        UserPrincipalName = $UserPrincipalName
        Action = $Action
        Target = $Target
        Status = $Status
        Message = $Message
    })
}

try {
    Import-Module ExchangeOnlineManagement -ErrorAction Stop
    Connect-ExchangeOnline -ManagedIdentity -Organization $OrganizationDomain -ShowBanner:$false -ErrorAction Stop
    $connected = $true

    $mailbox = Get-Mailbox -Identity $UserPrincipalName -ErrorAction Stop
    Write-Output ("Found mailbox: {0} ({1})" -f $mailbox.DisplayName, $mailbox.PrimarySmtpAddress)

    if ($mailbox.RecipientTypeDetails -eq 'SharedMailbox') {
        Add-ActionResult -Action 'ConvertMailboxToShared' -Target $UserPrincipalName -Status 'Skipped' -Message 'Mailbox is already shared.'
    }
    elseif (-not $ExecuteChanges) {
        Add-ActionResult -Action 'ConvertMailboxToShared' -Target $UserPrincipalName -Status 'Planned' -Message 'Dry-run only; no change made.'
    }
    elseif ($PSCmdlet.ShouldProcess($UserPrincipalName, 'Convert mailbox to shared mailbox')) {
        try {
            Set-Mailbox -Identity $UserPrincipalName -Type Shared -ErrorAction Stop
            Add-ActionResult -Action 'ConvertMailboxToShared' -Target $UserPrincipalName -Status 'Succeeded' -Message 'Command completed; verify resulting mailbox state.'
        }
        catch {
            Add-ActionResult -Action 'ConvertMailboxToShared' -Target $UserPrincipalName -Status 'Failed' -Message $_.Exception.Message
            throw
        }
    }

    $groups = @(Get-DistributionGroup -ResultSize Unlimited -ErrorAction Stop)
    foreach ($group in $groups) {
        try {
            $members = @(Get-DistributionGroupMember -Identity $group.Identity -ResultSize Unlimited -ErrorAction Stop)
            $member = $members | Where-Object {
                $_.PrimarySmtpAddress -and ([string]$_.PrimarySmtpAddress).Equals([string]$mailbox.PrimarySmtpAddress, [System.StringComparison]::OrdinalIgnoreCase)
            } | Select-Object -First 1
            if (-not $member) { continue }

            if (-not $ExecuteChanges) {
                Add-ActionResult -Action 'RemoveMailEnabledGroupMembership' -Target ([string]$group.Identity) -Status 'Planned' -Message 'Dry-run only; membership not changed.'
                continue
            }

            if ($PSCmdlet.ShouldProcess("$UserPrincipalName in $($group.DisplayName)", 'Remove mail-enabled group membership')) {
                Remove-DistributionGroupMember -Identity $group.Identity -Member $UserPrincipalName -Confirm:$false -ErrorAction Stop
                Add-ActionResult -Action 'RemoveMailEnabledGroupMembership' -Target ([string]$group.Identity) -Status 'Succeeded' -Message 'Removal command completed; verify membership.'
            }
        }
        catch {
            Add-ActionResult -Action 'InspectOrRemoveMailEnabledGroupMembership' -Target ([string]$group.Identity) -Status 'Failed' -Message $_.Exception.Message
        }
    }

    if ($results.Count -eq 0) {
        Add-ActionResult -Action 'Discovery' -Target $UserPrincipalName -Status 'Succeeded' -Message 'Mailbox found; no matching mail-enabled group memberships discovered.'
    }

    $summary = [pscustomobject]@{
        RunStarted = $runStarted.ToString('o')
        RunCompleted = (Get-Date).ToString('o')
        UserPrincipalName = $UserPrincipalName
        DryRun = (-not $ExecuteChanges)
        ActionCount = $results.Count
        Results = $results
    }
    Write-Output 'Action results (JSON):'
    $summary | ConvertTo-Json -Depth 6 | Write-Output

    if ($results.Status -contains 'Failed') { throw 'One or more actions failed. Review the action results above.' }
}
catch {
    Write-Error ("Exchange offboarding runbook failed: {0}" -f $_.Exception.Message)
    throw
}
finally {
    if ($connected) {
        try { Disconnect-ExchangeOnline -Confirm:$false -ErrorAction SilentlyContinue }
        catch { Write-Warning 'Exchange disconnect cleanup failed.' }
    }
}
