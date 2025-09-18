terraform {
  required_providers {
    google = { source = "hashicorp/google" }
    random = { source = "hashicorp/random" }
  }
}

#############################
# Variables (self-contained)
#############################
variable "project_id"         {
  type = string
  default = "{your-projectid}" 
}
variable "region"             {
  type = string
  default = "us-central1" 
}
variable "bucket_name"        {
  type = string
  default = "" 
} 
variable "env"                {
  type = string
  default = "lab" 
}
variable "default_storage_class" {
  type = string 
  default = "STANDARD" 
}
variable "cold_storage_class"    {
  type = string
  default = "NEARLINE" 
}

provider "google" {
  project = var.project_id
  region  = var.region
}

resource "random_id" "suffix" { byte_length = 3 }

locals {
  # Safe default name: <project>-lab06-<rand>  (avoids 'google*' naming restriction)
  bucket_name = var.bucket_name != "" ? var.bucket_name : format("%s-lab06-%s", var.project_id, random_id.suffix.hex)

  # Expect mime.json alongside this file; keys like ".jpg", ".png", ".txt"
  mime_map = jsondecode(file("${path.module}/mime.json"))

  # All files under static_files/
  files = toset(fileset("${path.module}/static_files", "**"))
}

#############################
# GCS bucket (private)
#############################
resource "google_storage_bucket" "media" {
  name                        = local.bucket_name
  location                    = var.region
  storage_class               = var.default_storage_class
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
  force_destroy = true

  versioning { enabled = true }

  # Move to colder storage after 30 days
  lifecycle_rule {
    condition { age = 30 }
    action    { 
    type = "SetStorageClass" 
    storage_class = var.cold_storage_class 
  }
  }

  # Delete after 90 days
  lifecycle_rule {
    condition { age = 90 }
    action    { type = "Delete" }
  }

  labels = {
    env     = var.env
    purpose = "lab06-gcs"
  }
}

#############################
# Upload objects with MIME
#############################
resource "google_storage_bucket_object" "objects" {
  for_each = local.files
  name     = each.value
  bucket   = google_storage_bucket.media.name
  source   = "${path.module}/static_files/${each.value}"

  # infer content type by file extension; fallback to octet-stream
  content_type = lookup(local.mime_map, regex("\\.[^.]*$", each.value), "application/octet-stream")
}

#############################
# Outputs
#############################
output "bucket_name" {
  value       = google_storage_bucket.media.name
  description = "Name of the created GCS bucket"
}

output "bucket_console_url" {
  value       = "https://console.cloud.google.com/storage/browser/${google_storage_bucket.media.name}?project=${var.project_id}"
  description = "Quick link to the bucket in the console"
}
