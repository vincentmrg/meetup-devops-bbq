provider "google" {
  version = "~> 2.9"
}

provider "google-beta" {
  version = "~> 2.9"
}

provider "random" {
  version = "~> 2.1"
}

# The LivingPackets organization remote state
data "terraform_remote_state" "organization" {
  backend = "gcs"

  config = {
    bucket = "my-terraform-bucket"
    prefix = "organization/state"
  }
}

# meetup_bbq project
resource "google_project" "meetup_bbq" {
  project_id          = var.project_id
  name                = var.project_id
  folder_id           = data.terraform_remote_state.organization.outputs.folder_name
  billing_account     = data.terraform_remote_state.organization.outputs.billing_account_id
  auto_create_network = false
}

