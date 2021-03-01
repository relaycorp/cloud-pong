variable "secret_id" {}

variable "secret_value" {}

variable "accessor_service_account_email" {}

variable "gcp_labels" {
  type = object({})
}
