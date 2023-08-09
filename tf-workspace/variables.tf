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
variable "internet_address" {
  default = "ping.awala.services"
}
variable "pohttp_server_domain" {
  default = "pong-pohttp.awala.services"
}

variable "pong_instance_name" {
  default = "pong"
}
variable "pong_version" {
  default     = "4.0.4"
  description = "Docker image tag for Awala Pong"
}

variable "sre_iam_uri" {
  description = "GCP IAM URI for an SRE or the SRE group (e.g., 'group:sre-team@acme.com')"
}
variable "sre_email_addresses" {
  description = "Email address for each SRE at Relaycorp"
  type        = list(string)
}
