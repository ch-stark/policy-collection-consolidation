# 06 — MustNotHave Example

**MustNotHave** means: if an object matching the template exists on the cluster, the policy is **NonCompliant**.

## Example: failed OLM InstallPlan

When an `InstallPlan` is in `Failed` phase, the cluster has a broken operator subscription. This policy detects that state.

Source: `policies/cluster-validations/olm/health/failed-installplan.yml`

## Generator configuration

```yaml
manifests:
  - path: failed-installplan.yml
    name: olm-failed-installplan
    complianceType: mustnothave
```

## Contrast with MustHave / MustOnlyHave

| complianceType | Non-compliant when |
|----------------|-------------------|
| `musthave` | Object does **not** exist |
| `mustonlyhave` | Extra or missing fields vs template |
| `mustnothave` | Matching object **exists** |

## Verify

```bash
kubectl get installplan -A | grep Failed
kubectl get policy tutorial-mustnothave-olm -n tutorial-policies
```

## Footgun

Do not use `mustonlyhave` on RBAC resources affected by OpenShift role aggregation — causes reconcile loops. See `AGENTS.md`.
