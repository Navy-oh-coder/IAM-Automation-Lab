$days = 90
$cutoff = (Get-Date).AddDays(-$days)

Get-MgUser -All -Property DisplayName,UserPrincipalName,AccountEnabled,SignInActivity |
Where-Object {
    $_.AccountEnabled -eq $true -and
    $_.SignInActivity.LastSuccessfulSignInDateTime -lt $cutoff
} |
Select-Object DisplayName,
              UserPrincipalName,
              AccountEnabled,
              @{N='LastSignIn';E={$_.SignInActivity.LastSuccessfulSignInDateTime}} |
Export-Csv C:\Temp\InactiveUsers90Days.csv -NoTypeInformation
