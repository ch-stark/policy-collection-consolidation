# PolicySets

Official and community PolicySet projects from policy-collection, built with PolicyGenerator.

## Layout

| Directory | Support | Description |
|-----------|---------|-------------|
| `stable/openshift-plus/` | SIG supported | ACS, Compliance, Quay, ODF, Observability stack |
| `stable/acm-hardening/` | SIG supported | ACM hub hardening policies |
| `community/gatekeeper/` | Community | Gatekeeper constraint library |
| `community/kyverno/` | Community | Kyverno policy sets |
| `community/acs-secure/` | Community | ACS secure configuration |
| `community/ocp-best-practices/` | Community | OpenShift best practices |
| `community/openshift-gitops/` | Community | OpenShift GitOps integration |
| `community/openshift-plus-setup/` | Community | OpenShift Plus setup helpers |
| `community/operatorguardrails/` | Community | OLM operator allowlist/denylist audit and VAP warnings ([PR #553](https://github.com/open-cluster-management-io/policy-collection/pull/553)) |

## Usage

PolicySets are **opt-in**. They are not included in the default `policies/kustomization.yaml` environment build because they are large and have specific prerequisites.

### Standalone build

```bash
cd policies/policy-sets/stable/openshift-plus
kustomize build --enable-alpha-plugins
```

### Include in an environment

Add to `environments/<env>/kustomization.yaml`:

```yaml
resources:
  - ../../policies/policy-sets/stable/acm-hardening/
```

### ArgoCD

Create a separate ArgoCD Application pointing at the PolicySet path. See [argocd/README.md](../../argocd/README.md).
