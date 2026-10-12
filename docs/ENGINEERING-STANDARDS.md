# Engineering Standards

## 1. Permissions and authentication

- Use least-privilege permissions appropriate to each script.
- Document required Microsoft Graph scopes, application permissions, directory roles and Exchange permissions.
- Prefer supported managed identity or certificate-based authentication for unattended automation where appropriate.
- Never commit client secrets, passwords, access tokens, private keys or real tenant credentials.
- Separate read-only reporting from actions that modify access or user state.

## 2. Safe execution

- Validate input files, required columns, identity identifiers and target objects.
- Use audit-only or dry-run behaviour where appropriate before making changes.
- Require explicit confirmation or an approved workflow for high-impact actions.
- Handle missing objects, unsupported object types, throttling and partial failures.
- Avoid broad destructive actions without documented scope and safeguards.
- Consider mailbox retention, licensing dependencies and legal or compliance requirements before offboarding changes.

## 3. Audit evidence

- Record the timestamp, target identity, action, outcome and error details needed for investigation.
- Distinguish attempted, successful, failed and skipped actions.
- Use correlation identifiers where available.
- Do not report success merely because a command was attempted.
- Avoid storing secrets or unnecessary personal information in logs.
- Document where reports are stored, who can access them and how long they are retained.

## 4. Testing and validation

- Test scripts with mock data or in a non-production tenant first.
- Add Pester tests for reusable functions and important decision logic where practical.
- Test empty results, missing attributes, duplicate input, API errors and partial failures.
- Verify permissions and module prerequisites before execution.
- Record what was tested and what remains unverified.
- Do not claim production validation without appropriate evidence.

## 5. Documentation and status

Every capability README should state:

- Purpose and scope.
- Current implementation status.
- Prerequisites and required permissions.
- How to run or validate the solution.
- Expected output and audit evidence.
- Known limitations and risks.
- Relevant roadmap item or GitHub issue.

Use the repository's defined status labels consistently. Planned functionality must not be described as implemented.

## 6. Change conventions

- Prefer small, focused changes with clear commit messages.
- Keep filenames descriptive and consistent.
- Update documentation when paths, behaviour or prerequisites change.
- Preserve existing work unless removal is explicitly agreed.
- Review the complete diff before publishing changes.
- Never include real production exports or sensitive tenant information in portfolio examples.
