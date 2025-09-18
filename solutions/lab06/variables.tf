variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "Region for the bucket"
  type        = string
  default     = "us-central1"
}

variable "bucket_name" {
  description = "Optional: explicit bucket name to use (must be globally unique)"
  type        = string
  default     = ""
}

variable "env" {
  description = "Label for environment"
  type        = string
  default     = "lab"
}

variable "default_storage_class" {
  description = "Default storage class for new objects"
  type        = string
  default     = "STANDARD"
}

variable "cold_storage_class" {
  description = "Target storage class for older objects"
  type        = string
  default     = "NEARLINE"
}
