resource "google_compute_global_address" "redis" {
  name          = "${local.env_full_name}-redis"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.main.id

  labels = local.gcp_resource_labels
}

resource "google_service_networking_connection" "redis" {
  network                 = google_compute_network.main.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.redis.name]
}

resource "google_redis_instance" "main" {
  name           = local.env_full_name
  tier           = "BASIC"
  memory_size_gb = 1

  location_id = local.gcp_zone

  authorized_network = google_compute_network.main.id
  connect_mode       = "PRIVATE_SERVICE_ACCESS"

  redis_version = "REDIS_4_0"
  display_name  = "Terraform Test Instance"

  depends_on = [google_service_networking_connection.redis]
}
