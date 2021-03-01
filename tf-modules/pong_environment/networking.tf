resource "google_compute_network" "main" {
  name = local.env_full_name
}

resource "google_compute_global_address" "managed_tls_cert" {
  name = local.env_full_name

  labels = local.gcp_resource_labels

  provider = google-beta
}
