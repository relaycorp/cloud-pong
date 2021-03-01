#!/bin/bash
set -o nounset
set -o errexit
set -o pipefail

# Constants and functions

SOURCE_RESOURCES_FILE="$(dirname "${BASH_SOURCE[0]}")/resources.yml"
DESTINATION_RESOURCES_FILE='/tmp/vault.yml'

VAULT_SA_KEY_PATH="../secrets/vault-sa-credentials"

REPLACEABLE_ENV_VARS=(
  'CLOUDSDK_CORE_PROJECT'
  'CLOUDSDK_COMPUTE_REGION'
  'VAULT_KMS_KEY_RING'
  'VAULT_KMS_AUTOUNSEAL_KEY'
  'VAULT_GCS_BUCKET'
  'VAULT_SA_KEY_BASE64'
  'HELM_RELEASE_NAME'
  'HELM_RELEASE_NAMESPACE'
)

replace_env_var() {
  local env_var_name="$1"
  local file_path="$2"

  local env_var_value="${!env_var_name?${env_var_name} is undefined}"

  sed "s/\${${env_var_name}}/${env_var_value}/g" -i "${file_path}"
}

# Main

export HELM_RELEASE_NAME="$1"
export HELM_RELEASE_NAMESPACE="$2"

cp "${SOURCE_RESOURCES_FILE}" "${DESTINATION_RESOURCES_FILE}"
trap "shred -u '${DESTINATION_RESOURCES_FILE}'" INT TERM EXIT

echo -n "Resolving environment variables... "
export VAULT_SA_KEY_BASE64="$(cat "${VAULT_SA_KEY_PATH}")"
for env_var in "${REPLACEABLE_ENV_VARS[@]}"; do
  replace_env_var "${env_var}" "${DESTINATION_RESOURCES_FILE}"
done
echo "Done"

echo "Applying resources..."
kubectl apply --filename="${DESTINATION_RESOURCES_FILE}" --wait
