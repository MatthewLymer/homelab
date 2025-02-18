resource "google_service_account" "homelink_updater" {
  account_id   = "homelink-updater"
  display_name = "Homelink Updater"
}

resource "google_dns_managed_zone_iam_member" "lymer_ca_homelink_updater" {
  managed_zone = data.google_dns_managed_zone.lymer_ca.name
  role         = "roles/editor"
  member       = "serviceAccount:${google_service_account.homelink_updater.email}"
}
