# Implementation guide: Entra Lifecycle Workflow → Exchange Online

This guide describes a reusable pattern for invoking an Azure Automation PowerShell runbook from a Microsoft Entra Lifecycle Workflow custom task extension. Tenant-specific values are represented as placeholders.

## 1. Architecture

1. Lifecycle Workflow selects the user and invokes the custom task at the intended lifecycle stage.
2. Custom task extension links the workflow to a Logic App and determines launch-and-continue or launch-and-wait behaviour.
3. Logic App receives the secured extension payload, extracts the user's UPN and starts an Azure Automation job.
4. Automation Account provides the runbook, runtime environment, job history and system-assigned managed identity.
5. Runbook authenticates to Exchange Online without a stored user password or certificate and runs approved actions.

## 2. Prepare Azure Automation

1. Create or select an Automation Account.
2. Enable its system-assigned managed identity.
3. Record the managed identity principal/object ID for permission assignment; do not confuse it with an application/client ID.
4. Create a PowerShell 7.4 runtime environment.
5. Add a compatible ExchangeOnlineManagement package. The source validation used version 3.10.1 with PowerShell 7.4; this is a test baseline, not a guarantee for every future combination.
6. Create and publish a runbook, then select the correct runtime environment.

### Runtime compatibility lesson

The source test found ExchangeOnlineManagement 3.10.1 required .NET 8 and failed under PowerShell 7.2; PowerShell 7.4 worked. Retest compatibility if changing the module or runtime.

## 3. Grant Exchange access to the managed identity

The tested permission model required two layers on the same Automation Account principal:

- Exchange Online application permission Exchange.ManageAsApp.
- An active Exchange Administrator directory role.

This is broad access. Review least privilege with your security team and assess Exchange Online application RBAC for narrower scope. Use the appropriate privileged role and approval process to grant permissions.

Example discovery/assignment commands. Replace the placeholder and obtain administrative approval before running; this command changes tenant permissions.

```powershell
Connect-MgGraph -Scopes "Application.Read.All","AppRoleAssignment.ReadWrite.All"

$ManagedIdentityObjectId = "<AUTOMATION-ACCOUNT-PRINCIPAL-ID>"
$ExchangeOnline = Get-MgServicePrincipal -Filter "appId eq '00000002-0000-0ff1-ce00-000000000000'"
$ExchangeManageAsAppRole = $ExchangeOnline.AppRoles | Where-Object { $_.Value -eq 'Exchange.ManageAsApp' }
if (-not $ExchangeOnline -or -not $ExchangeManageAsAppRole) {
    throw 'Could not find the Exchange Online service principal or Exchange.ManageAsApp app role.'
}
New-MgServicePrincipalAppRoleAssignment `
    -ServicePrincipalId $ManagedIdentityObjectId `
    -PrincipalId $ManagedIdentityObjectId `
    -ResourceId $ExchangeOnline.Id `
    -AppRoleId $ExchangeManageAsAppRole.Id
```

Discover your own tenant's initial domain rather than copying one from an example:

```powershell
(Get-MgOrganization).VerifiedDomains |
    Where-Object { $_.IsInitial -eq $true } |
    Select-Object Name, IsInitial
```

Use the returned initial onmicrosoft.com domain for the Exchange connection's Organization parameter.

## 4. Create the custom task extension

1. In Entra admin center, open ID Governance → Lifecycle workflows → Custom extensions.
2. Create a custom task extension. Choose Launch and continue for the initial asynchronous design.
3. Create the Consumption Logic App through the extension wizard; keep its generated secured trigger and authorization settings.
4. Add the custom task to the intended workflow and select the extension.
5. Enable the workflow only after the runbook and payload mapping have been tested.

Choose Launch and wait only if callback and task-result handling are deliberately implemented and tested.

## 5. Configure the Logic App

The UPN path in the extension payload is:

```text
triggerBody()?['data']?['subject']?['userPrincipalName']
```

For Azure Automation Create job, map the runbook parameter object:

```text
addProperty(
  json('{}'),
  'UserPrincipalName',
  triggerBody()?['data']?['subject']?['userPrincipalName']
)
```

Use the generated trigger from the extension wizard. The JSON in this repository is only a sanitized mapping illustration, not an importable replacement for the generated Logic App.

## 6. Test in layers

1. **Runbook only:** use the Automation Test pane with a dedicated test mailbox/identity. Verify module import and managed identity connection.
2. **Logic App action:** invoke through Lifecycle Workflows and inspect Logic App run history.
3. **Parameter mapping:** inspect Azure Automation job input and confirm parameters.UserPrincipalName contains the expected test UPN.
4. **End to end:** run the workflow on demand for a dedicated test account and inspect workflow and Automation job history.
5. **Write actions:** add one low-risk operation at a time with documented expected result and rollback/mitigation plan.

A successful Create job action alone does not prove that the runbook completed. If Wait for job is disabled, inspect the Automation job separately.

## 7. Troubleshooting

| Symptom | Likely cause | Check |
|---|---|---|
| Runbook not found | Runbook unpublished, stale selection or wrong Automation resource | Publish and reselect subscription, resource group, account and runbook. |
| Automation parameter empty | Incorrect trigger path or parameter object | Inspect trigger input; map data.subject.userPrincipalName to UserPrincipalName. |
| Exchange connection unauthorized | Missing permissions, propagation delay, wrong domain or stale token | Verify principal ID, application permission, directory role and initial tenant domain. Retest after propagation. |
| System.Runtime 8.0 assembly error | Module/runtime incompatibility | Align runtime and module; validate PowerShell 7.4 for the cited baseline. |
| Module loading error | Runtime assembly mismatch or import failure | Capture full exception and compare runtime/module versions. |
| Runbook test succeeds but workflow-triggered job fails | Different execution path, permission propagation or trigger authorization | Compare runtime, principal and job inputs; test through actual workflow path. |
| Designer Run with payload authentication error | Generated trigger expects secured request context | Test through Lifecycle Workflows; do not weaken trigger security. |
| Error logs empty | Early failure or insufficient diagnostic output | Add structured step output, catch details and rethrow; never log tokens/secrets. |
| Logic App succeeds but job fails | Create job only submitted the job | Inspect Automation job status and output separately. |

## 8. Production-readiness checklist

- [ ] Validate every write/destructive command independently.
- [ ] Keep dry-run as the default until explicit approval to execute changes.
- [ ] Emit structured results for each action, target UPN, timestamp and status.
- [ ] Use try/catch/finally and disconnect Exchange Online in finally.
- [ ] Never log access tokens, credentials or signed URLs.
- [ ] Alert on failed Automation jobs and agree monitoring/test suppression procedures.
- [ ] Review permissions for least privilege.
- [ ] Store tenant-specific Logic App configuration only in approved private storage.
- [ ] Keep scripts peer-reviewed and versioned.
- [ ] Document owner, support route, test evidence and mitigation steps.
