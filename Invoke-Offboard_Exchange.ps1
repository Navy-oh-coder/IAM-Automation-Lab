<#
.SYNOPSIS
    Exchange Online Offboarding Script

.DESCRIPTION
    Converts mailbox to Shared Mailbox,
    removes Distribution Group memberships,
    removes Mail-Enabled Security Group memberships,
    and creates an audit report.

.AUTHOR
    Winton Naviyo | Identity Administrator
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$UserPrincipalName,

    [string]$AuditLogPath = "./AuditReports/ExchangeOffboarding.csv"
)

# Ensure audit folder exists

$logDir = Split-Path $AuditLogPath -Parent

if ($logDir -and !(Test-Path $logDir)) {

    New-Item -ItemType Directory `
        -Path $logDir `
        -Force | Out-Null
}

Write-Host ""
Write-Host "=== STARTING EXCHANGE OFFBOARDING ===" -ForegroundColor Cyan
Write-Host "Target User: $UserPrincipalName" -ForegroundColor White
Write-Host ""

# Connect Exchange if required

if (-not (Get-Command Set-Mailbox -ErrorAction SilentlyContinue)) {

    Write-Host "[*] Connecting to Exchange Online..." -ForegroundColor Yellow

    Connect-ExchangeOnline
}

# Verify mailbox exists

$mailbox = Get-Mailbox $UserPrincipalName -ErrorAction Stop

Write-Host "[+] Mailbox Found: $($mailbox.DisplayName)" -ForegroundColor Green

# Convert mailbox

Write-Host "[*] Step 1: Converting mailbox to Shared Mailbox..." -ForegroundColor Yellow

Set-Mailbox `
    -Identity $UserPrincipalName `
    -Type Shared

Write-Host "    Mailbox converted successfully." -ForegroundColor Green

# Distribution Groups

Write-Host ""
Write-Host "[*] Step 2: Finding Distribution Group memberships..." -ForegroundColor Yellow

$DistributionGroups = Get-DistributionGroup |
Where-Object {

    (Get-DistributionGroupMember $_.Identity -ResultSize Unlimited |
    Select-Object -ExpandProperty PrimarySmtpAddress) -contains $UserPrincipalName

}

foreach ($Group in $DistributionGroups) {

    try {

        Remove-DistributionGroupMember `
            -Identity $Group.Identity `
            -Member $UserPrincipalName `
            -Confirm:$false

        Write-Host "    Removed from Distribution Group: $($Group.DisplayName)" -ForegroundColor Green

    }

    catch {

        Write-Host "    FAILED: $($Group.DisplayName)" -ForegroundColor Red

    }
}

# Mail Enabled Security Groups

Write-Host ""
Write-Host "[*] Step 3: Finding Mail-Enabled Security Groups..." -ForegroundColor Yellow

$MailSecurityGroups = Get-DistributionGroup -ResultSize Unlimited |
Where-Object {
    $_.RecipientTypeDetails -eq "MailUniversalSecurityGroup"
}

foreach ($Group in $MailSecurityGroups) {

    try {

        $Members = Get-DistributionGroupMember $Group.Identity -ResultSize Unlimited

        if ($Members.PrimarySmtpAddress -contains $UserPrincipalName) {

            Remove-DistributionGroupMember `
                -Identity $Group.Identity `
                -Member $UserPrincipalName `
                -Confirm:$false

            Write-Host "    Removed from Mail Security Group: $($Group.DisplayName)" -ForegroundColor Green
        }

    }

    catch {

        Write-Host "    FAILED: $($Group.DisplayName)" -ForegroundColor Red

    }
}

# Build Audit Record

Write-Host ""
Write-Host "[*] Creating Audit Report..." -ForegroundColor Yellow

$auditRecord = [PSCustomObject]@{

    Timestamp         = Get-Date
    UserPrincipalName = $UserPrincipalName
    MailboxConverted  = $true
    DistributionListsRemoved = $DistributionGroups.Count
    ProcessedBy       = (Get-ConnectionInformation).UserPrincipalName

}

$auditRecord |
Export-Csv `
    -Path $AuditLogPath `
    -NoTypeInformation `
    -Append

Write-Host ""
Write-Host "=== EXCHANGE OFFBOARDING COMPLETE ===" -ForegroundColor Cyan
Write-Host "Audit Report: $AuditLogPath" -ForegroundColor Green
Write-Host ""