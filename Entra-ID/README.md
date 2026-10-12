# Entra ID

This workstream covers Microsoft Entra ID security, identity lifecycle management, access governance, identity hygiene and reporting.

## Areas of focus

The corresponding repository folders use numeric prefixes to keep the execution areas in a conventional, sortable order.

- **01-Security:** Conditional Access, MFA, authentication methods, Identity Protection, Privileged Identity Management (PIM) and emergency access.
- **03-Lifecycle:** Joiner, mover and leaver processes.
- **04-Governance:** Access Reviews, Entitlement Management, group ownership and Lifecycle Workflows.
- **02-Hygiene:** Stale identities, guest accounts, missing attributes, group ownership and licensing analysis.
- **05-Reporting:** Identity inventory, licensing reports, audit evidence and governance metrics.

## Repository status

The repository contains a mixture of scripts and planning documentation. Each capability must be labelled accurately as implemented in code, in development, planned, a placeholder or validated. Code presence does not prove successful execution or production readiness.

## Engineering principles

- Apply least privilege.
- Prefer auditable and reversible changes.
- Separate reporting from remediation.
- Document prerequisites, limitations and validation evidence.
- Test against mock data or a non-production tenant before operational use.

See the [programme roadmap](../docs/ROADMAP.md) and [engineering standards](../docs/ENGINEERING-STANDARDS.md).