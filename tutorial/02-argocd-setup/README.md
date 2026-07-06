# 02 — Setup ArgoCD with PolicyGenerator

ArgoCD must invoke Kustomize with the PolicyGenerator plugin so `generator.yml` is expanded at sync time.

Pattern adapted from [gatekeeper-examples/setupgitops](https://github.com/ch-stark/gatekeeper-examples/tree/main/setupgitops).

## Components

| File | Kind | Purpose |
|------|------|---------|
| `argocd-instance.yml` | `ArgoCD` | Enables `--enable-alpha-plugins`, mounts PolicyGenerator binary |
| `argocd-application.yml` | `Application` | Syncs this `tutorial/` directory to the hub |

## Key settings

```yaml
spec:
  kustomizeBuildOptions: --enable-alpha-plugins
  repo:
    env:
      - name: KUSTOMIZE_PLUGIN_HOME
        value: /etc/kustomize/plugin
```

The initContainer copies `PolicyGenerator` from the ACM subscription image into the repo-server plugin path (same approach as `policies/operators/gitops/argocd-policygenerator.yml`).

## Apply order

1. Ensure `openshift-gitops` namespace exists (OpenShift GitOps operator)
2. Apply `argocd-instance.yml` to create/configure the ArgoCD instance
3. Update `repoURL` in `argocd-application.yml` to your git server (local tutorial: use a file server or skip until you have a remote)
4. Apply `argocd-application.yml`

## Verify

```bash
oc get argocd -n openshift-gitops
oc get application -n openshift-gitops
```

## Note

This tutorial repo is **local-only**. The Application manifest uses a placeholder `repoURL`. For cluster sync, point it at wherever you host this directory.
