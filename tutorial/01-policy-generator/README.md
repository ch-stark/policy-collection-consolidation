# 01 — PolicyGenerator

PolicyGenerator is a Kustomize plugin that wraps ordinary Kubernetes manifests in ACM `Policy` resources so you maintain one source of truth.

## Files

| File | Purpose |
|------|---------|
| `demo-namespace.yml` | Target namespace on managed clusters |
| `demo-configmap.yml` | Simple manifest wrapped as a ConfigurationPolicy |

## How it works

1. Place manifests in this directory
2. Reference them in `../generator.yml` under `policies[].manifests`
3. Run `kustomize build --enable-alpha-plugins` from `tutorial/`

The generator emits:

- `Policy` with embedded `ConfigurationPolicy` templates
- `PlacementBinding` linking the policy to `tutorial-placement`

## Try it

```bash
cd ..
kustomize build --enable-alpha-plugins | grep -A5 "kind: Policy"
kubectl get policy -n tutorial-policies   # after apply
```

## Reference

- [Policy Generator plugin](https://github.com/stolostron/policy-generator-plugin)
- `policies/examples/kustomize/` in this repo
