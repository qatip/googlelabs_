terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.17.0"
    }
  }
}

variable "project_id" { default = "mcg-demo-project" }


provider "google" {
  project = var.project_id
  region  = "us-central1"
}

resource "google_compute_network" "lab_vpc" {
  name                    = "lab-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "public_subnet" {
  name          = "public-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = "us-central1"
  network       = google_compute_network.lab_vpc.id
}

resource "google_compute_subnetwork" "private_subnet" {
  name          = "private-subnet"
  ip_cidr_range = "10.0.2.0/24"
  region        = "us-central1"
  network       = google_compute_network.lab_vpc.id
}

resource "google_compute_subnetwork" "eu_subnet" {
  name          = "eu-subnet"
  ip_cidr_range = "10.0.3.0/24"
  region        = "europe-west2"
  network       = google_compute_network.lab_vpc.id

  secondary_ip_range {
     ip_cidr_range = "192.168.1.0/24"
     range_name = "secondary"
     reserved_internal_range = ""
  }
}
