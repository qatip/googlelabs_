provider "google" {
  project = var.project_id
  region  = var.region
}

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.40"
    }
  }
}

terraform {
  backend "gcs" {
    bucket = "<your backend bucket name here>" 
    prefix = "dev"        # any folder-ish prefix you like
  }
}

# Simple demo resource — a storage bucket named with your project id
resource "google_storage_bucket" "demo" {
  name          = "demo-bucket-${var.project_id}"
  location      = var.region
  force_destroy = true
}
