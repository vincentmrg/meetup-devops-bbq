######################################################################
########################### Gitlab storage ###########################
######################################################################
# Buckets configuration for gitlab external object storage.
# https://docs.gitlab.com/charts/advanced/external-object-storage/index.html

# A service account for gitlab storage.
resource "google_service_account" "gitlab_storage" {
  account_id = "gitlab-storage-account"
  project    = google_project.meetup_bbq.project_id
}

# The gitlab storage service account key.
resource "google_service_account_key" "gitlab" {
  service_account_id = google_service_account.gitlab_storage.name
}

#####################################################################
########################## Gitlab registry ##########################
#####################################################################
# The bucket used to store gitlab registry.
resource "google_storage_bucket" "gitlab_registry" {
  name          = "${var.buckets_prefix}-gitlab-registry"
  location      = var.region
  project       = google_project.meetup_bbq.project_id
  storage_class = "REGIONAL"
}

# The gitlab registry bucket IAM configuration.
resource "google_storage_bucket_iam_binding" "gitlab_registry_storage_objectAdmin" {
  bucket = google_storage_bucket.gitlab_registry.name
  role   = "roles/storage.objectAdmin"

  members = [
    "serviceAccount:${google_service_account.gitlab_storage.email}",
  ]
}

####################################################################
############################ Gitlab lfs ############################
####################################################################
# The bucket used to store gitlab lfs.
resource "google_storage_bucket" "gitlab_lfs" {
  name          = "${var.buckets_prefix}-gitlab-lfs"
  location      = var.region
  project       = google_project.meetup_bbq.project_id
  storage_class = "REGIONAL"
}

# The gitlab lfs bucket IAM configuration.
resource "google_storage_bucket_iam_binding" "gitlab_lfs_storage_objectAdmin" {
  bucket = google_storage_bucket.gitlab_lfs.name
  role   = "roles/storage.objectAdmin"

  members = [
    "serviceAccount:${google_service_account.gitlab_storage.email}",
  ]
}

##################################################################
######################## Gitlab artifacts ########################
##################################################################
# The bucket used to store gitlab artifacts.
resource "google_storage_bucket" "gitlab_artifacts" {
  name          = "${var.buckets_prefix}-gitlab-artifacts"
  location      = var.region
  project       = google_project.meetup_bbq.project_id
  storage_class = "REGIONAL"
}

# The gitlab artifacts bucket IAM configuration.
resource "google_storage_bucket_iam_binding" "gitlab_artifacts_storage_objectAdmin" {
  bucket = google_storage_bucket.gitlab_artifacts.name
  role   = "roles/storage.objectAdmin"

  members = [
    "serviceAccount:${google_service_account.gitlab_storage.email}",
  ]
}

##################################################################
######################### Gitlab uploads #########################
##################################################################
# The bucket used to store gitlab uploads.
resource "google_storage_bucket" "gitlab_uploads" {
  name          = "${var.buckets_prefix}-gitlab-uploads"
  location      = var.region
  project       = google_project.meetup_bbq.project_id
  storage_class = "REGIONAL"
}

# The gitlab uploads bucket IAM configuration.
resource "google_storage_bucket_iam_binding" "gitlab_uploads_storage_objectAdmin" {
  bucket = google_storage_bucket.gitlab_uploads.name
  role   = "roles/storage.objectAdmin"

  members = [
    "serviceAccount:${google_service_account.gitlab_storage.email}",
  ]
}

#################################################################
######################## Gitlab packages ########################
#################################################################
# The bucket used to store gitlab packages.
resource "google_storage_bucket" "gitlab_packages" {
  name          = "${var.buckets_prefix}-gitlab-packages"
  location      = var.region
  project       = google_project.meetup_bbq.project_id
  storage_class = "REGIONAL"
}

# The gitlab packages bucket IAM configuration.
resource "google_storage_bucket_iam_binding" "gitlab_packages_storage_objectAdmin" {
  bucket = google_storage_bucket.gitlab_packages.name
  role   = "roles/storage.objectAdmin"

  members = [
    "serviceAccount:${google_service_account.gitlab_storage.email}",
  ]
}

################################################################
##################### Gitlab externaldiffs #####################
################################################################
# The bucket used to store gitlab externaldiffs.
resource "google_storage_bucket" "gitlab_externaldiffs" {
  name          = "${var.buckets_prefix}-gitlab-externaldiffs"
  location      = var.region
  project       = google_project.meetup_bbq.project_id
  storage_class = "REGIONAL"
}

# The gitlab externaldiffs bucket IAM configuration.
resource "google_storage_bucket_iam_binding" "gitlab_externaldiffs_storage_objectAdmin" {
  bucket = google_storage_bucket.gitlab_externaldiffs.name
  role   = "roles/storage.objectAdmin"

  members = [
    "serviceAccount:${google_service_account.gitlab_storage.email}",
  ]
}

################################################################
##################### Gitlab pseudonymizer #####################
################################################################
# The bucket used to store gitlab pseudonymizer.
resource "google_storage_bucket" "gitlab_pseudonymizer" {
  name          = "${var.buckets_prefix}-gitlab-pseudonymizer"
  location      = var.region
  project       = google_project.meetup_bbq.project_id
  storage_class = "REGIONAL"
}

# The gitlab pseudonymizer bucket IAM configuration.
resource "google_storage_bucket_iam_binding" "gitlab_pseudonymizer_storage_objectAdmin" {
  bucket = google_storage_bucket.gitlab_pseudonymizer.name
  role   = "roles/storage.objectAdmin"

  members = [
    "serviceAccount:${google_service_account.gitlab_storage.email}",
  ]
}

###############################################################
######################## Gitlab backup ########################
###############################################################
# The bucket used to store gitlab backup.
resource "google_storage_bucket" "gitlab_backup" {
  name          = "${var.buckets_prefix}-gitlab-backup"
  location      = var.region
  project       = google_project.meetup_bbq.project_id
  storage_class = "REGIONAL"
}

# The gitlab backup bucket IAM configuration.
resource "google_storage_bucket_iam_binding" "gitlab_backup_storage_objectAdmin" {
  bucket = google_storage_bucket.gitlab_backup.name
  role   = "roles/storage.objectAdmin"

  members = [
    "serviceAccount:${google_service_account.gitlab_storage.email}",
  ]
}

###################################################################
######################## Gitlab backup-tmp ########################
###################################################################
# The bucket used to store gitlab backup-tmp.
resource "google_storage_bucket" "gitlab_backup_tmp" {
  name          = "${var.buckets_prefix}-gitlab-backup-tmp"
  location      = var.region
  project       = google_project.meetup_bbq.project_id
  storage_class = "REGIONAL"
}

# The gitlab backup-tmp bucket IAM configuration.
resource "google_storage_bucket_iam_binding" "gitlab_backup_tmp_storage_objectAdmin" {
  bucket = google_storage_bucket.gitlab_backup_tmp.name
  role   = "roles/storage.objectAdmin"

  members = [
    "serviceAccount:${google_service_account.gitlab_storage.email}",
  ]
}

