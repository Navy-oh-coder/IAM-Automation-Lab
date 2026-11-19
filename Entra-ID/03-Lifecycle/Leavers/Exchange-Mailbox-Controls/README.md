# Exchange Online Leaver Mailbox Controls

## Overview

Two focused Exchange Online automations complement the broader leaver runbooks in the [parent folder](../README.md).

| Lab | Script | Purpose |
|---|---|---|
| 1 — GAL visibility | [Set-LeaverMailboxGALVisibility.ps1](./Set-LeaverMailboxGALVisibility.ps1) | Hide approved disabled-user cloud mailboxes from address lists. |
| 2 — Leaver auto-reply | [Set-LeaverMailboxAutoReply.ps1](./Set-LeaverMailboxAutoReply.ps1) | Apply a standard reply only when no enabled or scheduled reply exists. |

Restore scripts:
- [Restore-LeaverMailboxGALVisibility.ps1](./Restore-LeaverMailboxGALVisibility.ps1)
- [Restore-LeaverMailboxAutoReply.ps1](./Restore-LeaverMailboxAutoReply.ps1)

**Status: implementation artefacts added; execution and tenant validation are not yet evidenced.** These are lab scripts, not production-approved runbooks.

## Safety design

- Targets come from an approved CSV with a UserPrincipalName column. The scripts do not process every historically disabled account.
- Each identity is checked in Entra ID and skipped unless accountEnabled is false.
- Write scripts support -WhatIf and -Confirm.
- Existing hidden GAL state and enabled/scheduled auto-replies are preserved.
- Timestamped audit CSVs record previous state for rollback.
- Write operations are followed by a read-back verification.
- Per-target errors are recorded without stopping the remaining approved scope.

## Prerequisites

- PowerShell 7 recommended.
- Microsoft.Graph.Users and ExchangeOnlineManagement modules.
- Delegated Microsoft Graph User.Read.All consent for the signed-in operator.
- Exchange permissions sufficient to read and update the relevant mailbox properties. Verify role assignments in the target tenant.

## Input CSV

Create an approved scope file outside the repository:

    UserPrincipalName
    leaver1@contoso.com
    leaver2@contoso.com

Do not commit real user lists, mailbox messages, tenant exports or audit reports.

## Lab 1 — Hide disabled users from the GAL

Preview:

    ./Set-LeaverMailboxGALVisibility.ps1 -CsvPath C:\Temp\ApprovedLeavers.csv -WhatIf

After reviewing the preview and obtaining approval, run without -WhatIf. The script checks the Entra account state, current mailbox visibility and whether the recipient is directory-synchronised.

### Hybrid limitation

For Entra Connect-synchronised recipients, the authoritative msExchHideFromAddressLists attribute must be managed in on-premises Active Directory and synchronised. This lab deliberately skips recipients reported as directory-synchronised. Confirm source of authority in the target environment.

### Restore

    ./Restore-LeaverMailboxGALVisibility.ps1 -AuditCsvPath .\AuditReports\GALVisibility-YYYYMMDD-HHMMSS.csv -WhatIf

Review the audit rows before removing -WhatIf.

## Lab 2 — Apply a standard leaver auto-reply

Replace the example support address with an approved organisational contact. Preview:

    ./Set-LeaverMailboxAutoReply.ps1 -CsvPath C:\Temp\ApprovedLeavers.csv -SupportAddress helpdesk@contoso.com -WhatIf

The script only enables auto-reply when the current state is Disabled. Existing Enabled and Scheduled configurations are skipped. The example sets ExternalAudience to All; confirm this is permitted by the organisation's information-disclosure policy.

### Restore

The audit file stores the previous auto-reply state, internal and external messages, and external audience:

    ./Restore-LeaverMailboxAutoReply.ps1 -AuditCsvPath .\AuditReports\LeaverAutoReply-YYYYMMDD-HHMMSS.csv -WhatIf

Review the audit CSV before rollback.

## Validation checklist

- [ ] Confirm modules, Graph consent and Exchange permissions.
- [ ] Test with a dedicated disabled test account in a non-production tenant.
- [ ] Confirm an enabled Entra account is skipped.
- [ ] Confirm a missing mailbox is logged as a failure.
- [ ] Confirm an already-hidden mailbox is skipped.
- [ ] Confirm a hybrid-synchronised recipient is skipped by the GAL script.
- [ ] Confirm enabled and scheduled auto-replies are preserved.
- [ ] Confirm -WhatIf makes no changes.
- [ ] Confirm audit CSV fields and timestamps.
- [ ] Test each restore script and verify the original settings.
- [ ] Record module versions, test date, tenant type and observed outcomes before marking validated.

## Known limitations

- Scripts use delegated sign-in and the operator's permissions; unattended automation requires a separately designed authentication model.
- Audit CSVs are not tamper-proof compliance records. Store them in an access-controlled location with an appropriate retention policy.
- Hybrid GAL handling must be verified against the recipient source of authority and Exchange topology.
- ExternalAudience All may not be appropriate for every organisation.
- Restore scripts restore the properties captured by these scripts; they do not reverse unrelated offboarding actions.
- Do not use an unrestricted disabled-account query as a substitute for an approved leaver scope.
