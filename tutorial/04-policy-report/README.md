# 04 — PolicyReport

[PolicyReport](https://github.com/kubernetes-sigs/wg-policy-procs) resources (from Kyverno, Gatekeeper, or other engines) surface admission and audit violations.

This policy uses **MustNotHave** to flag any `PolicyReport` or `ClusterPolicyReport` containing a `fail` result.

## Source

Adapted from the upstream policy-collection `policy-check-policyreports` pattern (now implemented here via PolicyGenerator).

## Compliance logic

```yaml
complianceType: mustnothave
objectDefinition:
  apiVersion: wgpolicyk8s.io/v1alpha2
  kind: PolicyReport
  results:
    - result: fail
```

If a matching PolicyReport exists, the policy is **NonCompliant** (inform mode — no remediation).

## Verify

```bash
# On a managed cluster with Kyverno/Gatekeeper violations:
kubectl get policyreport -A
kubectl get policy tutorial-policy-report -n tutorial-policies -o yaml
```

## Related

- Kyverno auto-generates PolicyReports for cluster policies
- Gatekeeper constraint violations appear in PolicyReports when configured
