terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = { source = "hashicorp/google", version = "~> 5.40" }
    google-beta = { source = "hashicorp/google-beta", version = "~> 5.40" }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}


########################
# Remote state bucket
########################
resource "google_storage_bucket" "tf_state" {
  name                        = var.state_bucket_name
  location                    = var.region
  uniform_bucket_level_access = true
  force_destroy = true
  versioning { enabled = true }
}

