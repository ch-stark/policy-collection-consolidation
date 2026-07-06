# ArgoCD Deployment

Deploy consolidated policies via **ArgoCD** with PolicyGenerator support. No Application/Subscription (appsub) resources are used.

## Prerequisites

- OpenShift GitOps (ArgoCD) installed on the ACM hub
- PolicyGenerator plugin configured on the ArgoCD repo server (see `policies/operators/gitops/argocd-policygenerator.yml`)
- `ManagedClusterSet` and bindings configured per environment

## Quick start

```bash
# Deploy dev environment policies
kubectl apply -f argocd/applications/policy-collection-dev.yaml

# Or use the helper script
cd deploy
./argoDeploy.sh -u <your-fork-url> -b consolidation -p environments/dev -n acm-policies-dev
```

## Applications

| Application | Path | Namespace | Purpose |
|-------------|------|-----------|---------|
| `policy-collection-dev` | `environments/dev` | `acm-policies-dev` | Development fleet |
| `policy-collection-implt` | `environments/implt` | `acm-policies-implt` | Implementation/staging |
| `policy-collection-prod` | `environments/prod` | `acm-policies-prod` | Production fleet |

## PolicyGenerator in ArgoCD

ArgoCD must build with `--enable-alpha-plugins` so Kustomize invokes the PolicyGenerator plugin. The GitOps operator policy (`policies/operators/gitops/`) configures this on the default ArgoCD instance.

For custom ArgoCD instances, set:

```yaml
spec:
  kustomizeBuildOptions: --enable-alpha-plugins
```

## Release management

Point `targetRevision` at a git tag or branch per environment. Promote changes Dev → Implt → Prod by updating the Application `targetRevision` or using a release-management repo with ApplicationSets.

## What is NOT used

- `Subscription` / `Channel` (ACM Application Lifecycle)
- `PlacementRule` (deprecated; use `Placement`)
- Hub-side appsub GitOps
