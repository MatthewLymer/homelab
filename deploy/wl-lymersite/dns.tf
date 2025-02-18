data "google_dns_managed_zone" "lymer_ca" {
  name = "lymer-ca"
}

resource "google_dns_record_set" "lymer_ca_a" {
  name         = data.google_dns_managed_zone.lymer_ca.dns_name
  managed_zone = data.google_dns_managed_zone.lymer_ca.name
  type         = "A"
  ttl          = 300

  rrdatas = [
    "216.239.32.21",
    "216.239.34.21",
    "216.239.36.21",
    "216.239.38.21"
  ]
}

resource "google_dns_record_set" "lymer_ca_aaaa" {
  name         = data.google_dns_managed_zone.lymer_ca.dns_name
  managed_zone = data.google_dns_managed_zone.lymer_ca.name
  type         = "AAAA"
  ttl          = 300

  rrdatas = [
    "2001:4860:4802:32::15",
    "2001:4860:4802:34::15",
    "2001:4860:4802:36::15",
    "2001:4860:4802:38::15"
  ]
}

resource "google_dns_record_set" "www_lymer_ca_cname" {
  name         = "www.${data.google_dns_managed_zone.lymer_ca.dns_name}"
  managed_zone = data.google_dns_managed_zone.lymer_ca.name
  type         = "CNAME"
  ttl          = 300

  rrdatas = [
    "lymer.ca."
  ]
}
