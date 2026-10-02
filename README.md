# IAM Automation Lab

PowerShell automation, identity governance, and Microsoft 365 engineering projects focused on improving Identity and Access Management (IAM), Joiner-Mover-Leaver (JML) processes, security governance, and operational efficiency.

This repository serves as an engineering lab for developing, testing, and documenting automation solutions across Microsoft Entra ID, Microsoft 365, Exchange Online, Identity Governance, and Copilot readiness initiatives.

---

## Repository Structure

```text
IAM-Automation-Lab
│
├── JML-Automation
│   ├── Joiner
│   ├── Movers
│   └── Leavers
│
├── Identity-Hygiene
│   ├── Inactive-Users
│   ├── Guest-Lifecycle
│   └── Manager-Sync
│
├── Governance
│   ├── Access-Reviews
│   ├── Entitlement-Management
│   └── Lifecycle-Workflows
│
└── Reporting
    ├── Group-Inventory
    ├── Licensing
    └── Copilot-Readiness
```

---

# Joiner Automation

Automation for onboarding new starters into Microsoft 365 and Entra ID.

### Objectives

- Create new user accounts
- Assign managers
- Populate user attributes
- Assign licences
- Configure mailbox settings
- Add security and Microsoft 365 group memberships
- Generate onboarding audit reports

---

# Mover Automation

Automation for internal role changes and departmental transfers.

### Objectives

- Update managers
- Modify group memberships
- Reassign licences
- Perform access reviews
- Support group-based access management
- Reduce directly assigned permissions
- Maintain audit trails

---

# Leaver Automation

Automation for offboarding users from Microsoft 365.

### Current Features

#### Entra ID Offboarding

- Disable account
- Remove manager
- Revoke active sessions
- Remove group memberships
- Remove licences
- Export audit logs

#### Exchange Online Offboarding

- Convert mailbox to shared
- Remove distribution groups
- Remove mail-enabled security groups
- Export audit logs

---

# Identity Hygiene

Projects focused on maintaining accurate and secure identity data.

### Inactive Users

- Detect dormant accounts
- Identify stale users
- Reclaim licences
- Generate inactivity reports
- Support automated remediation

### Guest Lifecycle Management

- Detect inactive guest accounts
- Review guest activity
- Notify guest sponsors
- Revoke licences
- Remove expired guests
- Generate governance reports

### Manager & Attribute Sync

- Validate manager assignments
- Check department values
- Check employee hire dates
- Identify missing user attributes
- Generate alerts and remediation reports

---

# Governance

Identity Governance solutions using Microsoft Entra ID.

### Access Reviews

- Group access reviews
- Guest access reviews
- Manager attestations
- Access certification
- Review reporting

### Entitlement Management

- Access Packages
- Approval workflows
- Assignment policies
- Access lifecycle management
- Temporary access controls

### Lifecycle Workflows

- Joiner workflows
- Mover workflows
- Leaver workflows
- Workflow monitoring
- Governance reporting

---

# Reporting

Data collection, auditing, and governance reporting.

### Group Inventory

- Group ownership
- Membership analysis
- Dynamic group reporting
- Team-connected group reporting
- Governance assessments

### Licensing

- Licence utilisation
- Group-based licensing analysis
- Direct assignment reporting
- Cost optimisation opportunities

### Copilot Readiness

- Microsoft 365 data governance assessments
- Security posture reviews
- Permission analysis
- Purview readiness checks
- Copilot deployment readiness reporting

---

# Technology Stack

- PowerShell 7
- Microsoft Graph PowerShell SDK
