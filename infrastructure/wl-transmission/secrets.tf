resource "google_secret_manager_secret" "transmission_openvpn_username" {
  secret_id = "transmission-openvpn-username"

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret" "transmission_openvpn_password" {
  secret_id = "transmission-openvpn-password"

  replication {
    auto {}
  }
}
