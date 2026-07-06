# policy-collection-consolidation

Local consolidated ACM governance policies for [Open Cluster Management](https://open-cluster-management.io/), built with **PolicyGenerator** and deployed via **ArgoCD**.

Sources merged into this repository:

- [open-cluster-management-io/policy-collection](https://github.com/open-cluster-management-io/policy-collection)
- [brian-jarvis/bry-acm-policy-samples](https://github.com/brian-jarvis/bry-acm-policy-samples)

This is a **standalone local repository**. Push to your Git remote and update `repoURL` in `argocd/applications/` before syncing to a cluster.

> **For AI agents:** start with [AGENTS.md](AGENTS.md)

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

### Deploy via ArgoCD

```bash
kubectl apply -f argocd/applications/policy-collection-dev.yaml
```

See [argocd/README.md](argocd/README.md) for full deployment guide.

## Repository structure

| Path | Description |
|------|-------------|
| [`policies/`](policies/) | PolicyGenerator projects (primary content) |
| [`environments/`](environments/) | Dev/implt/prod kustomize overlays |
| [`argocd/`](argocd/) | ArgoCD Application manifests |
| [`template-examples/`](template-examples/) | Standalone template patterns |
| [`legacy/`](legacy/) | Deprecated raw Policy YAML (migration source) |
| [`docs/`](docs/) | Architecture, standards, policy catalog |

## Deployment model

| Supported | Not supported |
|-----------|---------------|
| ArgoCD (OpenShift GitOps) | ACM Subscription/Channel |
| PolicyGenerator + Kustomize | PlacementRule (deprecated) |
| Placement API | Application Lifecycle addon |

## Policy organization

Policies are grouped by function:

- **operators/** — OLM operator installation via OperatorPolicy
- **cluster-configs/** — OpenShift cluster configuration
- **acm-configs/** — ACM hub and spoke settings
- **security/** — CVE mitigations and security controls
- **policy-sets/** — Opt-in bundles (OpenShift Plus, Gatekeeper, Kyverno)

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

## Community

See [CONTRIBUTING.md](CONTRIBUTING.md) for contribution guidelines.
