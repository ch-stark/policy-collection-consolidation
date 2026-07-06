#!/bin/bash
# Validate PolicyGenerator standalone builds, policy-sets, environments, and tutorial.

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

validatePolicyGeneratorDir() {
	local setpath="$1"
	local abs_setpath="${ROOT_DIR}/${setpath}"
	local failed=0

	for kst in $(find "${abs_setpath}" -name "kustomization.y*ml" | sort); do
		project=$(dirname "${kst#${abs_setpath}/}")
		if [ "${project}" = "." ]; then
			project=""
		fi
		if grep -q "skip_validation: true" "${kst}" 2>/dev/null; then
			echo "Skipping validation for ${kst}"
			continue
		fi
		echo "Generating policies: ${setpath}/${project}"
		local output="${KUSTOMIZE_OUTPUT_ROOT}/${setpath}/${project}/kbout.yml"
		mkdir -p "$(dirname "${output}")"
		if ! (
			cd "${abs_setpath}/${project}"
			kustomize build --enable-alpha-plugins --enable-helm >"${output}"
		); then
			echo "ERROR: kustomize build failed for ${setpath}/${project}"
			failed=1
			continue
		fi
		if [ -d "${SCHEMA_DIR}" ] && [ -s "${output}" ]; then
			if ! "${KUBECONFORM}" \
				-schema-location "${SCHEMA_DIR}/{{ .ResourceKind }}_{{ .ResourceAPIVersion }}.json" \
				-schema-location default \
				-ignore-missing-schemas \
				-summary "${output}"; then
				echo "ERROR: kubeconform failed for ${setpath}/${project}"
				failed=1
			fi
		fi
	done

	return "${failed}"
}

installTools() {
	echo "::group::Installing kubeconform"
	go install "github.com/yannh/kubeconform/cmd/kubeconform@${KC_VERSION}"
	echo "::endgroup::"

	if [ ! -f "${SCHEMA_DIR}/policy_v1.json" ]; then
		rm -rf "${SCHEMA_DIR}"
		mkdir "${SCHEMA_DIR}"
		cd "${SCHEMA_DIR}"
		curl -s -o crd-schema.py "https://raw.githubusercontent.com/yannh/${KUBECONFORM}/${KC_VERSION}/scripts/openapi2jsonschema.py"
		chmod a+x crd-schema.py
		local crds=(
			"https://raw.githubusercontent.com/${GITHUB_REPOSITORY_OWNER}/governance-policy-propagator/main/deploy/crds/policy.open-cluster-management.io_placementbindings.yaml"
			"https://raw.githubusercontent.com/${GITHUB_REPOSITORY_OWNER}/governance-policy-propagator/main/deploy/crds/policy.open-cluster-management.io_policies.yaml"
			"https://raw.githubusercontent.com/${GITHUB_REPOSITORY_OWNER}/governance-policy-propagator/main/deploy/crds/policy.open-cluster-management.io_policysets.yaml"
			"https://raw.githubusercontent.com/${GITHUB_REPOSITORY_OWNER}/governance-policy-propagator/main/deploy/crds/policy.open-cluster-management.io_policyautomations.yaml"
			"https://raw.githubusercontent.com/${GITHUB_REPOSITORY_OWNER}/placement/main/deploy/hub/0000_02_clusters.open-cluster-management.io_placements.crd.yaml"
			"https://raw.githubusercontent.com/${GITHUB_REPOSITORY_OWNER}/placement/main/deploy/hub/0000_00_clusters.open-cluster-management.io_managedclusters.crd.yaml"
			"https://raw.githubusercontent.com/${GITHUB_REPOSITORY_OWNER}/placement/main/deploy/hub/0000_00_clusters.open-cluster-management.io_managedclustersets.crd.yaml"
			"https://raw.githubusercontent.com/${GITHUB_REPOSITORY_OWNER}/placement/main/deploy/hub/0000_01_clusters.open-cluster-management.io_managedclustersetbindings.crd.yaml"
		)
		for crd in "${crds[@]}"; do
			sleep 1
			./crd-schema.py "${crd}"
		done
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

FAILED=0

echo "=== PolicyGenerator standalone (policies/) ==="
validatePolicyGeneratorDir policies || FAILED=1

echo "=== PolicyGenerator standalone (template-examples/) ==="
validatePolicyGeneratorDir template-examples || FAILED=1

echo "=== PolicyGenerator policy-sets (stable/) ==="
validatePolicyGeneratorDir policies/policy-sets/stable || FAILED=1

echo "=== PolicyGenerator policy-sets (community/) ==="
validatePolicyGeneratorDir policies/policy-sets/community || FAILED=1

echo "=== Environment builds (ArgoCD paths) ==="
validatePolicyGeneratorDir environments || FAILED=1

echo "=== PolicyGenerator tutorial ==="
validatePolicyGeneratorDir tutorial || FAILED=1

rm -rf "${SCHEMA_DIR}" "${KUSTOMIZE_OUTPUT_ROOT}"

if [ "${FAILED}" -ne 0 ]; then
	echo "Validation failed."
	exit 1
fi

echo "Validation complete."
