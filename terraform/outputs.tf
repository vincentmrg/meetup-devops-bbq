# The gitlab storage service account key.
output "gitlab_storage_service_account_key" {
  value       = google_service_account_key.gitlab.private_key
  description = "The gitlab-storage-account key."
  sensitive   = true
}

# The Gitlab external address.
output "gitlab_external_address" {
  value       = google_compute_address.gitlab_external_address.address
  description = "The Gitlab external address."
}

# The gitlab database instance dns.
output "gitlab_instance_dns_record_name" {
  value = google_dns_record_set.gitlab_instance.name
}

# The gitlab database name.
output "gitlab_database_name" {
  value       = google_sql_database.gitlab_database.name
  description = "The gitlab database name."
}

# The gitlab user name.
output "gitlab_user_name" {
  value       = google_sql_user.gitlab_user.name
  description = "The gitlab user name."
}

# The gitlab database user password.
output "gitlab_user_password" {
  value       = google_sql_user.gitlab_user.password
  description = "The gitlab database user password."
  sensitive   = true
}

# The gitlab bucket used for registry.
output "gitlab_bucket_registry" {
  value       = google_storage_bucket.gitlab_registry.name
  description = "The gitlab bucket used for registry."
}

# The gitlab bucket used for lfs.
output "gitlab_bucket_lfs" {
  value       = google_storage_bucket.gitlab_lfs.name
  description = "The gitlab bucket used for lfs."
}

# The gitlab bucket used for artifacts.
output "gitlab_bucket_artifacts" {
  value       = google_storage_bucket.gitlab_artifacts.name
  description = "The gitlab bucket used for artifacts."
}

# The gitlab bucket used for uploads.
output "gitlab_bucket_uploads" {
  value       = google_storage_bucket.gitlab_uploads.name
  description = "The gitlab bucket used for uploads."
}

# The gitlab bucket used for packages.
output "gitlab_bucket_packages" {
  value       = google_storage_bucket.gitlab_packages.name
  description = "The gitlab bucket used for packages."
}

# The gitlab bucket used for externaldiffs.
output "gitlab_bucket_externaldiffs" {
  value       = google_storage_bucket.gitlab_externaldiffs.name
  description = "The gitlab bucket used for externaldiffs."
}

# The gitlab bucket used for pseudonymizer.
output "gitlab_bucket_pseudonymizer" {
  value       = google_storage_bucket.gitlab_pseudonymizer.name
  description = "The gitlab bucket used for pseudonymizer."
}

# The gitlab bucket used for backup.
output "gitlab_bucket_backup" {
  value       = google_storage_bucket.gitlab_backup.name
  description = "The gitlab bucket used for backup."
}

# The gitlab bucket used for backup-tmp.
output "gitlab_bucket_backup_tmp" {
  value       = google_storage_bucket.gitlab_backup_tmp.name
  description = "The gitlab bucket used for backup-tmp."
}

# The gitlab storage service account email.
output "storage_sa_email" {
  value       = google_service_account.gitlab_storage.email
  description = "The gitlab storage service account email."
}

