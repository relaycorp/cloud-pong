resource "google_secret_manager_secret" "main" {
  secret_id = var.secret_id

  replication {
    automatic = true
  }

  labels = var.gcp_labels
}

resource "google_secret_manager_secret_version" "main" {
  secret      = google_secret_manager_secret.main.id
  secret_data = var.secret_value
}

resource "google_secret_manager_secret_iam_binding" "main" {
  secret_id = google_secret_manager_secret.main.secret_id
  role      = "roles/secretmanager.secretAccessor"
  members   = ["serviceAccount:${var.accessor_service_account_email}"]
}
