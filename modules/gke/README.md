# GKE Module

This module is responsible for creating a Google Kubernetes Engine (GKE) cluster in the specified Google Cloud Platform (GCP) project. It includes configurations for the cluster itself, node pools, and any necessary IAM roles.

## Usage

To use this module, include it in your Terraform configuration as follows:

```hcl
module "gke" {
  source              = "../modules/gke"
  project_id         = var.project_id
  cluster_name       = var.cluster_name
  region             = var.region
  zone               = var.zone
  node_count         = var.node_count
  node_machine_type  = var.node_machine_type
  network            = var.network
  subnetwork         = var.subnetwork
  ip_range           = var.ip_range
  enable_private_ip  = var.enable_private_ip
  enable_autoscaling  = var.enable_autoscaling
  min_node_count     = var.min_node_count
  max_node_count     = var.max_node_count
}
```

## Inputs

| Name                     | Description                                      | Type   | Default | Required |
|--------------------------|--------------------------------------------------|--------|---------|----------|
| project_id               | The ID of the project in which to create the GKE cluster. | string | n/a     | yes      |
| cluster_name             | The name of the GKE cluster.                     | string | n/a     | yes      |
| region                   | The region where the GKE cluster will be created. | string | n/a     | yes      |
| zone                     | The zone where the GKE cluster will be created. | string | n/a     | yes      |
| node_count               | The initial number of nodes in the node pool.    | number | 3       | no       |
| node_machine_type        | The machine type for the nodes.                  | string | "e2-medium" | no    |
| network                  | The VPC network to which the GKE cluster will be connected. | string | n/a     | yes      |
| subnetwork               | The subnetwork to which the GKE cluster will be connected. | string | n/a     | yes      |
| ip_range                 | The IP range for the GKE cluster.                | string | n/a     | yes      |
| enable_private_ip        | Whether to enable private IP for the cluster.    | bool   | false   | no       |
| enable_autoscaling       | Whether to enable autoscaling for the node pool. | bool   | false   | no       |
| min_node_count           | Minimum number of nodes for autoscaling.         | number | 1       | no       |
| max_node_count           | Maximum number of nodes for autoscaling.         | number | 5       | no       |

## Outputs

| Name                     | Description                                      |
|--------------------------|--------------------------------------------------|
| cluster_name             | The name of the GKE cluster.                     |
| endpoint                 | The endpoint of the GKE cluster.                 |
| kubeconfig               | The kubeconfig file for accessing the GKE cluster. |

## Example

```hcl
module "gke" {
  source              = "../modules/gke"
  project_id         = "my-gcp-project"
  cluster_name       = "my-gke-cluster"
  region             = "us-central1"
  zone               = "us-central1-a"
  node_count         = 3
  node_machine_type  = "e2-medium"
  network            = "my-vpc-network"
  subnetwork         = "my-subnetwork"
  ip_range           = "10.0.0.0/24"
  enable_private_ip  = true
  enable_autoscaling  = true
  min_node_count     = 1
  max_node_count     = 5
}
```

## Notes

- Ensure that the necessary IAM roles are assigned to the service account used for Terraform to create the GKE cluster.
- Review the GKE pricing model to understand the costs associated with running a GKE cluster.