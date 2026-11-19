# Intune Device Compliance & Entra Conditional Access

## Overview

This lab demonstrates a Zero Trust device-access pattern across Microsoft Intune and Microsoft Entra ID.

- **Intune — device posture evaluation:** assesses enrolled Windows devices against an assigned compliance policy.
- **Entra ID — access decision:** consumes the device compliance signal and applies Conditional Access to grant or block access to cloud resources.

**Status: implementation guide documented; tenant configuration and end-to-end validation are not yet evidenced in this repository.** This guide is not proof that a policy has been deployed or tested.

## Objectives

1. Establish a baseline Windows device compliance policy in Intune.
2. Understand the built-in Default Device Compliance Policy checks.
3. Use Conditional Access to require compliant devices for selected corporate resources.
4. Validate impact in report-only mode before enforcement.

## Architecture

    Windows endpoint
          |
          v
    Microsoft Intune
      - BitLocker
      - Antivirus
      - Windows Firewall
      - Minimum supported OS version
          |
          | Device compliance state
          v
    Microsoft Entra ID
      - Conditional Access evaluation
      - Require device marked compliant
          |
          v
    Microsoft 365 / selected cloud resources

## Prerequisites

- Windows device enrolled in Intune and registered/joined appropriately with Entra ID.
- Intune and Entra licensing that supports the required compliance and Conditional Access capabilities; verify tenant entitlements.
- Administrative permissions to configure Intune compliance policies and Entra Conditional Access.
- Dedicated test user and test device.
- Emergency access account excluded from this Conditional Access policy and monitored under the organisation's emergency-access procedure.

## Part 1 — Configure Windows compliance in Intune

Navigate to Intune admin centre → Devices → Compliance → Policies and create a Windows compliance policy.

Example controls from this lab:

| Area | Requirement |
|---|---|
| Device health | Require BitLocker encryption |
| System security | Require antivirus |
| System security | Require Windows Firewall |
| Device properties | Enforce a minimum OS version |

Choose the minimum OS version from the organisation's currently supported Windows servicing baseline; do not blindly reuse an old example build number. Assign to a dedicated test group first.

Review non-compliance actions and grace periods deliberately. Policy assignment alone does not prove that devices have evaluated or become compliant.

## Part 2 — Default Device Compliance Policy

Review Intune admin centre → Devices → Compliance → Compliance policy settings.

The built-in default policy evaluates baseline conditions including:

1. Whether a compliance policy is assigned.
2. Whether the device is active within the configured validity period.
3. Whether an enrolled user exists.

The source lab uses 30 days as the example active-device validity period. Confirm the actual tenant setting rather than assuming it is universal.

If a device passes its custom compliance policy but fails the default policy's active-device check, investigate its last check-in and configured validity period, then initiate a device sync where appropriate.

## Part 3 — Configure Conditional Access

Navigate to Microsoft Entra admin centre → Protection → Conditional Access → Policies.

Create a policy using a controlled test scope:

| Setting | Lab configuration |
|---|---|
| Name | CA - Require Compliant Device for Corporate Access |
| Users | Dedicated test users initially |
| Exclusions | Emergency / break-glass accounts |
| Target resources | Selected test cloud apps initially |
| Conditions | Windows device platform for this Windows-only lab |
| Grant | Require device to be marked as compliant |
| Initial state | Report-only |

Start in Report-only mode. Review Entra sign-in logs and Conditional Access evaluation results over an appropriate observation period; the source lab suggests 24–48 hours. Check representative user, device and application scenarios before enabling the policy.

Do not switch to On solely because the observation period has elapsed. Confirm expected results, investigate unexpected blocks and obtain change approval.

## Part 4 — Test scenarios

| Scenario | Expected result to validate |
|---|---|
| Enrolled Windows device meets all assigned requirements | Intune reports compliant; Conditional Access requirement can be satisfied |
| Device fails a required compliance setting | Intune reports non-compliant; access is blocked when policy is enforced |
| Device has not checked in within configured validity period | Investigate default policy active status and device sync |
| Unmanaged or unregistered device | Compliant-device grant requirement is not satisfied |
| Emergency access account | Excluded from this policy; separate emergency-access controls still apply |
| Policy remains report-only | Sign-in logs show report-only evaluation; this policy does not block access |

Record actual sign-in log result, device compliance state, policy result and exceptions for each test. Expected outcomes are test criteria, not claimed results.

## Security and operational considerations

- Exclude emergency access accounts and monitor their use separately.
- Stage assignment: test group, pilot group, then broader scope.
- Keep the initial policy in report-only mode while assessing sign-in impact.
- Do not combine unrelated device platforms unless their compliance policies are also designed and tested.
- Keep Conditional Access exclusions minimal, documented and owned.
- Plan for device replacement, re-enrolment, stale device records and users with multiple devices.
- Document rollback/change procedure before enforcement.
- Do not commit tenant IDs, device identifiers, sign-in exports or user data.

## Validation evidence to add

- [ ] Sanitised Intune compliance policy configuration.
- [ ] Default Device Compliance Policy settings and actual active-device validity period.
- [ ] Conditional Access policy configuration and exclusions.
- [ ] Report-only sign-in evidence for compliant and non-compliant scenarios.
- [ ] Evidence of emergency-account exclusion.
- [ ] Change approval and enforcement decision.
- [ ] Post-enforcement verification, if subsequently enabled.

## Further development

- Authentication strengths and phishing-resistant MFA.
- Device filters and platform-specific compliance policies.
- Risk-based Conditional Access with Identity Protection.
- Monitoring policy changes and sign-in failures through Log Analytics / Microsoft Sentinel.
