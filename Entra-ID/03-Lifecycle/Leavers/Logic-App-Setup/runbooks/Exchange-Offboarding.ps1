<#
.SYNOPSIS
    Exchange Online offboarding runbook.

.DESCRIPTION
    Receives one UserPrincipalName from an Entra Lifecycle Workflow.

    Actions:
    1. Validates the mailbox.
    2. Converts a user mailbox to a shared mailbox.
    3. Discovers distribution group and mail-enabled security group memberships.
    4. Optionally removes those memberships.

.NOTES
    Runtime Environment:
        PowerShell 7.4

    Required package:
        ExchangeOnlineManagement 3.10.1

    Authentication:
        Azure Automation system-assigned managed identity
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$UserPrincipalName,

    # Leave false for the first test.
    [bool]$RemoveMailEnabledGroups = $True
    )

$ErrorActionPreference = "Stop"
$Organization = "Salix365.onmicrosoft.com"

Write-Output "=========================================="
Write-Output "Starting Exchange Online offboarding"
Write-Output "Target user: $UserPrincipalName"
Write-Output "PowerShell version: $($PSVersionTable.PSVersion)"
Write-Output "Remove mail-enabled groups: $RemoveMailEnabledGroups"
Write-Output "=========================================="

try {
    # ----------------------------------------------------
    # STEP 1: Import Exchange Online module
    # ----------------------------------------------------

    Write-Output "Step 1: Importing ExchangeOnlineManagement..."

    Import-Module ExchangeOnlineManagement `
        -RequiredVersion 3.10.1 `
        -Force `
        -ErrorAction Stop

    Write-Output "ExchangeOnlineManagement imported successfully."

    # ----------------------------------------------------
    # STEP 2: Connect using the Automation managed identity
    # ----------------------------------------------------

    Write-Output "Step 2: Connecting to Exchange Online..."

    Connect-ExchangeOnline `
        -ManagedIdentity `
        -Organization $Organization `
        -ShowBanner:$false `
        -ErrorAction Stop

    Write-Output "Connected to Exchange Online successfully."

    # ----------------------------------------------------
    # STEP 3: Validate the target mailbox
    # ----------------------------------------------------

    Write-Output "Step 3: Validating mailbox..."

    $Mailbox = Get-Mailbox `
        -Identity $UserPrincipalName `
        -ErrorAction Stop

    Write-Output "Mailbox found: $($Mailbox.DisplayName)"
    Write-Output "Primary SMTP address: $($Mailbox.PrimarySmtpAddress)"
    Write-Output "Current mailbox type: $($Mailbox.RecipientTypeDetails)"

    # ----------------------------------------------------
    # STEP 4: Convert mailbox to shared
    # ----------------------------------------------------
    if ($Mailbox.RecipientTypeDetails -eq "SharedMailbox") {

        Write-Output "Mailbox is already a shared mailbox. No conversion required."

    }
    else {

        Write-Output "Step 4: Converting mailbox to shared..."

        Set-Mailbox `
            -Identity $UserPrincipalName `
            -Type Shared `
            -ErrorAction Stop

        Write-Output "Set-Mailbox command completed successfully."

        Write-Output "Waiting 30 seconds for Exchange replication..."
        Start-Sleep -Seconds 30

        $UpdatedMailbox = Get-Mailbox `
            -Identity $UserPrincipalName `
            -ErrorAction Stop

        Write-Output "Mailbox type after conversion: $($UpdatedMailbox.RecipientTypeDetails)"

        if ($UpdatedMailbox.RecipientTypeDetails -eq "SharedMailbox") {

            Write-Output "Mailbox converted and verified as SharedMailbox."

        }
        else {

            Write-Warning "Mailbox conversion could not yet be verified."
            Write-Warning "Current mailbox type: $($UpdatedMailbox.RecipientTypeDetails)"
            Write-Warning "The conversion request may have succeeded but Exchange has not yet updated all services."

        }
    }

    # ----------------------------------------------------
    # STEP 5: Configure Automatic Replies
    # ----------------------------------------------------
    Write-Output "Step 5: Configuring automatic replies..."

    Set-MailboxAutoReplyConfiguration `
        -Identity $UserPrincipalName `
        -AutoReplyState Enabled `
        -InternalMessage "Thank you for your email. This mailbox is no longer actively monitored. Please contact Reception or the relevant department for assistance." `
        -ExternalMessage "Thank you for your email. This mailbox is no longer actively monitored. Please contact Reception or the relevant department for assistance." `
        -ExternalAudience All `
        -ErrorAction Stop

    Write-Output "Automatic replies configured successfully."

    # ----------------------------------------------------
    # STEP 6: Discover mail-enabled group memberships
    # ----------------------------------------------------

    Write-Output "Step 6: Discovering mail-enabled group memberships..."

    $MatchingGroups = [System.Collections.Generic.List[object]]::new()

    $MailEnabledGroups = Get-DistributionGroup `
        -ResultSize Unlimited `
        -RecipientTypeDetails MailUniversalDistributionGroup, MailUniversalSecurityGroup `
        -ErrorAction Stop

    Write-Output "Mail-enabled groups to inspect: $($MailEnabledGroups.Count)"

    foreach ($Group in $MailEnabledGroups) {
        try {
            $Member = Get-DistributionGroupMember `
                -Identity $Group.Identity `
                -ResultSize Unlimited `
                -ErrorAction Stop |
                Where-Object {
                    $_.PrimarySmtpAddress -and
                    $_.PrimarySmtpAddress.ToString() -ieq $UserPrincipalName
                } |
                Select-Object -First 1

            if ($Member) {
                $MatchingGroups.Add(
                    [PSCustomObject]@{
                        Identity             = $Group.Identity
                        DisplayName          = $Group.DisplayName
                        PrimarySmtpAddress   = $Group.PrimarySmtpAddress
                        RecipientTypeDetails = $Group.RecipientTypeDetails
                    }
                )

                Write-Output "Membership found: $($Group.DisplayName) [$($Group.RecipientTypeDetails)]"
            }
        }
        catch {
            Write-Warning "Could not inspect group '$($Group.DisplayName)': $($_.Exception.Message)"
        }
    }

    Write-Output "Total mail-enabled group memberships found: $($MatchingGroups.Count)"

    # ----------------------------------------------------
    # STEP 7: Remove memberships when enabled
    # ----------------------------------------------------

    if (-not $RemoveMailEnabledGroups) {
        Write-Output "Group removal is disabled."
        Write-Output "The groups above were discovered but no memberships were changed."
    }
    else {

    Write-Output "Step 7: Removing mail-enabled group memberships..."

    $RemovedCount = 0

    foreach ($Group in $MatchingGroups) {
        try {

            Remove-DistributionGroupMember `
                -Identity $Group.Identity `
                -Member $UserPrincipalName `
                -Confirm:$false `
                -ErrorAction Stop

            $RemovedCount++

            Write-Output "Removed from: $($Group.DisplayName)"
        }
        catch {
            Write-Warning "Failed to remove user from '$($Group.DisplayName)': $($_.Exception.Message)"
        }
    }

    Write-Output "Successfully removed from $RemovedCount mail-enabled groups."
}

    Write-Output "=========================================="
    Write-Output "Exchange Online offboarding completed"
    Write-Output "Mailbox: $UserPrincipalName"
    Write-Output "Groups found: $($MatchingGroups.Count)"
    Write-Output "Group removal enabled: $RemoveMailEnabledGroups"
    Write-Output "=========================================="
}
catch {
    Write-Output "=== OFFBOARDING ERROR ==="
    Write-Output "Target user: $UserPrincipalName"
    Write-Output "Exception type: $($_.Exception.GetType().FullName)"
    Write-Output "Error message: $($_.Exception.Message)"
    Write-Output "Error ID: $($_.FullyQualifiedErrorId)"
    Write-Output "Failed command: $($_.InvocationInfo.MyCommand)"
    Write-Output "Script line: $($_.InvocationInfo.ScriptLineNumber)"
    Write-Output "Position: $($_.InvocationInfo.PositionMessage)"
    Write-Output "Stack trace: $($_.ScriptStackTrace)"
    Write-Output "=== END ERROR ==="

    throw $_
}
finally {
    Disconnect-ExchangeOnline `
        -Confirm:$false `
        -ErrorAction SilentlyContinue

    Write-Output "Exchange Online session disconnected."
}
