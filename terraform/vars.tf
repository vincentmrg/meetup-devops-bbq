# The GCP project identifier.
variable "project_id" {
}

# The region to use for regional resources.
variable "region" {
}

# The Kubernetes cluster name.
variable "gke_cluster_name" {
}

# The Kubernetes cluster zone.
variable "gke_cluster_zone" {
}

# The Kubernetes instance type.
variable "gke_instance_type" {
}

# An ip authorized on the gke master.
variable "master_auth_ip" {
}

# A prefix for buckets names (Every bucket name must be unique).
variable "buckets_prefix" {
}

# The CloudSQL database version (postgreSQL).
variable "database_version" {
}

# The CloudSQL database tier.
variable "database_tier" {
}

# The Cloudflare account email.
variable "cf_email" {
}

# The Cloudflare account token.
variable "cf_token" {
}

# The gitlab host.
variable "gitlab_host" {
}

# The gitlab's container registry host.
variable "registry_host" {
}

# The gitlab's domain.
variable "domain" {
}

