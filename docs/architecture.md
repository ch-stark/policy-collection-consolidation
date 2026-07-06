# Architecture

## Design principles

1. **PolicyGenerator-first** — Kubernetes manifests are source of truth; OCM `Policy` CRs are generated
2. **GitOps via ArgoCD** — no ACM Application Lifecycle (Subscription/Channel)
3. **Environment overlays** — same policies, different namespaces/ClusterSets per fleet stage
4. **Reusable placements** — avoid 1:1 placement-to-policy coupling
5. **AI-readable** — consistent structure, README per policy, machine-parseable metadata

## Data flow

```mermaid
flowchart LR
  Git[Git Repository] --> ArgoCD[ArgoCD Application]
  ArgoCD --> Kustomize[Kustomize + PolicyGenerator]
  Kustomize --> Hub[ACM Hub Namespace]
  Hub --> Propagator[Policy Propagator]
  Propagator --> Spokes[Managed Clusters]
```

## Build pipeline

```mermaid
flowchart TD
  A[environments/dev] --> B[kustomize-configs transformers]
  B --> C[policies/ resources]
  C --> D[PolicyGenerator plugin]
  D --> E[Policy + PlacementBinding + PolicySet]
  E --> F[kubeconform validation]
```

## Directory responsibilities

| Path | Role |
|------|------|
| `policies/` | PolicyGenerator source projects grouped by domain |
| `environments/` | Per-fleet kustomize overlay (namespace, ClusterSet, suffix) |
| `kustomize-configs/` | Shared kustomize Component (ClusterSet refs, PolicySet naming) |
| `local-cluster/` | Hub ManagedCluster patches (prod only) |
| `argocd/` | ArgoCD Application definitions |
| `legacy/` | Deprecated raw policies (migration source) |
| `template-examples/` | Reusable patterns not tied to a full policy |

## Consolidation sources

| Source | Migrated to | Notes |
|--------|-------------|-------|
| policy-collection `stable/` | `legacy/stable/` | Raw YAML, migrate over time |
| policy-collection `community/` | `legacy/community/` | Raw YAML, migrate over time |
| policy-collection `policygenerator/policy-sets/` | `policies/policy-sets/` | Already PolicyGenerator |
| bry-acm-policy-samples `policies/` | `policies/` | Primary policy library |
| bry-acm-policy-samples `environments/` | `environments/` | Environment model |
| bry-acm-policy-samples `template-examples/` | `template-examples/` | Template patterns |

## What was removed

- `deploy/subscription.yaml`, `deploy/deploy.sh` — appsub GitOps
- `policygenerator/subscription.yaml` — appsub demo
- Duplicate Kyverno policies (upstream policy-collection cleanup)

## Namespace strategy

- Generator default: `acm-policies` (placeholder)
- Environment overlay sets actual namespace: `acm-policies-dev`, `acm-policies-prod`, etc.
- `namespace-namereference.yml` rewrites policy dependency namespaces

## PolicySet strategy

Large bundles (openshift-plus, gatekeeper sets) live in `policies/policy-sets/` and are **opt-in** via separate ArgoCD Applications or explicit kustomize `resources` entries.
