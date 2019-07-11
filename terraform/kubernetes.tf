# The gitlab's k8s cluster.
resource "google_container_cluster" "gitlab" {
  name     = "${var.gke_cluster_name}"
  project  = "${google_project.meetup_bbq.project_id}"
  location = "${var.gke_cluster_zone}"

  # Setting an empty username and password explicitly disables basic auth
  master_auth {
    username = ""
    password = ""
  }

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool ...
  initial_node_count = 1

  # ... and immediately delete it.
  remove_default_node_pool = true

  private_cluster_config {
    # Whether the master's internal IP address is used as the cluster endpoint.
    enable_private_endpoint = false

    # Whether nodes have internal IP addresses only.
    enable_private_nodes = true

    # The IP range in CIDR notation to use for the hosted master network.
    master_ipv4_cidr_block = "192.168.16.0/28"
  }

  network    = "${google_compute_network.meetup_bbq.self_link}"
  subnetwork = "${google_compute_subnetwork.meetup_bbq_private.self_link}"

  ip_allocation_policy {
    use_ip_aliases                = true
    cluster_secondary_range_name  = "${google_compute_subnetwork.meetup_bbq_private.secondary_ip_range.0.range_name}"
    services_secondary_range_name = "${google_compute_subnetwork.meetup_bbq_private.secondary_ip_range.1.range_name}"
  }

  addons_config {
    kubernetes_dashboard {
      disabled = true
    }
  }

  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = "${var.master_auth_ip}/32"
      display_name = "master_auth_ip"
    }
  }

  maintenance_policy {
    daily_maintenance_window {
      start_time = "03:00"
    }
  }
}

# The gitlab's k8s main cluster nodepool.
resource "google_container_node_pool" "main" {
  name       = "main"
  project    = "${google_project.meetup_bbq.project_id}"
  location   = "${google_container_cluster.gitlab.location}"
  cluster    = "${google_container_cluster.gitlab.name}"
  node_count = 1

  node_config {
    # 4 vCPU / 15GB ram
    machine_type = "${var.gke_instance_type}"
    preemptible  = false

    oauth_scopes = [
      "https://www.googleapis.com/auth/ndev.clouddns.readwrite",
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_write",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/trace.append",
      "https://www.googleapis.com/auth/sqlservice.admin",
    ]

    labels = {
      main = "true"
    }
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }
}
