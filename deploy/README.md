# Deploy Policies via ArgoCD

Deploy consolidated policies using **OpenShift GitOps (ArgoCD)**. Application/Subscription (appsub) deployment is not supported in this repository.

## Prerequisites

- `kubectl` or `oc` CLI logged into the ACM hub
- OpenShift GitOps installed (`openshift-gitops` namespace)
- ArgoCD repo server configured with PolicyGenerator (`--enable-alpha-plugins`)
- Target namespace exists or `CreateNamespace=true` sync option is set

## Quick deploy

```bash
kubectl create ns acm-policies-dev --dry-run=client -o yaml | kubectl apply -f -

kubectl apply -f argocd/applications/policy-collection-dev.yaml
```

## Helper script

```bash
cd deploy
./argoDeploy.sh -u <git-url> -b <branch> -p environments/dev -n acm-policies-dev
```

### Parameters

| Flag | Description | Default |
|------|-------------|---------|
| `-u` | Git repository URL | policy-collection main repo |
| `-b` | Branch or tag | `master` |
| `-p` | Path in repo | `environments/dev` |
| `-n` | Target namespace | `acm-policies-dev` |
| `-a` | Application name | `policy-collection-dev` |
| `--dry-run` | Print YAML only | |

## Environments

| Path | Namespace | ClusterSet |
|------|-----------|------------|
| `environments/dev` | `acm-policies-dev` | `dev-clusters` |
| `environments/implt` | `acm-policies-implt` | `implt-clusters` |
| `environments/prod` | `acm-policies-prod` | `prod-clusters` |

## PolicySets

Deploy PolicySets as separate ArgoCD Applications. See [policies/policy-sets/README.md](../policies/policy-sets/README.md).

## Removed

The following appsub-based deployment files were removed:

- `deploy.sh`, `remove.sh`
- `subscription.yaml`, `channel.yaml`, `application.yaml`
