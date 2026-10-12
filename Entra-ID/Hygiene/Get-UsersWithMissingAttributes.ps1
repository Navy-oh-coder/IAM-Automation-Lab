$users = Get-MgUser -All -Property `
DisplayName,
UserPrincipalName,
Department,
JobTitle,
AccountEnabled

$enabledUsers = $users | Where-Object {
    $_.AccountEnabled -eq $true
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Starting Attribute Hygiene Audit" -ForegroundColor Green
Write-Host " Enabled Users Found: $($enabledUsers.Count)" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$counter = 0
$issueCount = 0

$results = foreach ($user in $enabledUsers)
{
    $counter++

    Write-Progress `
        -Activity "Checking User Attributes" `
        -Status $user.DisplayName `
        -PercentComplete (($counter / $enabledUsers.Count) * 100)

    $MissingManager = $false
    $MissingDepartment = [string]::IsNullOrWhiteSpace($user.Department)
    $MissingJobTitle = [string]::IsNullOrWhiteSpace($user.JobTitle)

    try
    {
        $null = Get-MgUserManager `
            -UserId $user.Id `
            -ErrorAction Stop
    }
    catch
    {
        $MissingManager = $true
    }

    if ($MissingManager -or $MissingDepartment -or $MissingJobTitle)
    {
        $issueCount++

        Write-Host "Issue Found -> $($user.DisplayName)" -ForegroundColor Red

        [PSCustomObject]@{
            DisplayName       = $user.DisplayName
            UPN               = $user.UserPrincipalName
            Department        = $user.Department
            JobTitle          = $user.JobTitle
            MissingManager    = $MissingManager
            MissingDepartment = $MissingDepartment
            MissingJobTitle   = $MissingJobTitle
        }
    }
}

Write-Progress `
    -Activity "Checking User Attributes" `
    -Completed

$results |
Sort-Object DisplayName |
Export-Csv "C:\Temp\AttributeHygieneAudit.csv" -NoTypeInformation

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Audit Complete" -ForegroundColor Green
Write-Host " Users Checked: $counter" -ForegroundColor Yellow
Write-Host " Users With Issues: $issueCount" -ForegroundColor Red Cyan
Write-Host ""
Write-Host "CSV Exported:" -ForegroundColor Green
Write-Host "C:\Temp\AttributeHygieneAudit.csv" -ForegroundColor White