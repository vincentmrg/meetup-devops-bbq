# The The Meetup BBQ network.
resource "google_compute_network" "meetup_bbq" {
  name                    = "meetup-bbq"
  description             = "The Meetup BBQ network."
  project                 = "${google_project.meetup_bbq.project_id}"
  auto_create_subnetworks = false
}

# The Meetup BBQ private subnet.
resource "google_compute_subnetwork" "meetup_bbq_private" {
  name          = "private"
  project       = "${google_project.meetup_bbq.project_id}"
  network       = "${google_compute_network.meetup_bbq.self_link}"
  region        = "${var.region}"
  ip_cidr_range = "192.168.0.0/20"

  # The IP range used for gitlab cluster pods.
  secondary_ip_range {
    range_name    = "meetup-bbq-gitlab-cluster-pods"
    ip_cidr_range = "10.0.0.0/16"
  }

  # The IP range used for gitlab cluster services.
  secondary_ip_range {
    range_name    = "meetup-bbq-gitlab-cluster-services"
    ip_cidr_range = "10.1.0.0/16"
  }

  private_ip_google_access = true
}

# A router for meetup-bbq.
resource "google_compute_router" "meetup_bbq" {
  name    = "meetup-bbq"
  project = "${google_project.meetup_bbq.project_id}"
  network = "${google_compute_network.meetup_bbq.self_link}"
  region  = "${var.region}"
}

# The NAT associated to meetup-bbq router.
resource "google_compute_router_nat" "meetup_bbq" {
  name                               = "meetup-bbq-nat"
  project                            = "${google_project.meetup_bbq.project_id}"
  router                             = "${google_compute_router.meetup_bbq.name}"
  region                             = "${var.region}"
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

resource "google_compute_global_address" "meetup_bbq_cloud_private_ip" {
  provider      = "google-beta"
  name          = "meetup-bbq-cloud-private-ip"
  project       = "${google_project.meetup_bbq.project_id}"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = "${google_compute_network.meetup_bbq.self_link}"
}

resource "google_service_networking_connection" "meetup_bbq_cloud_peering" {
  provider = "google-beta"
  network  = "${google_compute_network.meetup_bbq.self_link}"
  service  = "servicenetworking.googleapis.com"

  reserved_peering_ranges = [
    "${google_compute_global_address.meetup_bbq_cloud_private_ip.name}",
  ]
}

resource "google_dns_managed_zone" "meetup_bbq_private_zone" {
  provider = "google-beta"
  name     = "private-zone-${terraform.workspace}"
  project  = "${google_project.meetup_bbq.project_id}"

  dns_name    = "${terraform.workspace}.internal.meetup-bbq."
  description = "Private DNS zone for workspace ${terraform.workspace}"

  visibility = "private"

  private_visibility_config {
    networks {
      network_url = "${google_compute_network.meetup_bbq.self_link}"
    }
  }
}

# The Gitlab external address.
resource "google_compute_address" "gitlab_external_address" {
  name         = "gitlab-external-address"
  project      = "${google_project.meetup_bbq.project_id}"
  region       = "${var.region}"
  address_type = "EXTERNAL"
}
