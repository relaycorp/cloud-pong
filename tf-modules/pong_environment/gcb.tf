locals {
  gcb_service_account_email = "${data.google_project.main.number}@cloudbuild.gserviceaccount.com"

  gcb_gcloud_image = "gcr.io/google.com/cloudsdktool/cloud-sdk:319.0.0-slim"

  gcb = {
    secret_retrieval_env = [
      "VAULT_SA_CREDENTIALS_SECRET_VERSION=${module.vault_sa_private_key.secret_version}",
      "VAULT_ROOT_TOKEN_SECRET_ID=${google_secret_manager_secret.vault_root_token.secret_id}",
    ]

    helmfile_env = [
      "CLOUDSDK_CORE_PROJECT=${var.gcp_project_id}",
      "CLOUDSDK_COMPUTE_REGION=${var.gcp_region}",

      "ENVIRONMENT_NAME=${var.name}",

      "REDIS_HOST=${google_redis_instance.main.host}",

      "VAULT_KMS_KEY_RING=${google_kms_key_ring.main.name}",
      "VAULT_KMS_AUTOUNSEAL_KEY=${google_kms_crypto_key.vault_auto_unseal.name}",
      "VAULT_GCS_BUCKET=${google_storage_bucket.vault.name}",
      "VAULT_KEYBASE_USERNAME=${local.vault.keybase_username}",
      "VAULT_KV_PREFIX=${local.vault.kv_prefix}",
      "VAULT_ROOT_TOKEN_SECRET_ID=${google_secret_manager_secret.vault_root_token.secret_id}",

      "PONG_INTERNET_ADDRESS=${var.internet_address}",
      "PONG_POHTTP_HOST_NAME=${var.pohttp_host_name}",
      "PONG_GLOBAL_IP_NAME=${google_compute_global_address.managed_tls_cert.name}",
      "PONG_MANAGED_CERT_NAME=${local.env_full_name}",
    ]
  }
}

resource "google_cloudbuild_trigger" "gke_deployment" {
  name        = "${local.env_full_name}-gke-deployment"
  description = "Deploy and configure Kubernetes resources in environment ${var.name}"

  github {
    owner = var.github_repo.organisation
    name  = var.github_repo.name
    push {
      branch = "^main$"
    }
  }

  included_files = ["charts/**"]
  ignored_files  = []

  build {
    step {
      id = "cluster-credentials-retrieval"

      name = local.gcb_gcloud_image
      args = [
        "gcloud",
        "container",
        "clusters",
        "get-credentials",
        google_container_cluster.main.name,
        "--zone",
        local.gcp_zone,
      ]
      env = [
        "CLOUDSDK_CORE_PROJECT=${var.gcp_project_id}",
      ]
    }

    step {
      id       = "secrets-retrieval"
      wait_for = ["cluster-credentials-retrieval"]

      name       = local.gcb_gcloud_image
      entrypoint = "bash"
      args       = ["charts/scripts/retrieve-secrets.sh"]
      env        = local.gcb.secret_retrieval_env
    }

    step {
      id       = "helmfile-backing-services-apply"
      wait_for = ["secrets-retrieval"]

      name       = "gcr.io/$PROJECT_ID/helmfile"
      dir        = "charts"
      entrypoint = "scripts/helmfile.sh"
      args       = ["--selector", "tier=backingService", "apply"]
      env        = local.gcb.helmfile_env
    }

    step {
      id       = "helmfile-apply"
      wait_for = ["helmfile-backing-services-apply"]

      name       = "gcr.io/$PROJECT_ID/helmfile"
      dir        = "charts"
      entrypoint = "scripts/helmfile.sh"
      args       = ["--selector", "tier!=backingService", "apply"]
      env        = local.gcb.helmfile_env
    }

    logs_bucket = "gs://${google_storage_bucket.gcb_build_logs.name}/main"
  }

  tags = [var.name]

  provider = google-beta
}

resource "google_cloudbuild_trigger" "gke_deployment_preview" {
  // This trigger should ideally be run with a limited service account. See:
  // https://issuetracker.google.com/issues/175097630

  name        = "${local.env_full_name}-gke-deployment-preview"
  description = "Preview a potential deployment to ${var.name}"

  github {
    owner = var.github_repo.organisation
    name  = var.github_repo.name
    pull_request {
      branch = "^main$"

      # NEVER, EVER change this. It prevents PRs from external contributors from being triggered
      # automatically.
      comment_control = "COMMENTS_ENABLED_FOR_EXTERNAL_CONTRIBUTORS_ONLY"
    }
  }

  included_files = ["charts/**"]
  ignored_files  = []

  build {
    step {
      id = "cluster-credentials-retrieval"

      name = local.gcb_gcloud_image
      args = [
        "gcloud",
        "container",
        "clusters",
        "get-credentials",
        google_container_cluster.main.name,
        "--zone",
        local.gcp_zone,
      ]
      env = [
        "CLOUDSDK_CORE_PROJECT=${var.gcp_project_id}",
      ]
    }

    step {
      id       = "secrets-retrieval"
      wait_for = ["cluster-credentials-retrieval"]

      name       = local.gcb_gcloud_image
      entrypoint = "bash"
      args       = ["charts/scripts/retrieve-secrets.sh"]
      env        = local.gcb.secret_retrieval_env
    }

    step {
      id       = "helmfile-diff"
      wait_for = ["secrets-retrieval"]

      name       = "gcr.io/$PROJECT_ID/helmfile"
      dir        = "charts"
      entrypoint = "scripts/helmfile.sh"
      args       = ["diff"]
      env        = local.gcb.helmfile_env
    }

    logs_bucket = "gs://${google_storage_bucket.gcb_build_logs.name}/preview"
  }

  tags = [var.name]

  provider = google-beta
}

resource "google_storage_bucket" "gcb_build_logs" {
  name          = "relaycorp-${local.env_full_name}-gcb-logs"
  storage_class = "REGIONAL"
  location      = upper(var.gcp_region)

  uniform_bucket_level_access = true

  versioning {
    enabled = false
  }

  labels = local.gcp_resource_labels
}

resource "google_storage_bucket_iam_member" "gcb_build_logs" {
  bucket = google_storage_bucket.gcb_build_logs.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${local.gcb_service_account_email}"
}
