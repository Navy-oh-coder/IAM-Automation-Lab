# Entra ID Identity Hygiene

Audit-oriented PowerShell utilities for reviewing identity data, group ownership, licensing and guest activity in Microsoft Entra ID.

## Scripts and current status

| Script | Current behaviour | Status |
|---|---|---|
| `Get-LicensedUsersReport-LegacyDuplicate.ps1` | Queries users and their licence details, then exports users with licence records. | Legacy duplicate; not a stale-account detector |
| `Get-LicensedUsersReport.ps1` | Queries users and their licence details, then exports users with licence records. | Licensed-user report; does not establish whether licences were assigned directly |
| `Get-GroupsWithoutOwners.ps1` | Queries groups and reports groups for which no owners were returned. | Implemented in code; requires validation |
| `Get-UsersWithMissingAttributes.ps1` | Checks enabled users for missing manager, department or job title information. | Implemented in code; requires validation |
| `Get-StaleGuests.ps1` | Reports guest accounts with no successful sign-in recorded or sign-in activity older than the configured 90-day threshold. | Implemented in code; requires validation |
| `Review-AuthenticationMethods-PLACEHOLDER.ps1` | Contains a heading only. | Placeholder; not functional |
| `Get-StaleEnabledUsers.ps1` | Exports enabled users whose last successful sign-in is older than the configured 90-day threshold. | Implemented in code; requires validation |

## Important limitations

- The two licensed-user reports substantially overlap. Consolidation or a genuine direct-versus-group-based licensing analysis is future work.
- Missing or unavailable sign-in data must not automatically be interpreted as proof that an account is stale.
- API permissions, sign-in data availability, paging, errors and export results must be validated in the target tenant.
- No script in this folder should be considered production-ready solely because code exists.

## Prerequisites and permissions

Review each script for its Microsoft Graph PowerShell module requirements and required permissions before running it. Grant only the permissions necessary for the intended report.

## Safe use

These scripts are intended for audit and reporting. Review findings before remediation, and do not commit production exports or sensitive tenant data to the repository.