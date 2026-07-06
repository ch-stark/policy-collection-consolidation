# 07 — Policy Templates

ACM policies support **Go templates** to customize manifests per managed cluster using hub or spoke context.

## Template sources

| Function | Reads from | Example |
|----------|------------|---------|
| `fromClusterClaim` | Managed cluster claims | OpenShift version |
| `{{hub .ManagedClusterName hub}}` | Hub policy context | Cluster name |
| `{{hub fromConfigMap "ns" "cm" "key" hub}}` | Hub ConfigMap | Shared config |
| `lookup` | Live API on hub/spoke | Routes, Secrets |

## Files

| File | Demonstrates |
|------|--------------|
| `cluster-label-configmap.yml` | `fromClusterClaim` for OpenShift version |
| `hub-name-configmap.yml` | `{{hub .ManagedClusterName hub}}` |

## Disable templates on specific policies

When a manifest must be literal (e.g. PrometheusRule), set:

```yaml
configurationPolicyAnnotations:
  policy.open-cluster-management.io/disable-templates: "true"
```

## Verify

```bash
kubectl get configmap tutorial-cluster-info -n tutorial-demo -o yaml
# data should show per-cluster values on each spoke
```

## References

- [ACM policy templating](https://access.redhat.com/documentation/en-us/red_hat_advanced_cluster_management_for_kubernetes/2.14/html/governance/governance#policy-templates)
- `policies/operators/data-foundation/operatorpolicy.yml` — `fromClusterClaim` for channel
- `template-examples/per-cluster-data/` in this repo
