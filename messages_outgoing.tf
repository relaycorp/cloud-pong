resource "google_pubsub_topic_iam_binding" "outgoing_messages_publisher" {
  project = var.gcp_project_id

  topic   = module.endpoint.pubsub_topics.outgoing_messages
  role    = "roles/pubsub.publisher"
  members = ["serviceAccount:${google_service_account.pong.email}", ]
}
