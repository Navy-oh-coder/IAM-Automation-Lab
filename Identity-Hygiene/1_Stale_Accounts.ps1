$users = Get-MgUser -All

foreach ($user in $users)
{
    $licenses = Get-MgUserLicenseDetail -UserId $user.Id

    if ($licenses)
    {
        [PSCustomObject]@{
            DisplayName = $user.DisplayName
            UPN         = $user.UserPrincipalName
            LicenceCount = $licenses.Count
        }
    }
} |
Export-Csv C:\Temp\LicensedUsers.csv -NoTypeInformation