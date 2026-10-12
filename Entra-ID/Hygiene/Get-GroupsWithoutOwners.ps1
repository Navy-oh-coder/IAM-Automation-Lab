$groups = Get-MgGroup -All

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Starting Ownerless Group Audit" -ForegroundColor Green
Write-Host " Total Groups Found: $($groups.Count)" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$counter = 0
$ownerlessCount = 0

$results = foreach ($group in $groups)
{
    $counter++

    Write-Host "[$counter/$($groups.Count)] Checking: $($group.DisplayName)" -ForegroundColor Gray

    $owners = Get-MgGroupOwner -GroupId $group.Id -ErrorAction SilentlyContinue

    if (!$owners)
    {
        $ownerlessCount++

        Write-Host "    OWNERLESS GROUP FOUND" -ForegroundColor Red

        [PSCustomObject]@{
            GroupName       = $group.DisplayName
            MailNickname    = $group.MailNickname
            GroupId         = $group.Id
            MailEnabled     = $group.MailEnabled
            SecurityEnabled = $group.SecurityEnabled
            GroupType       = ($group.GroupTypes -join ",")
        }
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Audit Complete" -ForegroundColor Green
Write-Host " Groups Checked: $counter" -ForegroundColor Yellow
Write-Host " Ownerless Groups: $ownerlessCount" -ForegroundColor Red
Write-Host " Exporting CSV..." -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$results |
Sort-Object GroupName |
Export-Csv "C:\Temp\OwnerlessGroups.csv" -NoTypeInformation

Write-Host ""
Write-Host "CSV Exported:" -ForegroundColor Green
Write-Host "C:\Temp\OwnerlessGroups.csv" -ForegroundColor White