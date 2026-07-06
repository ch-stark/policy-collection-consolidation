# policy-collection-consolidation

WIP DO NOT USE IN PRODUCTION 


Consolidated ACM governance policies for [Open Cluster Management](https://open-cluster-management.io/) and **Red Hat Advanced Cluster Management 2.15+**, built with **PolicyGenerator** and deployed via **ArgoCD** (or applied directly with `kustomize`/`kubectl`).

Sources merged into this repository:

- [open-cluster-management-io/policy-collection](https://github.com/open-cluster-management-io/policy-collection)
- [brian-jarvis/bry-acm-policy-samples](https://github.com/brian-jarvis/bry-acm-policy-samples)

> **For AI agents:** start with [AGENTS.md](AGENTS.md) and the machine-readable [policy-catalog.yaml](policies/policy-catalog.yaml)

## Quick start

### Validate locally

```bash
./build/validate-policies.sh
```

### Build a single policy (standalone PolicyGenerator)

```bash
cd policies/operators/compliance-operator
kustomize build --enable-alpha-plugins
```

### Apply directly (no ArgoCD)

```bash
cd policies/<category>/<policy-name>
kustomize build --enable-alpha-plugins | kubectl apply -f -
```

### Deploy via ArgoCD

Update `repoURL` in `argocd/applications/` to point at your git remote, then:

```bash
kubectl apply -f argocd/applications/policy-collection-dev.yaml
```

See [argocd/README.md](argocd/README.md) for full deployment guide.

## Repository structure

| Path | Description |
|------|-------------|
| [`policies/`](policies/) | PolicyGenerator projects (primary content) |
| [`policies/policy-catalog.yaml`](policies/policy-catalog.yaml) | Machine-readable policy index (AI-ready) |
| [`environments/`](environments/) | Dev/implt/prod kustomize overlays |
| [`argocd/`](argocd/) | ArgoCD Application manifests (templates) |
| [`template-examples/`](template-examples/) | Advanced PolicyGenerator template patterns |
| [`tutorial/`](tutorial/) | Step-by-step PolicyGenerator, ArgoCD, dependencies, alerts |
| [`docs/`](docs/) | Architecture, standards, policy catalog |

## Deployment model

| Supported | Not supported |
|-----------|---------------|
| ArgoCD (OpenShift GitOps) | ACM Subscription/Channel |
| Direct `kustomize build` + `kubectl apply` | PlacementRule (deprecated) |
| PolicyGenerator + Kustomize | Application Lifecycle addon |
| Placement API | Raw Policy CRs (use PolicyGenerator) |

## Policy organization

Policies are grouped by function:

- **operators/** — OLM operator installation via OperatorPolicy
- **cluster-configs/** — OpenShift cluster configuration
- **acm-configs/** — ACM hub and spoke settings
- **security/** — CVE mitigations and security controls
- **cluster-health/** — Cluster health monitoring
- **cluster-maintenance/** — Cluster hygiene and cleanup
- **cluster-version/** — Cluster upgrade management
- **policy-sets/** — Opt-in bundles (OpenShift Plus, Gatekeeper, Kyverno)
- **third-party/** — Third-party integrations (CyberArk, LogicMonitor, Portworx)
- **gatekeeper/** — Gatekeeper constraint templates and validations
- **virt-management/** — OpenShift Virtualization policies

## AI readiness

This repository is designed to be consumed by AI tools:

- **[AGENTS.md](AGENTS.md)** — structured context for AI agents (repository map, rules, workflows)
- **[policies/policy-catalog.yaml](policies/policy-catalog.yaml)** — machine-readable index of all policies with metadata (category, description, ACM version, NIST controls, remediation action)
- **[CLAUDE.md](CLAUDE.md)** — Claude Code agent instructions
- Every `generator.yml` contains structured NIST 800-53 compliance metadata

## Contributing

1. Add PolicyGenerator project under `policies/<category>/<name>/`
2. Follow [docs/policy-prerequisites.md](docs/policy-prerequisites.md)
3. Run `./build/validate-policies.sh`
4. See [CONTRIBUTING.md](CONTRIBUTING.md)

## Documentation

- [AGENTS.md](AGENTS.md) — AI agent guide
- [docs/architecture.md](docs/architecture.md) — system design
- [docs/policy-list.md](docs/policy-list.md) — policy catalog
- [deploy/README.md](deploy/README.md) — ArgoCD deployment helper
- [tutorial/README.md](tutorial/README.md) — hands-on tutorial
