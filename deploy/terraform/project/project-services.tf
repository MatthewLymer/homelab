resource "google_project_service" "dns" {
  project = local.project.id
  service = "dns.googleapis.com"
}

resource "google_project_service" "secretmanager" {
  project = local.project.id
  service = "secretmanager.googleapis.com"
}