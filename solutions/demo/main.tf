terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.17.0"
    }
  }
}

provider "google" {
  project = var.project_id
}

resource "google_storage_bucket" "demo_buckets" {
  count  = length(var.bucket_names)
  name   = var.bucket_names[count.index]
  location = "EU"
  force_destroy = true
  project = var.project_id
}

resource "google_storage_bucket" "demo_buckets_each" {
  for_each = var.buckets

  name     = each.key 
  location = each.value
  force_destroy = true
  project  = var.project_id
}

