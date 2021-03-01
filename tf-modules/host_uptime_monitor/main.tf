resource "google_monitoring_uptime_check_config" "main" {
  display_name = var.name
  timeout      = "5s"
  period       = "300s"

  http_check {
    port         = "443"
    use_ssl      = true
    validate_ssl = true
  }

  monitored_resource {
    type = "uptime_url"
    labels = {
      project_id = var.gcp_project_id
      host       = trimsuffix(var.host_name, ".")
    }
  }
}

resource "google_monitoring_alert_policy" "uptime" {
  display_name = "${var.name}-uptime"
  combiner     = "OR"
  conditions {
    display_name = "Uptime health check"
    condition_threshold {
      filter          = "metric.type=\"monitoring.googleapis.com/uptime_check/check_passed\" resource.type=\"uptime_url\" metric.label.\"check_id\"=\"${basename(google_monitoring_uptime_check_config.main.id)}\""
      duration        = "60s"
      comparison      = "COMPARISON_GT"
      threshold_value = 1.0
      trigger {
        count = 1
      }
      aggregations {
        alignment_period     = "300s"
        cross_series_reducer = "REDUCE_COUNT_FALSE"
        group_by_fields      = ["resource.*"]
        per_series_aligner   = "ALIGN_NEXT_OLDER"
      }
    }
  }

  notification_channels = [
    var.notification_channel
  ]
}
