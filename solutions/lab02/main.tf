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
  # Configuration options
}

resource "google_compute_instance" "default" {
  name         = "my-instance"
#  machine_type = "n2-standard-2"
  machine_type = "e2-small"
  zone         = "us-central1-a"
  allow_stopping_for_update = true

  tags = ["foo", "bar"]

  boot_disk {
    initialize_params {
#      image = "debian-cloud/debian-11"
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
      
      labels = {
        my_label = "value"
      }
    }
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral public IP
    }
  }
}

