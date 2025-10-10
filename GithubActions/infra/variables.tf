variable "project_id" {
  type        = string
  description = "Your GCP project ID"
}

variable "region" {
  type        = string
  description = "Default region for resources"
  default     = "europe-west1"
}
