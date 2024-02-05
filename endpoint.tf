locals {
  mongodb_endpoint_db_name = "endpoint"
}

module "endpoint" {
  source  = "relaycorp/awala-endpoint/google"
  version = "1.8.29"

  docker_image_tag = "1.8.19"

  backend_name     = var.pong_instance_name
  internet_address = var.internet_address

  project_id = var.gcp_project_id
  region     = var.gcp_region

  pohttp_server_domain = var.pohttp_server_domain

  mongodb_uri      = local.mongodb_uri
  mongodb_db       = local.mongodb_endpoint_db_name
  mongodb_user     = mongodbatlas_database_user.endpoint.username
  mongodb_password = random_password.mongodb_endpoint_user_password.result

  depends_on = [time_sleep.wait_for_services]
}
