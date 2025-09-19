
provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_compute_instance" "default" {
  name         = "lab-instance-${var.random_id}"
  machine_type = var.instance_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }
}

locals {
  actual_bucket_name = var.force_fail_postcondition ? "${var.bucket_name}-mismatch" : var.bucket_name
}


resource "google_storage_bucket" "default" {
  name     = local.actual_bucket_name
  location = "US"
  force_destroy = true

  lifecycle {
    precondition {
      condition     = can(regex("^lab-bucket", var.bucket_name))
      error_message = "Bucket name must start with 'lab-bucket'."
    }
    postcondition {
      condition     = local.actual_bucket_name == var.bucket_name
      error_message = "Actual bucket name must match input variable."
    }
  }
}
