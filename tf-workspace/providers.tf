provider "google" {
  project = var.gcp_project_id
}

provider "google-beta" {
  project = var.gcp_project_id
}
