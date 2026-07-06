# Agent Guide: policy-collection-consolidation

This file is the primary context for AI agents working in this repository.

## What this repo is

Consolidated ACM governance policies from:

- [open-cluster-management-io/policy-collection](https://github.com/open-cluster-management-io/policy-collection) — official OCM policy examples and PolicySets
- [brian-jarvis/bry-acm-policy-samples](https://github.com/brian-jarvis/bry-acm-policy-samples) — production-style PolicyGenerator patterns

**Deployment model:** ArgoCD + PolicyGenerator only. No Application/Subscription (appsub).

## Repository map

```
.
├── AGENTS.md                 # This file — start here
├── policies/                 # PRIMARY: all PolicyGenerator projects
│   ├── operators/            # OLM OperatorPolicy installs
│   ├── cluster-configs/      # Cluster configuration
│   ├── acm-configs/          # ACM hub/spoke configuration
│   ├── policy-sets/          # Opt-in PolicySet bundles (openshift-plus, etc.)
│   └── examples/kustomize/   # Minimal PolicyGenerator tutorial
├── environments/             # Kustomize overlays per fleet (dev/implt/prod)
├── kustomize-configs/        # Shared transformers (ClusterSet, PolicySet suffix)
├── argocd/applications/      # ArgoCD Application manifests
├── template-examples/        # Standalone template/PolicyGenerator examples
├── legacy/                   # DEPRECATED raw Policy YAML (stable/community/3rd-party)
├── docs/                     # Human + machine-readable reference
└── build/validate-policies.sh
```

## Key rules

1. **All new policies use PolicyGenerator** — never add raw `Policy` CRs outside `legacy/`
2. **No appsub** — do not create Subscription, Channel, or Application (ACM) resources
3. **Every policy directory needs:**
   - `generator.yml` (PolicyGenerator manifest)
   - `kustomization.yaml` with `generators: [./generator.yml]`
   - `README.md` per [docs/policy-standards.md](docs/policy-standards.md)
4. **YAML format:** start documents with `---`, no trailing whitespace, blank line at EOF
5. **Placement:** use `Placement` API, not deprecated `PlacementRule`
6. **Namespaces:** default policy namespace is `acm-policies`; environments override via kustomize

## PolicyGenerator workflow

### Create a new policy

```bash
mkdir -p policies/<category>/<policy-name>
# Add manifests, generator.yml, kustomization.yaml, README.md
cd policies/<category>/<policy-name>
kustomize build --enable-alpha-plugins
```

### generator.yml skeleton

```yaml
---
apiVersion: policy.open-cluster-management.io/v1
kind: PolicyGenerator
metadata:
  name: gen-<unique-name>
policyDefaults:
  namespace: acm-policies
  remediationAction: inform
  standards:
    - "NIST SP 800-53"
  categories:
    - "CM Configuration Management"
  controls:
    - "CM-2 Baseline Configuration"
  policyLabels:
    policy_gen.name: <policy-name>
placementBindingDefaults:
  name: "<policy-name>-binding"
policies:
  - name: <policy-name>
    description: "What this policy does"
    manifests:
      - path: <manifest>.yml
```

### Test standalone

```bash
cd policies/<category>/<policy-name>
kustomize build --enable-alpha-plugins | kubectl apply --dry-run=client -f -
```

### Test full validation

```bash
./build/validate-policies.sh
```

## ArgoCD deployment

- Applications point at `environments/<env>` paths
- ArgoCD must use `kustomizeBuildOptions: --enable-alpha-plugins`
- See [argocd/README.md](argocd/README.md) and `policies/operators/gitops/argocd-policygenerator.yml`

## Environment model

| Environment | Namespace | Includes hub? |
|-------------|-----------|---------------|
| dev | acm-policies-dev | No |
| implt | acm-policies-implt | No |
| prod | acm-policies-prod | Yes (`local-cluster/`) |

Kustomize transformers in `kustomize-configs/` wire ManagedClusterSet names, PolicySet suffixes, and namespace references.

## Placement conventions

Reusable placements in `policies/acm-placements/`:

- `env-bound-placement` — all clusters in environment ClusterSet
- `env-bound-hub-placement` — hub only (`local-cluster`)
- `env-bound-nohub-placement` — spokes only

Feature-flag placements: `ft-<label-key>--<label-value>` (created by `policies/acm-configs/feature-flags-placement/`)

## Policy types

| Type | When to use | Example path |
|------|-------------|--------------|
| ConfigurationPolicy | Wrap K8s manifests | `policies/cluster-configs/` |
| OperatorPolicy | Install OLM operators | `policies/operators/` |
| Gatekeeper/Kyverno | Admission control | `policies/gatekeeper/`, `policies/policy-sets/community/` |
| PolicySet | Group related policies | `policies/policy-sets/` |

## Common footguns (for risk analysis)

- `MustOnlyHave` on RBAC resources with OpenShift role-aggregation → reconcile loops
- `inform` mode with delete/prune settings → silent until switched to enforce
- Empty `namespaceSelector: {}` on enforce policies → fleet-wide blast radius
- Policy without Placement → never distributes to managed clusters

## Legacy content

`legacy/stable/`, `legacy/community/`, `legacy/3rd-party/` contain deprecated raw Policy YAML. Do not extend. Migrate to `policies/` using PolicyGenerator.

## Contributing checklist

- [ ] PolicyGenerator project under `policies/`
- [ ] README with dependencies, ACM version, documentation links
- [ ] `kustomize build --enable-alpha-plugins` succeeds
- [ ] `./build/validate-policies.sh` passes
- [ ] No secrets/credentials in YAML
- [ ] Default `remediationAction: inform` unless creating resources

## Reference docs

- [docs/architecture.md](docs/architecture.md) — system design
- [docs/policy-standards.md](docs/policy-prerequisites.md) — formatting rules
- [docs/policy-list.md](docs/policy-list.md) — policy catalog
- [docs/argocd-deployment.md](argocd/README.md) — GitOps deployment
