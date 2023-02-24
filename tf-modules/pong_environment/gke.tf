resource "google_container_cluster" "main" {
  name = local.env_full_name

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  min_master_version = var.gke_min_version
  release_channel {
    channel = "STABLE"
  }

  maintenance_policy {
    recurring_window {
      # Only do maintenance in the mornings (UK time).
      start_time = "2020-12-01T08:00:00Z"
      end_time   = "2020-12-01T12:00:00Z"
      recurrence = "FREQ=WEEKLY;BYDAY=MO,TU,WE,TH,FR"
    }
  }

  master_auth {
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = false
    }
  }

  # Make cluster VPC-native (alias IP) so we can connect to GCP services
  ip_allocation_policy {}

  network = google_compute_network.main.self_link

  location = local.gcp_zone

  resource_labels = local.gcp_resource_labels

  provider = google-beta
}

resource "random_id" "gke_node_pool_suffix" {
  byte_length = 3
}

resource "google_container_node_pool" "main" {
  name       = "${local.env_full_name}-${random_id.gke_node_pool_suffix.hex}"
  location   = google_container_cluster.main.location
  cluster    = google_container_cluster.main.name
  node_count = 1

  image_type = "COS_CONTAINERD"

  version = google_container_cluster.main.master_version

  node_config {
    machine_type = var.gke_instance_type
    disk_size_gb = 10

    metadata = {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    labels = local.gcp_resource_labels
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  upgrade_settings {
    max_surge       = 3
    max_unavailable = 3
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_project_iam_custom_role" "gke_limited_admin" {
  project = var.gcp_project_id

  role_id = "${replace(local.env_full_name, "-", "_")}.gke_limited_admin"
  title   = "Limited permissions to manage the GKE cluster"
  permissions = [
    "container.mutatingWebhookConfigurations.create",
    "container.mutatingWebhookConfigurations.get",
    "container.mutatingWebhookConfigurations.list",
    "container.mutatingWebhookConfigurations.update",
    "container.mutatingWebhookConfigurations.delete",
    "container.clusterRoles.create",
    "container.clusterRoles.get",
    "container.clusterRoles.list",
    "container.clusterRoles.bind",
    "container.clusterRoles.update",
    "container.clusterRoles.delete",
    "container.clusterRoles.escalate",
    "container.clusterRoleBindings.create",
    "container.clusterRoleBindings.get",
    "container.clusterRoleBindings.list",
    "container.clusterRoleBindings.update",
    "container.clusterRoleBindings.delete",
    "container.roleBindings.create",
    "container.roleBindings.get",
    "container.roleBindings.list",
    "container.roleBindings.update",
    "container.roleBindings.delete",
    "container.roles.create",
    "container.roles.get",
    "container.roles.list",
    "container.roles.update",
    "container.roles.delete",
    "container.roles.bind",
    "container.roles.escalate",
  ]
}

resource "google_project_iam_binding" "gke_limited_admin" {
  role = google_project_iam_custom_role.gke_limited_admin.id

  members = ["serviceAccount:${local.gcb_service_account_email}"]

  # TODO: Limit to a single GKE cluster
}
