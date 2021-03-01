locals {
  env_full_name = "pong-${var.name}"

  gcp_zone = "${var.gcp_region}-a"

  gcp_resource_labels = {
    environment = var.name
  }
}
