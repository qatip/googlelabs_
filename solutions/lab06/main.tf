terraform {
  required_providers {
    google = { source = "hashicorp/google" }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

locals {
  bucket_name = var.bucket_name
  mime_map = jsondecode(file("${path.module}/mime.json"))
  files = toset(fileset("${path.module}/static_files", "**"))
}

resource "google_storage_bucket" "media" {
  name                        = local.bucket_name
  location                    = var.region
  storage_class               = var.default_storage_class
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
  force_destroy               = true

  versioning {
    enabled = true
  }

  lifecycle_rule {
    condition { age = 30 }
    action {
      type          = "SetStorageClass"
      storage_class = var.cold_storage_class
    }
  }

  lifecycle_rule {
    condition { age = 90 }
    action    { type = "Delete" }
  }

}

resource "google_storage_bucket_object" "objects" {
  for_each = local.files

  name   = each.value
  bucket = google_storage_bucket.media.name
  source = "${path.module}/static_files/${each.value}"

  content_type = lookup(
    local.mime_map,
    can(regex("\\.[^.]*$", each.value)) ? regex("\\.[^.]*$", each.value) : "",
    "application/octet-stream"
  )
}
