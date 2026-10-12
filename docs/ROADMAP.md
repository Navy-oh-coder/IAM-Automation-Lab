# IAM Automation Lab — Programme Roadmap

## Purpose

Develop a practical, auditable identity governance programme alongside a separate Microsoft 365 Copilot governance workstream.

Priorities describe the recommended implementation sequence, not a claim that every capability is currently deployed.

## Priority 1 — Establish the identity security baseline

**Objective:** Document and validate core identity security controls before expanding automation.

- [ ] Review Conditional Access coverage, exclusions and policy design.
- [ ] Document MFA enforcement and authentication methods.
- [ ] Review emergency access accounts and monitoring.
- [ ] Review PIM eligibility, activation controls and standing privilege.
- [ ] Assess Identity Protection risk policies and response processes.
- [ ] Review privileged role separation and administrative accounts.
- [ ] Record licensing prerequisites, permissions, exceptions and validation evidence.

**Exit criteria:** A documented baseline, a list of gaps and evidence showing which controls have been validated.

## Priority 2 — Stabilise identity hygiene

**Objective:** Establish trustworthy identity data and actionable audit reports.

- [ ] Audit ownerless groups and missing identity attributes.
- [ ] Review inactive guest accounts and sponsor ownership.
- [ ] Identify direct group and licence assignments where applicable.
- [ ] Distinguish failed queries from genuine governance findings.
- [ ] Document remediation approval and evidence requirements.

**Exit criteria:** Repeatable audit-only reports with clear findings and documented limitations.

## Priority 3 — Complete Joiner-Mover-Leaver governance

**Objective:** Provide controlled and auditable identity lifecycle processes.

- [ ] Document the authoritative source for joiner, mover and leaver events.
- [ ] Complete and validate the leaver runbook.
- [ ] Design joiner provisioning and attribute population.
- [ ] Define mover access review and removal rules.
- [ ] Prefer attribute-driven dynamic groups where membership rules are appropriate.
- [ ] Use Access Packages for governed access requests, approvals and expiry where suitable.
- [ ] Use Lifecycle Workflows for supported lifecycle-triggered actions.
- [ ] Define exception handling, notifications and per-stage audit evidence.

**Exit criteria:** Documented lifecycle flows, test cases, failure handling and evidence of successful and failed stages.

## Priority 4 — Expand identity governance

**Objective:** Reduce excessive access and make ownership and review responsibilities explicit.

- [ ] Define Access Review scope, frequency and remediation rules.
- [ ] Design Entitlement Management catalogues and access packages.
- [ ] Review group ownership and access lifecycle.
- [ ] Establish workload identity and application governance.
- [ ] Review application permissions, consent and credential expiry.
- [ ] Assess external collaboration and cross-tenant access controls.

**Exit criteria:** Defined ownership, review, approval, expiry and remediation processes.

## Priority 5 — Build operational reporting

**Objective:** Measure governance outcomes rather than simply count scripts.

- [ ] Correct stale-account and licensing report logic.
- [ ] Standardise output paths, report schemas and timestamps.
- [ ] Track privileged role and PIM coverage.
- [ ] Track guest inactivity and review outcomes.
- [ ] Track joiner and leaver completion and failure rates.
- [ ] Track ownerless groups and identity data quality.
- [ ] Record remediation status and outstanding exceptions.
- [ ] Introduce dashboards only when reliable data sources are available.

**Exit criteria:** Defined metrics, reliable data sources and an agreed reporting cadence.

## Priority 6 — Copilot and agent governance

**Objective:** Build on identity and data governance to support safe AI adoption.

- [ ] Assess SharePoint permissions and oversharing.
- [ ] Review identity and access boundaries for Microsoft 365 Copilot.
- [ ] Document Microsoft Purview readiness and data protection controls.
- [ ] Review sensitivity labels, retention and data exposure where applicable.
- [ ] Define agent inventory, ownership, permissions and lifecycle controls.
- [ ] Review agent authentication, application permissions and secret management.
- [ ] Establish monitoring, approval and retirement processes for agents.

**Exit criteria:** A documented Copilot and agent governance model with explicit owners, controls and validation evidence.

## Engineering quality — applies to every priority

- [ ] Follow least privilege and document required permissions.
- [ ] Use dry-run or audit-only modes where appropriate.
- [ ] Validate inputs and handle partial failures explicitly.
- [ ] Record per-action outcomes without logging secrets.
- [ ] Add automated tests where practical.
- [ ] Test against mock data or a non-production tenant.
- [ ] Document known limitations, licensing requirements and rollback considerations.

## Delivery rule

Work on one or two actionable deliverables at a time. Keep future ideas in the roadmap until they are sufficiently defined to become implementation tasks.
