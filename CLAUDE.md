# CLAUDE.md

This file provides guidance to Claude Code when working with code in this repository.

## Repository Overview

Consolidated ACM governance policies for **ACM 2.15+** from **policy-collection** and **bry-acm-policy-samples**. All policies use **PolicyGenerator**; deployment is **ArgoCD** preferred, also supports direct `kustomize build` + `kubectl apply`.

**Start here:** [AGENTS.md](AGENTS.md)

## Repository Structure

```
policies/              # PRIMARY — PolicyGenerator projects
policies/policy-catalog.yaml  # Machine-readable policy index (AI-ready)
environments/          # dev/implt/prod kustomize overlays (ArgoCD source paths)
argocd/                # ArgoCD Application manifests (templates)
kustomize-configs/     # Shared transformers
template-examples/     # Advanced template patterns
tutorial/              # Step-by-step tutorial (7 modules)
docs/                  # Architecture, standards, policy catalog
```

### Policy domains (`policies/`)

- `operators/` — OperatorPolicy (OLM operator installs)
- `cluster-configs/` — OpenShift cluster configuration
- `acm-configs/` — ACM hub/spoke settings
- `cluster-health/` — Cluster health monitoring
- `cluster-maintenance/` — Cluster hygiene and cleanup
- `cluster-version/` — Cluster upgrade management
- `security/` — CVE mitigations
- `gatekeeper/` — Gatekeeper constraint templates
- `third-party/` — Third-party integrations (CyberArk, LogicMonitor, Portworx)
- `virt-management/` — OpenShift Virtualization
- `policy-sets/` — Opt-in bundles (openshift-plus, gatekeeper, kyverno)
- `examples/kustomize/` — Minimal PolicyGenerator example

## PolicyGenerator

- Manifest: `generator.yml` (apiVersion: `policy.open-cluster-management.io/v1`, kind: `PolicyGenerator`)
- Build: `kustomize build --enable-alpha-plugins`
- Default namespace: `acm-policies` (overridden per environment)
- Plugin install: `go install open-cluster-management.io/policy-generator-plugin/cmd/PolicyGenerator@latest`

## ArgoCD Deployment

Update `repoURL` in `argocd/applications/` to point at your git remote, then:

```bash
kubectl apply -f argocd/applications/policy-collection-dev.yaml
```

ArgoCD requires `kustomizeBuildOptions: --enable-alpha-plugins --enable-helm`. See `policies/operators/gitops/argocd-policygenerator.yml`.

## Direct Apply (no ArgoCD)

```bash
cd policies/<category>/<policy-name>
kustomize build --enable-alpha-plugins | kubectl apply -f -
```

## Validation

```bash
./build/validate-policies.sh   # PolicyGenerator standalone + environment builds
./build/lint.sh                # yamllint + template-resolver
```

## Key Rules

1. Never add raw `Policy` CRs — use PolicyGenerator
2. Never create Subscription/Channel/Application (appsub) resources
3. Use `Placement` API, not deprecated `PlacementRule`
4. Every policy directory needs `generator.yml`, `kustomization.yaml`, `README.md`
5. YAML must start with `---`, no trailing whitespace

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) and [docs/policy-prerequisites.md](docs/policy-prerequisites.md).
