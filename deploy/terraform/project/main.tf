locals {
  region          = "northamerica-northeast1"
  billing_account = "017629-BB9381-1C2281"

  project = {
    id = "matthewlymer-production"
  }
}

provider "google" {
  region  = local.region
  project = local.project.id
}

resource "google_project" "default" {
  name            = local.project.id
  project_id      = local.project.id
  billing_account = local.billing_account
}

terraform {
  backend "gcs" {
    bucket = "490635812867-tfstate"
    prefix = "matthewlymer-production-project"
  }
}
