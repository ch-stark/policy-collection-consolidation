# 05 — Alerts for Critical Policies

Use ACM governance metrics with Prometheus to alert when policies are non-compliant.

## Metric

`policy_governance_info{type="root"}` — exposed when a root policy is not compliant.

## Files

| File | Purpose |
|------|---------|
| `alert-namespace.yml` | Namespace for alert-related resources on hub |
| `prometheusrule.yml` | `PolicyAlert` firing after 2 minutes non-compliance |

## Source

Adapted from `policies/acm-configs/policy-alerts/` in this repo.

## Apply note

`PrometheusRule` must land in a namespace monitored by ACM observability (default: `open-cluster-management`). The generator sets `remediationAction: enforce` for hub placement.

## Verify

```bash
oc get prometheusrule open-cluster-management-alerts -n open-cluster-management
# Trigger: set a tutorial policy to NonCompliant and wait 2m
```

## Severity

The example uses `severity: critical`. Adjust `for:` and `expr:` for your SLOs.
