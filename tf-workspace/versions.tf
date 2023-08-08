terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.75.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 4.75.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5.1"
    }
  }
  required_version = ">= 1.5.3"
}
