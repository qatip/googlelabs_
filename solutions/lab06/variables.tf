variable "project_id" {
  type        = string
  description = "GCP project ID"
  default = "{projectid}"
}

variable "region" {
  type        = string
  default     = "us-central1"
  description = "Region for the bucket"
}

variable "bucket_name" {
  type        = string
  description = "Name of the GCS bucket to create"
  default = "{bucket name}"
}

variable "default_storage_class" {
  type        = string
  default     = "STANDARD"
  description = "Initial storage class for new objects"
}

variable "cold_storage_class" {
  type        = string
  default     = "NEARLINE"
  description = "Storage class after lifecycle transition"
}
