# Legacy Policies (Deprecated)

Raw `Policy` YAML files from the original [policy-collection](https://github.com/open-cluster-management-io/policy-collection) repository.

## Status

**Deprecated.** New contributions must use [PolicyGenerator](../policies/) under `policies/`. These files remain for reference and gradual migration.

## Layout

| Directory | Support level | Format |
|-----------|---------------|--------|
| `stable/` | OCM Policy SIG supported | Raw `Policy` CRs |
| `community/` | Community contributed | Raw `Policy` CRs |
| `3rd-party/` | Third-party supported | Raw `Policy` CRs |

## Migration path

1. Extract manifests from `spec.policy-templates[].objectDefinition`
2. Create a `generator.yml` (PolicyGenerator) in `policies/<category>/<name>/`
3. Add a `kustomization.yaml` with `generators: [./generator.yml]`
4. Add a `README.md` per [policy standards](../docs/policy-standards.md)
5. Remove the legacy file after validation passes

## Deployment

Legacy policies are **not** included in environment builds (`environments/`). Deploy individually or migrate to PolicyGenerator.
