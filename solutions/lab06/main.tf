terraform {
  required_version = ">= 1.6.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.30.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# Random suffix to help ensure global uniqueness when students forget to change the name.
resource "random_id" "suffix" {
  byte_length = 3
}

locals {
  bucket_name = var.bucket_name != "" ? var.bucket_name : format("%s-%s", "googlelabs-static", random_id.suffix.hex)
  mime_map    = jsondecode(file("${path.module}/mime.json"))
}

resource "google_storage_bucket" "media" {
  name                        = local.bucket_name
  location                    = var.region
  storage_class               = var.default_storage_class
  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }

  lifecycle_rule {
    condition {
      age = 30
    }
    action {
      type          = "SetStorageClass"
      storage_class = var.cold_storage_class
    }
  }

  lifecycle_rule {
    condition {
      age = 90
    }
    action {
      type = "Delete"
    }
  }

  # Block all public access at the bucket level.
  public_access_prevention = "enforced"

  labels = {
    env     = var.env
    purpose = "lab06-gcs"
  }
}

# OPTIONAL best-effort "HTTPS only" note:
# GCS JSON API uses HTTPS. To avoid accidental unsigned access, keep objects private and
# use Signed URLs for temporary sharing.

# Upload all files from static_files with the correct MIME type.
# Uses content_type based on mime.json (lookup by file extension).
locals {
  files = toset(fileset("${path.module}/static_files", "**"))
}

resource "google_storage_bucket_object" "objects" {
  for_each = local.files

  name   = each.value
  bucket = google_storage_bucket.media.name
  source = "${path.module}/static_files/${each.value}"

  content_type = lookup(local.mime_map, regex("\\.[^.]*$", each.value), "application/octet-stream")
}

# Create a service account to sign URLs (kept scoped to Storage Object Viewer).
resource "google_service_account" "signer" {
  account_id   = "lab06-url-signer"
  display_name = "Lab06 URL Signer"
}

resource "google_storage_bucket_iam_member" "signer_viewer" {
  bucket = google_storage_bucket.media.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.signer.email}"
}

# Generate a Signed URL for Teide.jpeg valid for 1 hour.
# Requires google provider data source 'google_storage_object_signed_url'.
data "google_storage_object_signed_url" "teide" {
  bucket       = google_storage_bucket.media.name
  path         = "Teide.jpeg"
  duration     = "3600s"
  http_method  = "GET"
  service_account_email = google_service_account.signer.email
}

output "bucket_name" {
  value = google_storage_bucket.media.name
}

output "signed_url_teide" {
  value       = data.google_storage_object_signed_url.teide.signed_url
  description = "Signed URL (valid 1 hour) for Teide.jpeg"
}
