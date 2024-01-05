variable "project_id" {
  description = "The project ID to host the cluster in"
  default     = ""
}

variable "worker_sa" {
  description = "The Service Account to be used"
  default     = ""
}
