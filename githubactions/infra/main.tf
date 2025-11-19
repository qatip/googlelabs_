terraform {
  required_version = ">= 1.5.0"

  backend "gcs" {
    bucket = "{state bucket}"  # <<<<< your remote state bucket
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.40"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# -------------------------------------------------------------------
# Locals: central place for env-aware naming & flags
# -------------------------------------------------------------------
locals {
  env         = var.environ              # "dev" | "test" | "prod"
  is_prod     = local.env == "prod"
  is_dev      = local.env == "dev"
  name_prefix = "ga-${var.project_id}-${local.env}"

  # Dev gets cheaper shapes, prod gets beefier
  machine_type = local.is_prod ? "e2-medium" : "e2-micro"

  # Retention: longer in prod
  bucket_retention_seconds = local.is_prod ? 30 * 24 * 3600 : 7 * 24 * 3600
}

# -------------------------------------------------------------------
# VPC network – shared pattern, env in the name
# -------------------------------------------------------------------
resource "google_compute_network" "demo_vpc" {
  name                    = "${local.name_prefix}-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "demo_subnet" {
  name          = "${local.name_prefix}-subnet"
  ip_cidr_range = "10.0.0.0/24"
  region        = var.region
  network       = google_compute_network.demo_vpc.id
}

# -------------------------------------------------------------------
# App data bucket – exists in all envs, env in the name
# -------------------------------------------------------------------
resource "google_storage_bucket" "app_data" {
  name          = "${local.name_prefix}-app-data"
  location      = var.region
  force_destroy = true

  uniform_bucket_level_access = true

  labels = {
    project     = var.project_id
    environment = local.env
    purpose     = "app-data"
  }

  retention_policy {
    retention_period = local.bucket_retention_seconds
  }
}

# -------------------------------------------------------------------
# Prod-only log bucket – created only when env == "prod"
# -------------------------------------------------------------------
resource "google_storage_bucket" "logs" {
  count         = local.is_prod ? 1 : 0
  name          = "${local.name_prefix}-logs"
  location      = var.region
  force_destroy = true

  uniform_bucket_level_access = true

  labels = {
    project     = var.project_id
    environment = local.env
    purpose     = "logs"
  }

  retention_policy {
    retention_period = 90 * 24 * 3600
  }
}

# -------------------------------------------------------------------
# Tiny demo instance – type varies by env
# -------------------------------------------------------------------
resource "google_compute_instance" "demo_vm" {
  name         = "${local.name_prefix}-vm"
  machine_type = local.machine_type
  zone         = "${var.region}-b"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.demo_subnet.id
    access_config {}
  }

  labels = {
    project     = var.project_id
    environment = local.env
  }
}

# -------------------------------------------------------------------
# Outputs to prove env differences
# -------------------------------------------------------------------
output "environment" {
  value = local.env
}

output "bucket_name" {
  value = google_storage_bucket.app_data.name
}

output "vm_machine_type" {
  value = google_compute_instance.demo_vm.machine_type
}

output "log_bucket_created" {
  value = local.is_prod
}
