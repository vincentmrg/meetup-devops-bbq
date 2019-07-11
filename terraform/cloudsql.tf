# The Postgre instance used by gitlab.
resource "google_sql_database_instance" "gitlab" {
  name             = "gitlab-postgres-instance"
  project          = "${google_project.meetup_bbq.project_id}"
  region           = "${var.region}"
  database_version = "${var.database_version}"

  settings {
    tier = "${var.database_tier}"

    ip_configuration {
      ipv4_enabled    = "false"
      private_network = "${google_compute_network.meetup_bbq.self_link}"
    }

    maintenance_window {
      // on saturday
      day = "6"

      // at 2 on the morning
      hour = "2"

      // only stable version
      update_track = "stable"
    }
  }

  depends_on = ["google_service_networking_connection.meetup_bbq_cloud_peering"]
}

# The Postgre database used by gitlab.
resource "google_sql_database" "gitlab_database" {
  project = "${google_project.meetup_bbq.project_id}"

  # Same name as user for psql cli connection
  name       = "gitlabhq_production"
  instance   = "${google_sql_database_instance.gitlab.name}"
  depends_on = ["google_sql_database_instance.gitlab"]
  charset    = "UTF8"
}

# # The gitlab's user password random generator.
resource "random_string" "gitlab_password" {
  length = 16

  # This password is decoded and put in a gitlab's yaml configuration without quotes.
  special = false
}

# # The gitlab's database user.
resource "google_sql_user" "gitlab_user" {
  # Same name as database for psql cli connection
  name     = "gitlab"
  project  = "${google_project.meetup_bbq.project_id}"
  instance = "${google_sql_database_instance.gitlab.name}"
  password = "${random_string.gitlab_password.result}"

  lifecycle {
    ignore_changes = ["password"]
  }
}

# # The DNS of the Postgre instance
resource "google_dns_record_set" "gitlab_instance" {
  name         = "db.gitlab.${google_dns_managed_zone.meetup_bbq_private_zone.dns_name}"
  project      = "${google_project.meetup_bbq.project_id}"
  type         = "A"
  ttl          = 300
  managed_zone = "${google_dns_managed_zone.meetup_bbq_private_zone.name}"
  rrdatas      = ["${google_sql_database_instance.gitlab.private_ip_address}"]
}
