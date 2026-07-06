# 03 — Policy Dependencies

Policies can declare `dependencies` so ACM waits for another policy to reach a compliance state before propagating the dependent policy.

Pattern from [gatekeeper-examples/policyGenerator.yaml](https://github.com/ch-stark/gatekeeper-examples/blob/main/policyGenerator.yaml) (install → check → configure chain).

## Example chain

```
tutorial-deps-namespace  →  Compliant  →  tutorial-deps-configmap
     (creates NS)                              (creates ConfigMap in NS)
```

## Generator snippet

```yaml
policies:
  - name: tutorial-deps-configmap
    dependencies:
      - name: tutorial-deps-namespace
        compliance: Compliant
        kind: Policy
    manifests:
      - path: deps-configmap.yml
```

## Verify on hub

```bash
kubectl get policy -n tutorial-policies
kubectl describe policy tutorial-deps-configmap -n tutorial-policies
# Look for dependency status in policy status
```

## When to use

- Operator install before configuration policies
- Namespace before namespaced resources
- Gatekeeper install before constraints (see gatekeeper-examples)
