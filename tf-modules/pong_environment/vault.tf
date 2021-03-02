locals {
  vault = {
    kv_prefix        = "pong-keys"
    keybase_username = "gnarea"
  }
}

resource "google_service_account" "vault" {
  project    = var.gcp_project_id
  account_id = "${local.env_full_name}-vault"
}

resource "google_service_account_key" "vault" {
  service_account_id = google_service_account.vault.name
}

// Auto-unseal

resource "google_kms_crypto_key" "vault_auto_unseal" {
  name            = "vault-auto-unseal"
  key_ring        = google_kms_key_ring.main.self_link
  rotation_period = "100000s"

  lifecycle {
    prevent_destroy = false
  }
}

resource "google_project_iam_custom_role" "vault_auto_unseal" {
  project = var.gcp_project_id

  role_id     = "${replace(local.env_full_name, "-", "_")}.vault_auto_unseal"
  title       = "Vault auto-unseal"
  permissions = ["cloudkms.cryptoKeys.get"]

  // TODO: Add conditions to restrict it to one keyring
}

resource "google_project_iam_binding" "vault_auto_unseal" {
  role = google_project_iam_custom_role.vault_auto_unseal.id

  members = [
    "serviceAccount:${google_service_account.vault.email}"
  ]
}

data "google_iam_policy" "vault_auto_unseal" {
  binding {
    role    = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
    members = ["serviceAccount:${google_service_account.vault.email}"]
  }
}

resource "google_kms_crypto_key_iam_policy" "crypto_key" {
  crypto_key_id = google_kms_crypto_key.vault_auto_unseal.id
  policy_data   = data.google_iam_policy.vault_auto_unseal.policy_data
}

// GCS storage backend

resource "google_storage_bucket" "vault" {
  name          = "relaycorp-${local.env_full_name}-vault"
  storage_class = "REGIONAL"
  location      = upper(var.gcp_region)

  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }

  labels = local.gcp_resource_labels
}

resource "google_storage_bucket_iam_member" "vault_storage" {
  bucket = google_storage_bucket.vault.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.vault.email}"
}

// TODO: Remove. Only needed to remove objects after a failed `vault init`.
resource "google_storage_bucket_iam_member" "vault_storage_sre" {
  bucket = google_storage_bucket.vault.name
  role   = "roles/storage.objectAdmin"
  member = var.sre_iam_uri
}

module "vault_sa_private_key" {
  source = "../cd_secret"

  secret_id                      = "${local.env_full_name}-vault-sa-private-key"
  secret_value                   = google_service_account_key.vault.private_key
  accessor_service_account_email = local.gcb_service_account_email
  gcp_labels                     = local.gcp_resource_labels
}

resource "google_secret_manager_secret" "vault_root_token" {
  secret_id = "${local.env_full_name}-vault-root-token"

  replication {
    automatic = true
  }

  labels = local.gcp_resource_labels
}

resource "google_secret_manager_secret_iam_binding" "gcb_vault_root_token" {
  secret_id = google_secret_manager_secret.vault_root_token.secret_id
  role      = "roles/secretmanager.admin"
  members   = ["serviceAccount:${local.gcb_service_account_email}"]
}
