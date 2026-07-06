# CLAUDE.md

This file provides guidance to Claude Code when working with code in this repository.

## Repository Overview

Consolidated ACM governance policies from **policy-collection** and **bry-acm-policy-samples**. All new policies use **PolicyGenerator**; deployment is **ArgoCD only** (no Application/Subscription).

**Start here:** [AGENTS.md](AGENTS.md)

## Repository Structure

```
policies/              # PRIMARY — PolicyGenerator projects
environments/          # dev/implt/prod kustomize overlays (ArgoCD source paths)
argocd/                # ArgoCD Application manifests
kustomize-configs/     # Shared transformers
template-examples/     # Standalone template patterns
legacy/                # DEPRECATED raw Policy YAML (stable/community/3rd-party)
docs/                  # Architecture, standards, policy catalog
```

### Policy domains (`policies/`)

- `operators/` — OperatorPolicy (OLM operator installs)
- `cluster-configs/` — OpenShift cluster configuration
- `acm-configs/` — ACM hub/spoke settings
- `security/` — CVE mitigations
- `policy-sets/` — Opt-in bundles (openshift-plus, gatekeeper, kyverno)
- `examples/kustomize/` — Minimal PolicyGenerator tutorial

## PolicyGenerator

- Manifest: `generator.yml` (apiVersion: `policy.open-cluster-management.io/v1`, kind: `PolicyGenerator`)
- Build: `kustomize build --enable-alpha-plugins`
- Default namespace: `acm-policies` (overridden per environment)
- Plugin install: `go install open-cluster-management.io/policy-generator-plugin/cmd/PolicyGenerator@latest`

## ArgoCD Deployment

```bash
kubectl apply -f argocd/applications/policy-collection-dev.yaml
```

ArgoCD requires `kustomizeBuildOptions: --enable-alpha-plugins`. See `policies/operators/gitops/argocd-policygenerator.yml`.

## Validation

```bash
./build/validate-policies.sh   # PolicyGenerator standalone + environment builds + legacy YAML
./build/lint.sh                # yamllint + template-resolver
```

## Key Rules

1. Never add raw `Policy` CRs outside `legacy/`
2. Never create Subscription/Channel/Application (appsub) resources
3. Use `Placement` API, not deprecated `PlacementRule`
4. Every policy directory needs `generator.yml`, `kustomization.yaml`, `README.md`
5. YAML must start with `---`, no trailing whitespace

## Legacy Content

`legacy/stable/`, `legacy/community/`, `legacy/3rd-party/` — migrate to `policies/` over time.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) and [docs/policy-prerequisites.md](docs/policy-prerequisites.md).
