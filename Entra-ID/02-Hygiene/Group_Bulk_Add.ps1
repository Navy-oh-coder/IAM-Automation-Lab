$CsvPath = "C:\Temp\testCSV.csv"
$GroupName = "GRP-User-Assigned-Lessons-Learnt-Main-Power-App"

$Users = Import-Csv $CsvPath

# Find the group
$Group = Get-MgGroup -Filter "displayName eq '$GroupName'"

if (-not $Group)
{
    throw "Group '$GroupName' not found"
}

if ($Group.Count -gt 1)
{
    throw "Multiple groups found with name '$GroupName'"
}

$Audit = foreach ($User in $Users)
{
    $DisplayName = $User.DisplayName

    try
    {
        $EntraUser = Get-MgUser -Filter "displayName eq '$DisplayName'"

        if (-not $EntraUser)
        {
            throw "User not found"
        }

        if ($EntraUser.Count -gt 1)
        {
            throw "Multiple users found"
        }

        New-MgGroupMember `
            -GroupId $Group.Id `
            -DirectoryObjectId $EntraUser.Id `
            -ErrorAction Stop

        Write-Host "SUCCESS: $DisplayName added to $GroupName" -ForegroundColor Green

        [PSCustomObject]@{
            DisplayName = $DisplayName
            GroupName   = $GroupName
            Status      = "Success"
            Timestamp   = Get-Date
        }
    }
    catch
    {
        Write-Host "FAILED: $DisplayName" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Yellow

        [PSCustomObject]@{
            DisplayName = $DisplayName
            GroupName   = $GroupName
            Status      = "Failed"
            Error       = $_.Exception.Message
            Timestamp   = Get-Date
        }
    }
}

$Audit | Export-Csv `
    "C:\Temp\Audits\GroupMembershipAudit.csv" `
    -NoTypeInformation

Write-Host "Completed." -ForegroundColor Cyan
