variable "gcp_project_id" {
  default = "relaycorp-cloud-ping"
}
variable "gcp_region" {
    default = "europe-west1" # Belgium
}
variable "gcp_service_account_id" {}

variable "mongodb_atlas_project_id" {}
variable "mongodb_atlas_region" {
  default = "WESTERN_EUROPE" # Belgium
}

variable "backend_name" {
  default = "pong"
}
variable "internet_address" {
  default = "ping.awala.services"
}
variable "pohttp_server_domain" {
  default = "pong-pohttp.awala.services"
}

variable "sre_iam_uri" {
  description = "GCP IAM URI for an SRE or the SRE group (e.g., 'group:sre-team@acme.com')"
}
variable "sre_email_addresses" {
  description = "Email address for each SRE at Relaycorp"
  type        = list(string)
}
