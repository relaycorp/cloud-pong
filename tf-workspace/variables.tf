variable "gcp_project_id" {
  default = "relaycorp-cloud-pong"
}
variable "gcp_service_account_id" {}

variable "sre_iam_uri" {
  description = "GCP IAM URI for an SRE or the SRE group (e.g., 'group:sre-team@acme.com')"
}
variable "sre_monitoring_notification_channel" {
  description = "Cloud Monitoring notification channel for the SRE team"
}
variable "sre_email_addresses" {
  description = "Email address for each SRE at Relaycorp"
  type        = list(string)
}
