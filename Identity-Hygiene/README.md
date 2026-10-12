Entra Governance
A collection of Microsoft Graph PowerShell scripts used to perform Microsoft Entra ID hygiene and governance reviews.

Scripts
1_Stale_Accounts.ps1
Identifies enabled accounts that have not signed in within the defined period.

Output:

InactiveUsers90Days.csv
2_Directly_Assigned_Licences.ps1
Identifies users with directly assigned licences rather than group-based licensing.

Used to support licence governance and group-based licensing initiatives.

Output:

UserList_Microsoft_365_E5_Licences.csv
3_Groups_Without_Owners.ps1
Identifies Microsoft 365 Groups and Security Groups that do not have owners assigned.

Output:

OwnerlessGroups.csv
4_Users_With_Missing_Attributes.ps1
Reviews enabled users for missing:

Manager
Department
Job Title
Supports:

Dynamic Groups
Lifecycle Workflows
Access Reviews
Entitlement Management
Output:

AttributeHygieneAudit.csv
5_Guests_Not_Used_Recently.ps1
Identifies guest accounts that have not signed in within the defined period.

Supports guest lifecycle governance and cleanup.

Output:

StaleGuests90Days.csv
6_MFA_Auth_Method_Review.ps1
Reviews registered authentication methods and MFA configuration.

Optional if legacy authentication is already blocked via Conditional Access.

Required Microsoft Graph Permissions
Recommended:

AuditLog.Read.All
User.Read.All
Directory.Read.All
Group.Read.All
