# M365 Mover Automation

## Purpose

Design controlled access changes when employees change role, manager or department.

## Current status

**Planned.** This folder currently contains design documentation, not an implemented mover script.

## Planned scope

- Assess manager, department and job-title changes.
- Review group memberships and licence requirements.
- Reduce unnecessary direct assignments.
- Record access changes and exceptions.

## Design approach

Consider attribute-driven dynamic groups where membership naturally follows authoritative user attributes. Use Access Packages for governed access requests, approvals and expiry, and Lifecycle Workflows for supported lifecycle-triggered actions. These controls serve different scenarios and should not be treated as interchangeable.

## Future considerations

Access Reviews, approvals, role-based access patterns and notifications to the new manager where useful.

## Validation and limitations

Define which access is removed automatically, which needs approval and how exceptions are handled. Test in a non-production environment before operational use.