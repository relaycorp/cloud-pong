module "env_main" {
  source = "../tf-modules/pong_environment"

  name = "main"

  pohttp_host_name = "pong-pohttp.awala.services"
  internet_address = "ping.awala.services"

  gcp_project_id = var.gcp_project_id
  gcp_region     = "europe-west2"

  sre_iam_uri = var.sre_iam_uri
}
