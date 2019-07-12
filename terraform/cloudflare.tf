# Configure the Cloudflare provider
provider "cloudflare" {
  email = var.cf_email
  token = var.cf_token
}

# The gitlab DNS.
resource "cloudflare_record" "gitlab" {
  domain = var.domain
  name   = var.gitlab_host
  value  = google_compute_address.gitlab_external_address.address
  type   = "A"
}

# The registry DNS.
resource "cloudflare_record" "registry" {
  domain = var.domain
  name   = var.registry_host
  value  = google_compute_address.gitlab_external_address.address
  type   = "A"
}

