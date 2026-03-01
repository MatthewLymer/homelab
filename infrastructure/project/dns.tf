resource "google_dns_managed_zone" "lymer_ca" {
  name     = "lymer-ca"
  dns_name = "lymer.ca."

  depends_on = [
    google_project_service.dns
  ]
}

# for personal email address
resource "google_dns_record_set" "lymer_ca_mx" {
  name         = google_dns_managed_zone.lymer_ca.dns_name
  managed_zone = google_dns_managed_zone.lymer_ca.name
  type         = "MX"
  ttl          = 3600

  rrdatas = [
    "5 outlook-com.olc.protection.outlook.com."
  ]
}
