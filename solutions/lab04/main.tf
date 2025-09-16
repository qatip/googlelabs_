terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "6.17.0"
    }
  }
}

provider "google" {
  project = "<your project id here>"
}

resource "google_compute_instance" "default" {
  name         = "terraform-demo-${terraform.workspace}-1"
  machine_type = var.vm_size
  zone         = var.vm_location
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = var.vm_image
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }
}

output "instance_details" {
  description = "Details of the created instances"
  value = {
    workspace_used = terraform.workspace
    name_of_vm  = google_compute_instance.default.name
    zone_of_vm = google_compute_instance.default.zone
    size_of_vm = google_compute_instance.default.machine_type
    image_of_vm = var.vm_image
  }
}