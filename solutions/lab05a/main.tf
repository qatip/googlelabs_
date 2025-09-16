terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "6.17.0"
    }
  }
}

provider "google" {
  project = var.lab-project
  region  = var.lab-region
}
module "vpc" {
  source = "./network"
}

terraform {
  backend "gcs" {
    bucket = "tf-remote-state-<YOUR NAME>"  # Replace <YOUR NAME> with your unique identifier
    prefix = "terraform/state"              # Path within the bucket for the state file
  }


}