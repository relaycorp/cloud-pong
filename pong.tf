resource "google_service_account" "pong" {
  project = var.gcp_project_id

  account_id   = "awala-pong"
  display_name = "Awala Pong"
}

resource "google_cloud_run_v2_service" "pong" {
  project  = var.gcp_project_id
  location = var.gcp_region

  name    = "awala-pong"
  ingress = "INGRESS_TRAFFIC_INTERNAL_ONLY"

  template {
    timeout = "300s"

    service_account = google_service_account.pong.email

    execution_environment = "EXECUTION_ENVIRONMENT_GEN2"

    max_instance_request_concurrency = 100

    containers {
      name  = "pong"
      image = "relaycorp/awala-pong:${var.pong_version}"

      env {
        name  = "VERSION"
        value = var.pong_version
      }

      env {
        name  = "LOG_LEVEL"
        value = "info"
      }
      env {
        name  = "LOG_TARGET"
        value = "gcp"
      }

      env {
        name  = "REQUEST_ID_HEADER"
        value = "X-Cloud-Trace-Context"
      }

      env {
        name  = "CE_TRANSPORT"
        value = "google-pubsub"
      }
      env {
        name  = "CE_CHANNEL"
        value = module.endpoint.pubsub_topics.outgoing_messages
      }

      resources {
        startup_cpu_boost = true
        cpu_idle          = false

        limits = {
          cpu    = 1
          memory = "512Mi"
        }
      }

      startup_probe {
        initial_delay_seconds = 3
        failure_threshold     = 3
        period_seconds        = 10
        timeout_seconds       = 3
        http_get {
          path = "/"
          port = 8080
        }
      }

      liveness_probe {
        initial_delay_seconds = 0
        failure_threshold     = 3
        period_seconds        = 20
        timeout_seconds       = 3
        http_get {
          path = "/"
          port = 8080
        }
      }
    }

    scaling {
      min_instance_count = 0
      max_instance_count = 3
    }
  }
}

resource "google_cloud_run_v2_job_iam_binding" "endpoint_bootstrap_invoker" {
  project = var.gcp_project_id

  location = var.gcp_region
  name     = module.endpoint.bootstrap_job_name
  role     = "roles/run.invoker"
  members  = [var.sre_iam_uri]
}
