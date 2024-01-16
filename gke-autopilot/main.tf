data "google_client_config" "default" {}

resource "google_artifact_registry_repository" "main" {
  location      = var.region
  repository_id = "main"
  format        = "DOCKER"
  project       = var.project_id
}
resource "google_artifact_registry_repository_iam_binding" "binding" {
  provider   = google-beta
  project    = google_artifact_registry_repository.main.project
  location   = google_artifact_registry_repository.main.location
  repository = google_artifact_registry_repository.main.name
  role       = "roles/artifactregistry.reader"
  members = [
    "serviceAccount:${var.worker_sa}",
  ]
}

module "gke_kafka_central" {
  source                          = "../modules/beta-autopilot-private-cluster"
  project_id                      = var.project_id
  name                            = "gke-kafka-${var.region}"
  kubernetes_version              = "1.25"
  region                          = var.region
  regional                        = true
  network                         = var.network
  subnetwork                      = var.subnetwork
  ip_range_pods                   = var.ip_range_pods
  ip_range_services               = var.ip_range_svcs
  horizontal_pod_autoscaling      = true
  release_channel                 = "REGULAR"
  enable_vertical_pod_autoscaling = true
  enable_private_endpoint         = false
  enable_private_nodes            = true
  master_ipv4_cidr_block          = "172.16.0.0/28"
  create_service_account          = false
  grant_registry_access           = true
  service_account                 = var.worker_sa
  datapath_provider               = "ADVANCED_DATAPATH"
}

