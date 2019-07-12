# gcloud services activation list
resource "google_project_services" "meetup_bbq" {
  project = google_project.meetup_bbq.project_id

  services = [
    "pubsub.googleapis.com",
    "oslogin.googleapis.com",
    "compute.googleapis.com",
    "bigquery-json.googleapis.com",
    "servicenetworking.googleapis.com",
    "dns.googleapis.com",
    "iam.googleapis.com",
    "containerregistry.googleapis.com",
    "iamcredentials.googleapis.com",
    "container.googleapis.com",
    "storage-api.googleapis.com",
  ]
}

