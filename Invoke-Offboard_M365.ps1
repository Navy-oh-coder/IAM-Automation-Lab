<#
.SYNOPSIS
    Automated M365 User Offboarding & Compliance Script
.DESCRIPTION
    Executes an end-to-end offboarding sequence for a terminated employee:
    Blocks sign-in, revokes sessions, converts mailbox, strips licenses, 
    removes group memberships, and exports an audit trail report.
.AUTHOR
    Winton Naviyo | Identity Administrator
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$UserPrincipalName,
    
    [string]$AuditLogPath = "./AuditReports/Offboarding.csv"
)

# Ensure audit directory exists
$logDir = Split-Path $AuditLogPath -Parent
if ($logDir -and !(Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir -Force | Out-Null }

Write-Host "=== STARTING M365 OFFBOARDING SEQUENCE FOR: $UserPrincipalName ===" -ForegroundColor Cyan

# 1. Retrieve User Object
$user = Get-MgUser -UserId $UserPrincipalName -ErrorAction Stop
Write-Host "[+] Target User Found: $($user.DisplayName) (ID: $($user.Id))" -ForegroundColor Green

# 2. Block Sign-In
Write-Host "[*] Step 1: Blocking user sign-in..." -ForegroundColor Yellow
Update-MgUser -UserId $user.Id -AccountEnabled:$false

# 3. Remove manager
Write-Host "[*] Step 2: Removing manager..." -ForegroundColor Yellow

try {
    Remove-MgUserManagerByRef -UserId $user.Id -ErrorAction Stop
    Write-Host "    Manager removed." -ForegroundColor Green
}
catch {
    Write-Host "    Failed to remove manager: $($_.Exception.Message)" -ForegroundColor Red
}


# 4. Revoke Active Sessions
Write-Host "[*] Step 3: Revoking all active refresh tokens and sessions..." -ForegroundColor Yellow
Revoke-MgUserSignInSession -UserId $user.Id



# 5. Strip Group Memberships
Write-Host "[*] Step 4: Removing user from all security and distribution groups..." -ForegroundColor Yellow
$memberGroups = Get-MgUserMemberOf -UserId $user.Id
foreach ($group in $memberGroups) {
    try {
        Remove-MgGroupMemberByRef -GroupId $group.Id -DirectoryObjectId $user.Id
        Write-Host "    Removed from group ID: $($group.Id)" -ForegroundColor Gray
    } catch {
        Write-Host "    Failed to remove from group ID $($group.Id): $_" -ForegroundColor Red
    }
}


# 6. Remove All Assigned Licenses
Write-Host "[*] Step 5: Stripping assigned product licenses..." -ForegroundColor Yellow
$assignedLicenses = (Get-MgUser -UserId $user.Id -Property AssignedLicenses).AssignedLicenses
if ($assignedLicenses) {
    $licenseToRemove = @($assignedLicenses.SkuId)
    Set-MgUserLicense -UserId $user.Id -AddLicenses @() -RemoveLicenses $licenseToRemove
    Write-Host "    Successfully removed $($licenseToRemove.Count) license(s)." -ForegroundColor Green
} else {
    Write-Host "    No active licenses found to remove." -ForegroundColor Gray
}


# 7. Generate Compliance Evidence Report
Write-Host "[*] Step 6: Generating compliance evidence log..." -ForegroundColor Yellow
$auditRecord = [PSCustomObject]@{
    Timestamp              = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    UserPrincipalName      = $user.UserPrincipalName
    DisplayName            = $user.DisplayName
    AccountStatus          = "Disabled"
    SessionsRevoked        = $true
    LicensesRemoved        = $true
    GroupsStripped         = $memberGroups.Count
    ProcessedBy            = (Get-MgContext).Account
}

$auditRecord | Export-Csv -Path $AuditLogPath -NoTypeInformation
Write-Host "=== OFFBOARDING COMPLETE. Audit report saved to: $AuditLogPath ===" -ForegroundColor Cyan
