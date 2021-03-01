resource "random_id" "kms_key_ring_suffix" {
  byte_length = 3
}

resource "google_kms_key_ring" "main" {
  # Key rings can be deleted from the Terraform state but not GCP, so let's add a suffix in case
  # we need to recreate it.
  project = var.gcp_project_id

  name     = "${local.env_full_name}-${random_id.kms_key_ring_suffix.hex}"
  location = var.gcp_region
}
