resource "google_project_iam_binding" "monitoring_admin_sre" {
  // TODO: Remove
  role    = "roles/monitoring.admin"
  members = [var.sre_iam_uri]
}

resource "google_project_iam_binding" "monitoring_viewer_sre" {
  role    = "roles/monitoring.viewer"
  members = [var.sre_iam_uri]
}

resource "google_project_iam_binding" "dashboard_viewer_sre" {
  role    = "roles/monitoring.dashboardViewer"
  members = [var.sre_iam_uri]
}

resource "google_project_iam_binding" "error_reporting_sre_access" {
  role    = "roles/errorreporting.user"
  members = [var.sre_iam_uri]
}

resource "google_monitoring_group" "main" {
  display_name = local.env_full_name

  filter = "resource.metadata.tag.environment=\"${var.name}\""
}

// TODO: Reinstate
//module "pohttp_lb_uptime" {
//  source = "../host_uptime_monitor"
//
//  name                 = "${local.env_full_name}-pohttp"
//  host_name            = var.pohttp_host_name
//  notification_channel = var.sre_monitoring_notification_channel
//  gcp_project_id       = var.gcp_project_id
//}
