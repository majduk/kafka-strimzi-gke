variable "project_id" {
  description = "The project ID to host the cluster in"
}

variable "worker_sa" {
  description = "The Service Account to be used"
}


variable "automation_sa" {
  description = "The Service Account used by Terraform"
}

variable "tfstate_bucket" {
  description = "terraform state GCS bucket"
}

variable "region" {
  description = "The region to be used"
}

variable "network" {
  description = "The network name"
}

variable "subnetwork" {
  description = "The subnetwork name"
}

variable "ip_range_pods" {
  description = "Pods IP range name"
}

variable "ip_range_svcs" {
  description = "services IP range name"
}
