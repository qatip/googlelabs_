### Task 1 ###
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.17.0"
    }
  }
}

provider "google" {
  project = "<your project id>"
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

### Task 2 ###

resource "google_compute_router" "lab_router" {
  name    = "lab-router"
  region  = google_compute_subnetwork.public_subnet.region
  network = google_compute_network.lab_vpc.id
}

resource "google_compute_router_nat" "lab_nat" {
  name                               = "lab-nat"
  router                             = google_compute_router.lab_router.name
  region                             = google_compute_router.lab_router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.private_subnet.id
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}

### Task 3 ###

resource "google_compute_firewall" "lab_private_fw_rule" {
  name    = "lab-private-firewall"
  network = google_compute_network.lab_vpc.name

  allow {
    protocol = "all"
  }
  source_tags = ["pub-subnet-vm"]
  target_tags = ["priv-subnet-vm"]
}

resource "google_compute_firewall" "lab_public_fw_rules" {
  name    = "lab-public-firewall"
  network = google_compute_network.lab_vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["pub-subnet-vm"]
}

### Task 4 ###

resource "google_compute_instance" "pub_vm" {
  name                      = "pub-vm"
  machine_type              = "e2-small"
  zone                      = "us-central1-a"
  allow_stopping_for_update = true
  tags                      = ["pub-subnet-vm"]
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  network_interface {
    subnetwork = google_compute_subnetwork.public_subnet.id
    access_config {
    }
  }
}

resource "google_compute_instance" "priv_vm" {
  name                      = "priv-vm"
  machine_type              = "e2-small"
  zone                      = "us-central1-a"
  allow_stopping_for_update = true
  tags                      = ["priv-subnet-vm"]
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  network_interface {
    subnetwork = google_compute_subnetwork.private_subnet.id
  }
}

