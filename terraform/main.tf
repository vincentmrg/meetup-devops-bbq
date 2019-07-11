provider "google" {}

provider "google-beta" {}

provider "random" {}

# The LivingPackets organization remote state
data "terraform_remote_state" "organization" {
  backend = "gcs"

  config {
    bucket = "my-terraform-bucket"
    prefix = "organization/state"
  }
}

# meetup_bbq project
resource "google_project" "meetup_bbq" {
  project_id          = "${var.project_id}"
  name                = "${var.project_id}"
  folder_id           = "${data.terraform_remote_state.organization.folder_name}"
  billing_account     = "${data.terraform_remote_state.organization.billing_account_id}"
  auto_create_network = false
}
