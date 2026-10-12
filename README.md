# IAM Automation Lab

A practical engineering portfolio focused on Microsoft Entra ID, Identity and Access Management (IAM), identity governance, PowerShell automation and Microsoft 365 Copilot governance.

This repository contains working scripts, technical designs, implementation plans and lessons learned. Capabilities are labelled according to their current state so that planned work is not confused with tested functionality.

## Workstreams

### 1. Entra ID

Identity security, lifecycle automation, access governance and identity hygiene.

- **Security:** Conditional Access, MFA and authentication methods, Identity Protection, Privileged Identity Management (PIM) and emergency access.
- **Lifecycle:** Joiner, mover and leaver processes.
- **Governance:** Access Reviews, Entitlement Management, group and access governance, and Lifecycle Workflows.
- **Hygiene:** Stale identities, guest accounts, group ownership, missing attributes and licensing.
- **Reporting:** Group inventory, licensing reports, audit evidence and governance metrics.

Start here: [Entra-ID/README.md](Entra-ID/README.md)

### 2. Copilot Governance

Readiness and governance for Microsoft 365 Copilot and AI agents, including SharePoint permissions, data governance, Microsoft Purview and agent security.

Start here: [Copilot-Governance/README.md](Copilot-Governance/README.md)

## Programme roadmap

The central roadmap identifies priorities, dependencies and planned deliverables. Current execution is focused on Entra ID; Copilot governance remains a separate, deferred workstream for this pass.

See [docs/ROADMAP.md](docs/ROADMAP.md).

## Repository structure

```text
IAM-Automation-Lab/
├── Entra-ID/
│   ├── 01-Security/
│   ├── 02-Hygiene/
│   ├── 03-Lifecycle/
│   │   ├── Joiners/
│   │   ├── Movers/
│   │   └── Leavers/
│   ├── 04-Governance/
│   │   ├── Access-Reviews/
│   │   └── Entitlement-Management/
│   └── 05-Reporting/
├── Copilot-Governance/
│   └── Readiness/
└── docs/
    ├── ROADMAP.md
    └── ENGINEERING-STANDARDS.md
```

Folders are added as real artefacts are developed. The structure is intended to grow with the work rather than create empty folders for every possible feature.

## Implementation status

Each capability should use one of these statuses:

- **Implemented:** Relevant code or configuration artefacts exist.
- **In development:** Work has started but is incomplete.
- **Planned:** A design or intended outcome exists, but implementation has not started.
- **Placeholder:** A file or document exists but does not yet provide the described functionality.
- **Validated:** Testing evidence has been recorded for the stated environment and scope.

A capability must not be described as production-ready solely because a script or README exists.

## Engineering standards

All automation should follow least privilege, safe execution, explicit error handling, useful audit evidence and documented validation procedures.

See [docs/ENGINEERING-STANDARDS.md](docs/ENGINEERING-STANDARDS.md).

## Technology

- Microsoft Entra ID
- Microsoft Graph PowerShell SDK
- PowerShell 7
- Exchange Online PowerShell
- Microsoft Entra Identity Governance
- Microsoft Purview and Microsoft 365 Copilot governance

## Disclaimer

This is an engineering lab and portfolio. Scripts must be reviewed and tested in a non-production environment before use. Required licences, permissions, module versions and service limitations should be verified for the target environment.
