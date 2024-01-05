# Terraform to provision GKE Autopilot

## Feature List
* Use [Autopilot Compute Class](https://cloud.google.com/kubernetes-engine/docs/concepts/autopilot-compute-classes) `Scale-Out` to automatically setup taints and tolerations to a dedicated node pool, which will be used by the helm chart to distribute the DB Pods
* Enable Workload Identity by Autopilot
* Enable `Backup for GKE` by Autopilot

## Prerequisites and Assumptions
* Done initialization of the project and gcloud CLI following the instructions in `{ROOT}/README.md`
* VPC network, refer to `gke` folder for the details

## Usage
```
./generate_provider.py
terraform init
terraform plan -var-file terraform.tfvars.json
terraform apply -var-file terraform.tfvars.json
```
## Clean up
**NOTE:** Be very careful when destroying any resource, not recommended for production!
```
# Destroy everything
terraform apply -var-file terraform.tfvars.json

# Destroy GKE cluster
terraform destroy \
-var-file terraform.tfvars.json \
-target='module.gke-db1-autopilot.google_container_cluster.primary' \
```
