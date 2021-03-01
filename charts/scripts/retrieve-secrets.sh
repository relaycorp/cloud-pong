#!/bin/bash
set -o nounset
set -o errexit
set -o pipefail

# Constants and functions

retrieve_secret_version() {
  local secret_version="$1"

  gcloud secrets versions access "${secret_version}"
}

retrieve_latest_secret_version() {
  local secret_id="$1"

  gcloud secrets versions access latest --secret="${secret_id}"
}

# Main

mkdir secrets
cd secrets
retrieve_secret_version "${VAULT_SA_CREDENTIALS_SECRET_VERSION}" >vault-sa-credentials
retrieve_secret_version "${STAN_DB_PASSWORD_SECRET_VERSION}" >stan-db-password
retrieve_secret_version "${GW_MONGODB_PASSWORD_SECRET_VERSION}" >gw-mongodb-password

if ! retrieve_latest_secret_version "${VAULT_ROOT_TOKEN_SECRET_ID}" >vault-root-token; then
  echo "Could not retrieve Vault root token. Vault may not be initialised yet." >&2
fi
