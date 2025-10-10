variable "project_id" {
  type        = string
  description = "Your GCP project ID"
}

variable "region" {
  type        = string
  description = "GCP region for provider calls"
}

variable "repo_full_name" {
  type        = string
  description = "Your GitHub repo in owner/name form, e.g. qatip/google-gitactions"
}

variable "wif_pool_id" {
  type        = string
  description = "Workload Identity Pool ID (name-only)"
}

variable "wif_provider_id" {
  type        = string
  description = "Workload Identity Provider ID (name-only)"
}

variable "tf_runner_sa_id" {
  type        = string
  description = "Service Account name (name-only, not email)"
}

variable "state_bucket_name" {
  type        = string
  description = "Globally-unique GCS bucket name for Terraform state (e.g., tf-state-<yourname>-001)"
}
