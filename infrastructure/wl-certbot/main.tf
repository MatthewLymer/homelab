locals {
  project = {
    id = "matthewlymer-production"
  }

  serviceAccount = "onprem-certbot"
}

provider "google" {
  project = local.project.id
}

terraform {
  backend "gcs" {
    bucket = "490635812867-tfstate"
    prefix = "matthewlymer-production-wl-certbot"
  }
}
