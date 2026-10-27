# Entra Lifecycle Workflows — Exchange custom extension

## Architecture

```text
Microsoft Entra Lifecycle Workflow
  └─ Run a Custom Task Extension
      └─ Logic App created from the extension wizard
          └─ Azure Automation: Create job
              └─ PowerShell 7.4 runbook
                  └─ Exchange Online PowerShell
                      └─ Approved offboarding actions
```

The reference implementation exercised the workflow-to-Logic-App-to-Azure-Automation-to-Exchange connection path in a test environment. Individual destructive offboarding actions must still be validated independently.

## Files

- [Implementation guide](./implementation-guide.md) — setup, permissions, testing and troubleshooting.
- [Test connection runbook](./runbooks/Test-ExchangeConnection.ps1) — read-only connection check.
- [Exchange offboarding runbook](./runbooks/Exchange-Offboarding.ps1) — dry-run by default; writes require an explicit switch.
- [Workflow mapping template](./logic-app/workflow-definition.template.json) — illustrative only, not deployable.
- [Sample trigger payload](./examples/sample-trigger-payload.json) — fictional example.
- [Parameter mapping](./examples/sample-parameter-mapping.md) — UPN and Automation parameter mapping.

## Create the Logic App from the extension wizard

Create the custom task extension in Entra ID Governance and use the wizard to create the Consumption Logic App. This supplies the expected security configuration and request schema.

**Do not replace the generated secured trigger with a generic manually-created HTTP trigger.** Do not commit an actual workflow export until callback URLs, signatures, tenant/resource IDs, connection references and other environment-specific values have been reviewed and removed.

## Launch and continue vs launch and wait

Use **Launch and continue** when the workflow only needs to submit the Logic App/Automation job. Inspect Azure Automation job status separately: a successful Create job action confirms submission, not completion.

Use **Launch and wait** only when callback and task-result handling have been implemented and tested end to end.

## Before enabling production

- [ ] Use a dedicated test identity and document expected effects.
- [ ] Verify the Automation Account system-assigned managed identity and principal ID.
- [ ] Confirm Exchange application permission and directory-role requirements.
- [ ] Confirm PowerShell 7.4 and a compatible ExchangeOnlineManagement package.
- [ ] Run the connection test and a read-only command first.
- [ ] Verify trigger payload and Automation job parameter input.
- [ ] Keep the offboarding runbook in dry-run mode until each write action has approval and test evidence.
- [ ] Configure job-failure monitoring and support ownership.
- [ ] Review least privilege; Exchange Administrator is broad. Assess Exchange Online application RBAC for narrower scope where feasible.
- [ ] Keep tenant-specific deployment artefacts in approved private storage, not this public repository.

## Microsoft Learn

- [Workflow extensibility — Microsoft Entra ID Governance](https://learn.microsoft.com/en-us/entra/id-governance/lifecycle-workflow-extensibility)
- [Trigger Logic Apps based on custom task extensions](https://learn.microsoft.com/en-us/entra/id-governance/trigger-custom-task)
- [Configure a Logic App for Lifecycle Workflow use](https://learn.microsoft.com/en-us/entra/id-governance/configure-logic-app-lifecycle-workflows)
- [Managed identities and Exchange Online PowerShell](https://learn.microsoft.com/en-us/powershell/exchange/connect-exo-powershell-managed-identity)
- [Runtime environments in Azure Automation](https://learn.microsoft.com/en-us/azure/automation/runtime-environment-overview)
- [Grant API permissions to managed identities](https://learn.microsoft.com/en-us/powershell/entra-powershell/grant-api-permissions-managed-identity)
