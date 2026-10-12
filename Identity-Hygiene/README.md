# Entra ID Identity Hygiene

PowerShell automation for auditing Microsoft Entra ID identities, group ownership, licensing, user attributes, and authentication methods.

Designed to support **Identity and Access Management (IAM)**, security reviews, and ongoing identity governance.

---

## Scripts

| Script | Description |
|:---|:---|
| `1_Stale_Accounts.ps1` | Identifies enabled user accounts that have not signed in within the configured period. |
| `2_Directly_Assigned_Licences.ps1` | Identifies users with directly assigned licences to support group-based licensing. |
| `3_Groups_Without_Owners.ps1` | Identifies Microsoft 365 groups and security groups without owners. |
| `4_Users_With_Missing_Attributes.ps1` | Identifies enabled users missing manager, department, or job title attributes. |
| `5_Guests_Not_Used_Recently.ps1` | Identifies guest accounts with no sign-in activity within the configured period. |
| `6_MFA_Auth_Method_Review.ps1` | Reviews registered authentication methods and MFA-related configuration. |

---

## Technology Stack

- **PowerShell 7**
- **Microsoft Graph PowerShell SDK**
- **Microsoft Entra ID**

---

## Permissions

Required Microsoft Graph permissions depend on the script being executed. Review each script and grant only the permissions necessary for its functionality.

> **Note:** These scripts are intended for auditing and reporting. Validate findings before performing remediation.
