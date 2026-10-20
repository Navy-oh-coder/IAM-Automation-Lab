$CsvPath = "C:\Temp\Bulk_actions\Group_Bulk_Add.csv"

$Users = Import-Csv $CsvPath

$Audit = foreach ($User in $Users)
{
    $DisplayName = $User.DisplayName.Trim()
    $GroupName   = $User.GroupName.Trim()

    try
    {
        # Find the user
        $EntraUser = Get-MgUser -Filter "displayName eq '$DisplayName'"

        if (-not $EntraUser)
        {
            throw "User not found"
        }

        if ($EntraUser.Count -gt 1)
        {
            throw "Multiple users found"
        }

        # Find the group
        $Group = Get-MgGroup -Filter "displayName eq '$GroupName'"

        if (-not $Group)
        {
            throw "Group not found"
        }

        if ($Group.Count -gt 1)
        {
            throw "Multiple groups found"
        }

        # Add user to group
        New-MgGroupMember `
            -GroupId $Group.Id `
            -DirectoryObjectId $EntraUser.Id `
            -ErrorAction Stop

        Write-Host "SUCCESS: '$DisplayName' added to '$GroupName'" -ForegroundColor Green

        [PSCustomObject]@{
            DisplayName = $DisplayName
            GroupName   = $GroupName
            Status      = "Success"
            Error       = ""
            Timestamp   = Get-Date
        }
    }
    catch
    {
        Write-Host "FAILED: '$DisplayName' added to '$GroupName'" -ForegroundColor Red
        Write-Host "Reason: $($_.Exception.Message)" -ForegroundColor Yellow

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
