resource "google_project_service" "dns" {
  project = local.project.id
  service = "dns.googleapis.com"
}
