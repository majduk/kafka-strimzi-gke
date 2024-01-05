/**
 * Copyright 2023 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
locals {
  activate_apis = [
  ]
  automation_sa_required_roles = [
    "roles/storage.objectAdmin",
    "role/logging.logWriter", 
    "role/artifactregistry.Admin", 
    "roles/container.clusterAdmin", 
    "role/container.serviceAgent", 
    "roles/iam.serviceAccountAdmin", 
    "roles/serviceusage.serviceUsageAdmin", 
    "roles/iam.serviceAccountAdmin"
  ]
  worker_sa_required_roles = [
  ]
}

module "data_project" {
  source                      = "terraform-google-modules/project-factory/google"
  version                     = "~> 14.0"
  name                        = var.project_name
  folder_id                   = data.google_folder.parent.id
  org_id                      = var.org_id
  create_project_sa           = false
  billing_account             = var.billing_account
  activate_apis               = local.activate_apis
}

module "vpc" {
  source       = "terraform-google-modules/network/google"
  version      = "~> 7.0"
  project_id   = module.data_project.project_id
  network_name = "worker-network"

  subnets = [
    {
      subnet_name   = "worker-subnetwork"
      subnet_ip     = "10.2.3.0/24"
      subnet_region = var.region
      subnet_private_access = true
    },
  ]

  secondary_ranges = {
    dataflow-subnetwork = [
      {
        range_name    = "worker-secondary-range"
        ip_cidr_range = "192.168.128.0/24"
      },
    ]
  }
}

resource "google_service_account" "worker_sa" {
  project      = module.data_project.project_id
  account_id   = "kafka-sa"
  display_name = "kafka-sa"
}

resource "google_project_iam_member" "worker_sa" {
  for_each = toset(local.worker_sa_required_roles)
  project = module.data_project.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.worker_sa.email}"
}

resource "google_service_account" "automation_sa" {
  project      = module.data_project.project_id
  account_id   = "automation-sa"
  display_name = "automation-sa"
}

resource "google_project_iam_member" "automation_sa" {
  for_each = toset(local.automation_sa_required_roles)
  project = module.data_project.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.automation_sa.email}"
}

resource "random_id" "random_suffix" {
  byte_length = 4
}

locals {
  tfstate_bucket_name = "tfstate-${random_id.random_suffix.hex}"
}

resource "google_storage_bucket" "tfstate_bucket" {
  name          = local.tfstate_bucket_name
  location      = var.region
  storage_class = "REGIONAL"
  project       = module.data_project.project_id
  uniform_bucket_level_access = true
  force_destroy = true
}


