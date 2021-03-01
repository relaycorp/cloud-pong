output "secret_id" {
  value = var.secret_id
}

output "secret_version" {
  value = google_secret_manager_secret_version.main.id
}
