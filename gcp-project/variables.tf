/**
 * Copyright 2023 Google. This software is provided as-is,
 * without warranty or representation for any use or purpose.
 * Your use of it is subject to your agreement with Google.
 */

variable "tfstate_bucket_name" {
  description = "Bucket for storing terraform state"
  type        = string
}

variable "terraform_sa" {
  description = "Service account used by terraform"
  type        = string
}

variable "org_id" {
  description = "GCP Organization ID"
  type        = string
}

variable "parent_folder" {
  description = "Organization's parent folder id in a form folders/{id}"
  type        = string
}

variable "billing_account" {
  description = "The ID of the billing account to associate projects with."
  type        = string
}

variable "project_name" {
  description = "Project to create"
  type        = string
}

variable "region" {
  description = "Project region"
  type        = string
}

variable "outputs_location" {
  description = "Outputs location"
  type        = string
}
