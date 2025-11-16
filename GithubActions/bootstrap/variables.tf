variable "project_id" {
  type        = string
  description = "GCP Project ID"
}

variable "region" {
  type        = string
  description = "Default region"
  default     = "europe-west1"
}

variable "state_bucket_name" {
  type        = string
  description = "Globally-unique GCS bucket name for Terraform state"
}

