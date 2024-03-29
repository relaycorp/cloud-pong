locals {
  mongodb_uri = "${mongodbatlas_serverless_instance.main.connection_strings_standard_srv}/?retryWrites=true&w=majority"
}

resource "mongodbatlas_serverless_instance" "main" {
  project_id = var.mongodb_atlas_project_id
  name       = "awala-pong"

  provider_settings_backing_provider_name = "GCP"
  provider_settings_provider_name         = "SERVERLESS"
  provider_settings_region_name           = var.mongodb_atlas_region

  termination_protection_enabled = true
}

resource "mongodbatlas_project_ip_access_list" "main" {
  project_id = var.mongodb_atlas_project_id
  comment    = "See https://github.com/relaycorp/terraform-google-awala-endpoint/issues/2"
  cidr_block = "0.0.0.0/0"
}

resource "mongodbatlas_database_user" "endpoint" {
  project_id = var.mongodb_atlas_project_id

  username           = "awala-endpoint"
  password           = random_password.mongodb_endpoint_user_password.result
  auth_database_name = "admin"

  roles {
    role_name     = "readWrite"
    database_name = local.mongodb_endpoint_db_name
  }
}

resource "random_password" "mongodb_endpoint_user_password" {
  length = 32
}
