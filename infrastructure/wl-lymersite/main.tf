locals {
  project = {
    id = "matthewlymer-production"
  }
}

provider "google" {
  project = local.project.id
}

terraform {
  backend "gcs" {
    bucket = "490635812867-tfstate"
    prefix = "matthewlymer-production-wl-lymersite"
  }
}
