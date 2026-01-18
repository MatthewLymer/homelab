resource "google_storage_bucket" "music" {
  name          = "music-backups-${data.google_project.default.number}"
  location      = "us-central1"
  storage_class = "COLDLINE"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      num_newer_versions = 3 # Keep up to 3 noncurrent versions (total of 4 versions including the live one)
    }
  }
}

resource "google_service_account" "music_backup" {
  account_id   = "onprem-tn-music-backup"
  display_name = "Truenas Music Backup Manager"
}

# resource "google_project_iam_member" "qnap_backup_manager_browser" {
#   project = local.project.id
#   role = "roles/browser"
#   member  = "serviceAccount:${google_service_account.qnap_backup_manager.email}"
# }

resource "google_project_iam_custom_role" "music_backup" {
  role_id = "tn_music_backup"
  title   = "Truenas Music Backup Manager"
  permissions = [
    # "storage.buckets.get",
    "storage.buckets.list",
    # "storage.buckets.update"
  ]
}

resource "google_project_iam_member" "music_backup" {
  project = local.project.id
  role    = google_project_iam_custom_role.music_backup.id
  member  = "serviceAccount:${google_service_account.music_backup.email}"
}

resource "google_storage_bucket_iam_member" "music_backup_object_admin" {
  bucket = google_storage_bucket.music.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.music_backup.email}"
}
