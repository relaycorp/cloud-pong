resource "google_billing_budget" "main" {
  billing_account = var.gcp_billing_account_id
  display_name    = "${var.gcp_project_id} (managed by Terraform workspace ${terraform.workspace})"

  budget_filter {
    projects = [data.google_project.current.id]
  }

  amount {
    specified_amount {
      units         = "100"
      currency_code = "USD"
    }
  }

  threshold_rules {
    threshold_percent = 0.9
  }
  threshold_rules {
    threshold_percent = 1.0
    spend_basis       = "FORECASTED_SPEND"
  }

  all_updates_rule {
    monitoring_notification_channels = [for channel in google_monitoring_notification_channel.sres_email : channel.name]
    disable_default_iam_recipients   = true
  }

  depends_on = [google_project_service.services]
}
