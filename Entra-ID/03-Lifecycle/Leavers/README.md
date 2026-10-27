# M365 Offboarding Automation

## Overview

This folder contains reference PowerShell scripts and implementation notes for Microsoft Entra ID, Microsoft 365 and Exchange Online offboarding.

**Status: reference material; production readiness is not implied.** The scripts and integration patterns require environment-specific permission review and testing before use.

## Existing scripts

| File | Purpose | Important note |
|---|---|---|
| [Invoke-Offboard-M365.ps1](./Invoke-Offboard-M365.ps1) | Reference sequence for identity/session, licence and group offboarding actions | Review group types, licensing dependencies, error handling and audit accuracy before use. |
| [Invoke-Offboard-Exchange.ps1](./Invoke-Offboard-Exchange.ps1) | Reference Exchange Online mailbox and mail-enabled group actions | Validate each write operation and ensure the audit log reflects actual results. |
| [Invoke-Offboard-Placeholder.ps1](./Invoke-Offboard-Placeholder.ps1) | Preserved placeholder | Not a working entry point. |

## Entra Lifecycle Workflows → Logic App → Azure Automation

See [Logic App custom extension setup](./Logic-App-Setup/README.md) for the documented integration pattern, setup sequence, examples, test runbooks and troubleshooting.

The integration pattern has been exercised end to end in a test environment. That does **not** mean all mailbox or group-removal actions in the existing scripts have been independently validated.

## Safety checklist

- Use a dedicated test account and non-production environment first.
- Review CSV schemas and verify every target identity before execution.
- Confirm required Microsoft Graph, Entra directory-role and Exchange permissions.
- Test each destructive action independently; preserve mailbox, legal hold, retention and licensing requirements.
- Record per-action success, failure and skipped states; do not infer success from a submitted job or a success banner.
- Review group-type handling and nested/dynamic group behaviour.
- Never commit tenant identifiers, object IDs, resource IDs, signed trigger URLs, access tokens, credentials or employer-specific configuration.
- Treat examples in this folder as templates, not a substitute for change approval and operational validation.
