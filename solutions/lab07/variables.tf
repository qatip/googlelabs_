
variable "project_id" {
  description = "Your GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "GCP zone"
  type        = string
  default     = "us-central1-a"
}

variable "instance_type" {
  description = "Compute Engine machine type"
  type        = string
  default     = "n1-standard-1"

  validation {
    condition     = can(regex("^n1-standard", var.instance_type))
    error_message = "Only machine types starting with n1-standard are allowed."
  }
}

variable "bucket_name" {
  description = "Name of the GCS bucket"
  type        = string
}

variable "random_id" {
  description = "Random identifier"
  type        = string
}

variable "force_fail_postcondition" {
  type        = bool
  default     = false
}
