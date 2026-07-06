#!/bin/bash
# Validate consolidated policy-collection: legacy YAML, PolicyGenerator standalone, and environment builds.

set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
cd "${ROOT_DIR}"

KUBECONFORM=kubeconform
KC_VERSION=v0.7.0
KUSTOMIZE_VERSION=v5.8.1
GENERATOR_PATH=policy.open-cluster-management.io/v1/policygenerator
KUSTOMIZE_OUTPUT_ROOT=${ROOT_DIR}/bin/.kustomize
SCHEMA_DIR=${ROOT_DIR}/schemas
export POLICY_GEN_ENABLE_HELM=true

export GOBIN=${ROOT_DIR}/bin
export PATH=${GOBIN}:${PATH}
export KUSTOMIZE_PLUGIN_HOME=${GOBIN}
mkdir -p "${GOBIN}"

if [ -z "${GITHUB_REPOSITORY_OWNER:-}" ]; then
	GITHUB_REPOSITORY_OWNER=open-cluster-management-io
fi

validateRawPolicies() {
	if [ -d "$1" ]; then
		echo "Checking raw policies in $1"
		find "${ROOT_DIR}/$1" -name "*.yaml" -exec "${KUBECONFORM}" \
			-schema-location "${SCHEMA_DIR}/{{ .ResourceKind }}_{{ .ResourceAPIVersion }}.json" \
			-summary {} +
	fi
}

validatePolicyGeneratorDir() {
	local setpath="$1"
	local abs_setpath="${ROOT_DIR}/${setpath}"
	for kst in $(find "${abs_setpath}" -name "kustomization.y*ml"); do
		project=$(dirname "${kst#${abs_setpath}/}")
		if grep -q "skip_validation: true" "${kst}" 2>/dev/null; then
			echo "Skipping validation for ${kst}"
			continue
		fi
		echo "Generating policies: ${setpath}/${project}"
		local output="${KUSTOMIZE_OUTPUT_ROOT}/${setpath}/${project}/kbout.yml"
		mkdir -p "$(dirname "${output}")"
		(
			cd "${abs_setpath}/${project}"
			kustomize build --enable-alpha-plugins --enable-helm >"${output}"
		)
		if [ -d "${SCHEMA_DIR}" ]; then
			"${KUBECONFORM}" \
				-schema-location "${SCHEMA_DIR}/{{ .ResourceKind }}_{{ .ResourceAPIVersion }}.json" \
				-schema-location default \
				-ignore-missing-schemas \
				-summary "${output}" || true
		fi
	done
}

installTools() {
	echo "::group::Installing kubeconform"
	go install "github.com/yannh/kubeconform/cmd/kubeconform@${KC_VERSION}"
	echo "::endgroup::"

	if [ ! -d "${SCHEMA_DIR}" ]; then
		mkdir "${SCHEMA_DIR}"
		cd "${SCHEMA_DIR}"
		curl -s -o crd-schema.py "https://raw.githubusercontent.com/yannh/${KUBECONFORM}/${KC_VERSION}/scripts/openapi2jsonschema.py"
		chmod a+x crd-schema.py
		./crd-schema.py "https://raw.githubusercontent.com/${GITHUB_REPOSITORY_OWNER}/governance-policy-propagator/main/deploy/crds/policy.open-cluster-management.io_placementbindings.yaml"
		./crd-schema.py "https://raw.githubusercontent.com/${GITHUB_REPOSITORY_OWNER}/governance-policy-propagator/main/deploy/crds/policy.open-cluster-management.io_policies.yaml"
		./crd-schema.py "https://raw.githubusercontent.com/${GITHUB_REPOSITORY_OWNER}/governance-policy-propagator/main/deploy/crds/policy.open-cluster-management.io_policysets.yaml"
		./crd-schema.py "https://raw.githubusercontent.com/${GITHUB_REPOSITORY_OWNER}/governance-policy-propagator/main/deploy/crds/policy.open-cluster-management.io_policyautomations.yaml"
		./crd-schema.py "https://raw.githubusercontent.com/${GITHUB_REPOSITORY_OWNER}/placement/main/deploy/hub/0000_02_clusters.open-cluster-management.io_placements.crd.yaml"
		./crd-schema.py "https://raw.githubusercontent.com/${GITHUB_REPOSITORY_OWNER}/placement/main/deploy/hub/0000_00_clusters.open-cluster-management.io_managedclusters.crd.yaml"
		./crd-schema.py "https://raw.githubusercontent.com/${GITHUB_REPOSITORY_OWNER}/placement/main/deploy/hub/0000_00_clusters.open-cluster-management.io_managedclustersets.crd.yaml"
		./crd-schema.py "https://raw.githubusercontent.com/${GITHUB_REPOSITORY_OWNER}/placement/main/deploy/hub/0000_01_clusters.open-cluster-management.io_managedclustersetbindings.crd.yaml"
		cd "${ROOT_DIR}"
	fi

	echo "::group::Installing kustomize"
	GO111MODULE=on go install "sigs.k8s.io/kustomize/kustomize/v5@${KUSTOMIZE_VERSION}"
	echo "::endgroup::"

	echo "::group::Installing PolicyGenerator"
	GOBIN="${KUSTOMIZE_PLUGIN_HOME}/${GENERATOR_PATH}" \
		go install open-cluster-management.io/policy-generator-plugin/cmd/PolicyGenerator@latest
	echo "::endgroup::"
}

installTools

echo "=== Legacy raw policies ==="
validateRawPolicies legacy/stable
validateRawPolicies legacy/community

echo "=== PolicyGenerator standalone (policies/) ==="
validatePolicyGeneratorDir policies

echo "=== PolicyGenerator standalone (template-examples/) ==="
validatePolicyGeneratorDir template-examples

echo "=== PolicyGenerator standalone (policy-sets/) ==="
validatePolicyGeneratorDir policies/policy-sets/stable
validatePolicyGeneratorDir policies/policy-sets/community

echo "=== Environment builds (ArgoCD paths) ==="
validatePolicyGeneratorDir environments

echo "=== PolicyGenerator examples ==="
validatePolicyGeneratorDir policies/examples

rm -rf "${SCHEMA_DIR}" "${KUSTOMIZE_OUTPUT_ROOT}"
echo "Validation complete."
