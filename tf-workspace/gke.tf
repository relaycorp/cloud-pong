resource "google_project_iam_binding" "gke_developers" {
  role    = "roles/container.developer"
  members = [var.sre_iam_uri, "serviceAccount:${local.gcb_service_account_email}"]
}
