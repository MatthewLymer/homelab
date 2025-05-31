resource "google_service_account" "default" {
  account_id   = local.serviceAccount
  display_name = local.serviceAccount
}

resource "google_dns_managed_zone_iam_member" "default_lymer_ca" {
  managed_zone = data.google_dns_managed_zone.lymer_ca.name
  role         = "roles/editor"
  member       = "serviceAccount:${google_service_account.default.email}"
}

resource "google_service_account_key" "default_sa_key" {
  service_account_id = google_service_account.default.name
}

resource "google_secret_manager_secret" "default_sa_key" {
  secret_id = "${local.serviceAccount}_sa_key"

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "sa_key_version" {
  secret = google_secret_manager_secret.default_sa_key.id

  secret_data = base64decode(google_service_account_key.default_sa_key.private_key)
}
