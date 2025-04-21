resource "google_service_account" "certbot" {
  account_id   = "certbot"
  display_name = "Certbot"
}

resource "google_dns_managed_zone_iam_member" "certbot_lymer_ca" {
  managed_zone = data.google_dns_managed_zone.lymer_ca.name
  role         = "roles/editor"
  member       = "serviceAccount:${google_service_account.certbot.email}"
}

resource "google_project_iam_member" "certbot_dns_reader" {
  project = local.project.id
  role    = "roles/dns.reader"
  member  = "serviceAccount:${google_service_account.certbot.email}"
}