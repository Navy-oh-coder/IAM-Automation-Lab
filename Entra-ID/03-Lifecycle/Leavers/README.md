# M365 Offboarding Automation

## Current status

**Scripts present; validation status unconfirmed.** The repository contains Microsoft 365 and Exchange Online offboarding scripts. Review permissions, group-type handling, error paths, audit accuracy and mailbox/licensing dependencies before use.

## Entra ID and Microsoft 365 script

`Invoke-Offboard-M365.ps1`

The script contains actions intended to block sign-in, remove a manager, revoke sessions, remove assigned licences, remove group memberships and export a report. These behaviours have not been independently validated in this repository.

## Exchange Online script

`Invoke-Offboard-Exchange.ps1`

The script contains actions intended to convert a mailbox to a shared mailbox, remove mail-enabled group memberships and export a report. Validate its handling of errors and evidence before use.

## Preserved placeholder

`Invoke-Offboard-Placeholder.ps1` is an effectively empty placeholder retained from the original repository. It is not a working offboarding entry point.

## Safety and validation

- Review CSV schema and target identities before execution.
- Confirm required Microsoft Graph and Exchange permissions.
- Validate each action separately and record successful, failed and skipped outcomes.
- Confirm mailbox retention, licensing and compliance requirements.
- Test in a non-production environment; do not treat command output alone as proof of successful offboarding.