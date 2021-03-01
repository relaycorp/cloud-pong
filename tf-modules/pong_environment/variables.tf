variable "name" {}

variable "pohttp_host_name" {}
variable "public_address" {}

variable "gcp_project_id" {}
variable "gcp_region" {}

variable "gke_min_version" {
  default = "1.17.15"
}
variable "gke_instance_type" {
  default = "n2-standard-2"
}

variable "github_repo" {
  type = object({
    organisation = string
    name         = string
  })

  default = {
    organisation = "relaycorp"
    name         = "cloud-pong"
  }
}

variable "sre_iam_uri" {}
//variable "sre_monitoring_notification_channel" {}
