terraform {
  required_version = ">= 1.5.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.40"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 5.40"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}

data "google_project" "this" {}

# 1) Service Account that GitHub Actions will impersonate
resource "google_service_account" "tf_runner" {
  account_id   = var.tf_runner_sa_id
  display_name = "Terraform GitHub Actions Runner"
}

# 2) GCS bucket for Terraform remote state
resource "google_storage_bucket" "tf_state" {
  name                        = var.state_bucket_name
  location                    = var.region
  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }
}

# Allow the runner SA to manage objects in the state bucket
resource "google_storage_bucket_iam_member" "tf_state_admin" {
  bucket = google_storage_bucket.tf_state.name
  role   = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.tf_runner.email}"
}

# 3) Workload Identity Federation pool & OIDC provider (trusts GitHub)
resource "google_iam_workload_identity_pool" "gha_pool" {
  provider                  = google-beta
  workload_identity_pool_id = var.wif_pool_id
  display_name              = "GitHub Actions Pool"
}

resource "google_iam_workload_identity_pool_provider" "gha_provider" {
  provider                           = google-beta
  workload_identity_pool_id          = google_iam_workload_identity_pool.gha_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = var.wif_provider_id
  display_name                       = "GitHub OIDC Provider"

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }

  # Map useful GitHub claims into attributes
  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.repository" = "assertion.repository"
    "attribute.ref"        = "assertion.ref"
  }

  # Restrict trust to exactly your repo (owner/name)
  attribute_condition = "assertion.repository == '${var.repo_full_name}'"
}

# 4) Let identities from the pool (restricted by repo) impersonate the SA
resource "google_service_account_iam_member" "wif_impersonation" {
  service_account_id = google_service_account.tf_runner.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/projects/${data.google_project.this.number}/locations/global/workloadIdentityPools/${google_iam_workload_identity_pool.gha_pool.workload_identity_pool_id}/attribute.repository/${var.repo_full_name}"
}

output "service_account_email" {
  description = "Use this as SERVICE_ACCOUNT in the GitHub Actions workflows"
  value       = google_service_account.tf_runner.email
}

output "workload_identity_provider_resource" {
  description = "Use this as WORKLOAD_IDENTITY_PROVIDER in the GitHub Actions workflows"
  value       = "projects/${data.google_project.this.number}/locations/global/workloadIdentityPools/${google_iam_workload_identity_pool.gha_pool.workload_identity_pool_id}/providers/${google_iam_workload_identity_pool_provider.gha_provider.workload_identity_pool_provider_id}"
}

output "state_bucket" {
  description = "Use this as the backend bucket in infra/backend.tf"
  value       = google_storage_bucket.tf_state.name
}

# TEMPORARY: Broad permissions for the demo
resource "google_project_iam_member" "project_editor_demo" {
  project = var.project_id
  role    = "roles/editor"
  member  = "serviceAccount:${google_service_account.tf_runner.email}"
}

