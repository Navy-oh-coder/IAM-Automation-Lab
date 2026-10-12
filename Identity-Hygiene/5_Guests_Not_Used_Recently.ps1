$cutoff = (Get-Date).AddDays(-90)

Get-MgUser -All `
    -Filter "userType eq 'Guest'" `
    -Property DisplayName,UserPrincipalName,SignInActivity,AccountEnabled |
Where-Object {
    $_.SignInActivity.LastSuccessfulSignInDateTime -lt $cutoff -or
    $null -eq $_.SignInActivity.LastSuccessfulSignInDateTime
} |
Select-Object DisplayName,
              UserPrincipalName,
              AccountEnabled,
              @{N='LastSignIn';E={$_.SignInActivity.LastSuccessfulSignInDateTime}} |
Export-Csv "C:\Temp\StaleGuests90Days.csv" -NoTypeInformation