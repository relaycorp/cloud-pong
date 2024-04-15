terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.75.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 5.24.0"
    }
    mongodbatlas = {
      source  = "mongodb/mongodbatlas"
      version = "~> 1.14.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.0"
    }
  }
  required_version = ">= 1.5.3"
}

provider "google" {
  project = var.gcp_project_id
}

provider "google-beta" {
  project = var.gcp_project_id
}

provider "mongodbatlas" {
}
