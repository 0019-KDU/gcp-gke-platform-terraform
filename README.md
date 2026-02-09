# Multi-Region GKE Platform with Service Mesh

[![Terraform CI](https://github.com/0019-KDU/gcp-gke-platform-terraform/actions/workflows/terraform-ci.yml/badge.svg)](https://github.com/0019-KDU/gcp-gke-platform-terraform/actions/workflows/terraform-ci.yml)
[![Infracost](https://img.shields.io/badge/Infracost-Enabled-brightgreen)](https://www.infracost.io/)
[![Terraform](https://img.shields.io/badge/Terraform-1.9.0-purple)](https://www.terraform.io/)
[![GCP](https://img.shields.io/badge/GCP-GKE-blue)](https://cloud.google.com/kubernetes-engine)

Production-ready multi-region GKE infrastructure with Cloud Service Mesh, automated CI/CD pipelines, cost estimation, and drift detection.

---

## Table of Contents

- [Architecture](#architecture)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Project Structure](#project-structure)
- [Quick Start](#quick-start)
- [CI/CD Pipelines](#cicd-pipelines)
- [Environments](#environments)
- [Cost Management](#cost-management)
- [Security](#security)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)

---

## Architecture

```
                         ┌──────────────────────────────────────────────────────────┐
                         │                    Google Cloud Platform                  │
                         │                                                          │
                         │    ┌──────────────────────────────────────────────────┐  │
                         │    │        External Application Load Balancer         │  │
                         │    │              (Global Static IP)                   │  │
                         │    └─────────────────────┬────────────────────────────┘  │
                         │                          │                               │
                         │    ┌─────────────────────┴────────────────────────────┐  │
                         │    │              GKE Fleet (Hub)                      │  │
                         │    │    • Multi-Cluster Services (MCS)                 │  │
                         │    │    • Multi-Cluster Ingress (MCI)                  │  │
                         │    │    • Cloud Service Mesh                           │  │
                         │    └─────────────────────┬────────────────────────────┘  │
                         │                          │                               │
          ┌──────────────┼──────────────────────────┼───────────────────────────────┤
          │              │                          │                               │
          │   ASIA       │              EUROPE      │                               │
          │   (asia-     │              (europe-    │                               │
          │   southeast1)│              west1)      │                               │
          │              │                          │                               │
          │ ┌────────────┴───┐      ┌───────────────┴──┐                           │
          │ │  GKE Cluster   │      │   GKE Cluster    │                           │
          │ │   gke-asia     │◄────►│   gke-europe     │                           │
          │ │                │      │                  │                           │
          │ │ • Private      │      │ • Private        │                           │
          │ │ • Workload ID  │      │ • Workload ID    │                           │
          │ │ • Datapath V2  │      │ • Datapath V2    │                           │
          │ │ • mTLS         │      │ • mTLS           │                           │
          │ └───────┬────────┘      └────────┬─────────┘                           │
          │         │                        │                                      │
          │ ┌───────┴────────┐      ┌────────┴─────────┐                           │
          │ │  Cloud NAT     │      │   Cloud NAT      │                           │
          │ │  (Outbound)    │      │   (Outbound)     │                           │
          │ └────────────────┘      └──────────────────┘                           │
          │                                                                         │
          └─────────────────────────────────────────────────────────────────────────┘
```

---

## Features

### Infrastructure
| Feature | Description |
|---------|-------------|
| **Multi-Region** | GKE clusters in Asia and Europe for high availability |
| **Private Clusters** | No public IPs on nodes for security |
| **Workload Identity** | Secure pod-to-GCP authentication |
| **Datapath V2** | eBPF-based networking for performance |
| **Cloud NAT** | Outbound internet for private nodes |
| **Artifact Registry** | Container image storage |

### Service Mesh
| Feature | Description |
|---------|-------------|
| **Cloud Service Mesh** | Managed Istio-based service mesh |
| **mTLS** | Automatic encryption between services |
| **Multi-Cluster Services** | Service discovery across clusters |
| **Multi-Cluster Ingress** | Global load balancing with Gateway API |

### CI/CD & DevOps
| Feature | Description |
|---------|-------------|
| **Terraform CI** | Automated validation on PRs |
| **Infracost** | Cost estimation on PRs |
| **Drift Detection** | Daily infrastructure drift checks |
| **Auto Documentation** | terraform-docs integration |

---

## Prerequisites

### Tools Required

| Tool | Version | Installation |
|------|---------|--------------|
| Terraform | >= 1.5.0 | [Install](https://www.terraform.io/downloads) |
| gcloud CLI | Latest | [Install](https://cloud.google.com/sdk/docs/install) |
| kubectl | Latest | [Install](https://kubernetes.io/docs/tasks/tools/) |
| Git | Latest | [Install](https://git-scm.com/downloads) |

### GCP Requirements

1. **GCP Project** with billing enabled
2. **APIs Enabled** (automated by Terraform):
   - Kubernetes Engine API
   - Compute Engine API
   - Cloud Resource Manager API
   - GKE Hub API
   - Service Mesh API
   - Artifact Registry API

3. **Existing VPC** with subnets:
   - `subnet-asia` in `asia-southeast1`
   - `subnet-europe` in `europe-west1`

4. **Service Account** with roles:
   - `roles/container.admin`
   - `roles/compute.admin`
   - `roles/iam.serviceAccountAdmin`
   - `roles/gkehub.admin`
   - `roles/artifactregistry.admin`

### GitHub Secrets Required

| Secret | Description |
|--------|-------------|
| `GCP_PROJECT_ID` | Your GCP project ID |
| `GCP_SA_KEY` | Service account JSON key |
| `TF_STATE_BUCKET` | GCS bucket for Terraform state |
| `INFRACOST_API_KEY` | Infracost API key ([Get free key](https://www.infracost.io/)) |
| `SLACK_WEBHOOK_URL` | (Optional) Slack notifications |

---

## Project Structure

```
gcp-gke-platform-terraform/
│
├── .github/
│   └── workflows/
│       ├── terraform-ci.yml           # PR validation pipeline
│       ├── terraform-deploy.yml       # Manual deployment
│       ├── terraform-drift-detection.yml  # Daily drift checks
│       ├── terraform-docs.yml         # Auto documentation
│       └── infracost.yml              # Cost estimation
│
├── modules/
│   ├── gke-cluster/                   # GKE cluster module
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── fleet/                         # Fleet & service mesh
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── nat/                           # Cloud NAT module
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── load-balancer/                 # Global load balancer
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
│
├── main.tf                            # Root module
├── variables.tf                       # Input variables
├── outputs.tf                         # Output values
├── providers.tf                       # Provider config
├── versions.tf                        # Version constraints
├── terraform.tfvars                   # Variable values
├── terraform.tfvars.example           # Example values
├── backend.hcl                        # Backend config template
└── README.md                          # This file
```

---

## How It Works - Deep Dive

### Terraform File Relationships

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                        HOW TERRAFORM FILES WORK TOGETHER                         │
└─────────────────────────────────────────────────────────────────────────────────┘

┌──────────────────┐      ┌──────────────────┐      ┌──────────────────┐
│  terraform.tfvars │      │   variables.tf   │      │   versions.tf    │
│                  │      │                  │      │                  │
│  YOUR VALUES:    │─────►│  DEFINITIONS:    │      │  REQUIREMENTS:   │
│  project_id =    │      │  variable "x" {} │      │  terraform >= 1.5│
│  clusters = {}   │      │  variable "y" {} │      │  google >= 5.0   │
└──────────────────┘      └────────┬─────────┘      └──────────────────┘
                                   │
                                   ▼
┌──────────────────┐      ┌──────────────────┐      ┌──────────────────┐
│   providers.tf   │      │     main.tf      │      │    outputs.tf    │
│                  │      │                  │      │                  │
│  AUTHENTICATION: │─────►│  ORCHESTRATOR:   │─────►│  RESULTS:        │
│  google {}       │      │  - APIs          │      │  cluster_endpoints│
│  google-beta {}  │      │  - Modules       │      │  kubectl_commands│
│  kubernetes {}   │      │  - Resources     │      │                  │
└──────────────────┘      └────────┬─────────┘      └──────────────────┘
                                   │
                    ┌──────────────┼──────────────┐
                    │              │              │
                    ▼              ▼              ▼
            ┌─────────────┐ ┌─────────────┐ ┌─────────────┐
            │ modules/    │ │ modules/    │ │ modules/    │
            │ gke-cluster │ │ fleet       │ │ nat         │
            │             │ │             │ │             │
            │ Creates:    │ │ Creates:    │ │ Creates:    │
            │ - Cluster   │ │ - Fleet     │ │ - Router    │
            │ - Node Pool │ │ - Mesh      │ │ - NAT       │
            │ - SA        │ │ - MCS/MCI   │ │             │
            └─────────────┘ └─────────────┘ └─────────────┘
```

### How Two Clusters Are Deployed

The magic happens with Terraform's `for_each` in `main.tf`:

```hcl
# terraform.tfvars - You define the clusters
clusters = {
  "gke-asia" = {
    region      = "asia-southeast1"
    subnet_name = "subnet-asia"
    ...
  }
  "gke-europe" = {
    region      = "europe-west1"
    subnet_name = "subnet-europe"
    ...
  }
}
```

```hcl
# main.tf - Terraform loops through each cluster
module "gke_clusters" {
  for_each = var.clusters    # ← Loop through map
  source   = "./modules/gke-cluster"

  cluster_name = each.key              # "gke-asia" or "gke-europe"
  region       = each.value.region     # "asia-southeast1" or "europe-west1"
  ...
}
```

**Visual Flow:**

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                          DEPLOYMENT FLOW                                         │
└─────────────────────────────────────────────────────────────────────────────────┘

terraform.tfvars                    main.tf                         GCP
      │                                │                              │
      │  clusters = {                  │                              │
      │    "gke-asia" = {...}         │                              │
      │    "gke-europe" = {...}       │                              │
      │  }                             │                              │
      │                                │                              │
      └───────────────────────────────►│                              │
                                       │  for_each = var.clusters     │
                                       │         │                    │
                                       │         ├─── gke-asia ──────►│ Creates Cluster 1
                                       │         │                    │
                                       │         └─── gke-europe ────►│ Creates Cluster 2
                                       │                              │
```

### Module Dependency Chain

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                     RESOURCE CREATION ORDER                                      │
└─────────────────────────────────────────────────────────────────────────────────┘

Step 1: Enable APIs
    │
    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│  google_project_service.apis["container.googleapis.com"]                     │
│  google_project_service.apis["compute.googleapis.com"]                       │
│  google_project_service.apis["gkehub.googleapis.com"]                        │
│  ... (13 APIs total)                                                         │
└─────────────────────────────────────────────────────────────────────────────┘
    │
    ▼
Step 2: Create Artifact Registry (depends on APIs)
    │
    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│  google_artifact_registry_repository.ping_iam                                │
└─────────────────────────────────────────────────────────────────────────────┘
    │
    ▼
Step 3: Create GKE Clusters (depends on APIs) - PARALLEL
    │
    ├────────────────────────────────┬────────────────────────────────┐
    ▼                                ▼                                │
┌─────────────────────┐    ┌─────────────────────┐                   │
│ module.gke_clusters │    │ module.gke_clusters │                   │
│ ["gke-asia"]        │    │ ["gke-europe"]      │                   │
│                     │    │                     │                   │
│ • Service Account   │    │ • Service Account   │                   │
│ • IAM Bindings      │    │ • IAM Bindings      │                   │
│ • GKE Cluster       │    │ • GKE Cluster       │                   │
│ • Node Pool         │    │ • Node Pool         │                   │
└─────────────────────┘    └─────────────────────┘                   │
    │                                │                                │
    ▼                                ▼                                │
Step 4: Create Cloud NAT (depends on VPC) - PARALLEL                 │
    │                                │                                │
┌─────────────────────┐    ┌─────────────────────┐                   │
│ module.cloud_nat    │    │ module.cloud_nat    │                   │
│ ["asia-southeast1"] │    │ ["europe-west1"]    │                   │
│                     │    │                     │                   │
│ • Cloud Router      │    │ • Cloud Router      │                   │
│ • NAT Gateway       │    │ • NAT Gateway       │                   │
└─────────────────────┘    └─────────────────────┘                   │
    │                                │                                │
    └────────────────────────────────┴────────────────────────────────┘
                                     │
                                     ▼
Step 5: Create Fleet & Service Mesh (depends on clusters)
                                     │
┌─────────────────────────────────────────────────────────────────────────────┐
│  module.fleet                                                                │
│  • google_gke_hub_fleet.fleet                                               │
│  • google_gke_hub_membership.membership["gke-asia"]                         │
│  • google_gke_hub_membership.membership["gke-europe"]                       │
│  • google_gke_hub_feature.mcs (Multi-Cluster Services)                      │
│  • google_gke_hub_feature.mci (Multi-Cluster Ingress)                       │
│  • google_gke_hub_feature.mesh (Service Mesh)                               │
└─────────────────────────────────────────────────────────────────────────────┘
                                     │
                                     ▼
Step 6: Create Load Balancer (depends on clusters)
                                     │
┌─────────────────────────────────────────────────────────────────────────────┐
│  module.load_balancer                                                        │
│  • google_compute_global_address.lb_ip                                      │
└─────────────────────────────────────────────────────────────────────────────┘
```

### State File Management

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                        TERRAFORM STATE MANAGEMENT                                │
└─────────────────────────────────────────────────────────────────────────────────┘

                          GCS Bucket (Remote Backend)
                    ┌─────────────────────────────────────┐
                    │  bold-lantern-480305-k3-tf-state    │
                    │                                     │
                    │  ┌───────────────────────────────┐  │
                    │  │ gke-platform/                 │  │
                    │  │   ├── dev/                    │  │
                    │  │   │   └── default.tfstate ◄───┼──┼─── Dev Environment
                    │  │   │                          │  │
                    │  │   ├── staging/               │  │
                    │  │   │   └── default.tfstate ◄───┼──┼─── Staging Environment
                    │  │   │                          │  │
                    │  │   └── prod/                  │  │
                    │  │       └── default.tfstate ◄───┼──┼─── Prod Environment
                    │  └───────────────────────────────┘  │
                    └─────────────────────────────────────┘

How it works:

1. LOCAL DEVELOPMENT:
   ┌──────────────┐     terraform init -backend-config="prefix=gke-platform/dev"
   │  Developer   │─────────────────────────────────────────────────────────────►
   │  Machine     │                                                              │
   └──────────────┘                                                              │
         │                                                                       │
         │ terraform plan/apply                                                  ▼
         │                                                          ┌────────────────────┐
         └─────────────────────────────────────────────────────────►│ dev/default.tfstate│
                                                                    └────────────────────┘

2. CI/CD PIPELINE:
   ┌──────────────┐     terraform init -backend-config="prefix=gke-platform/${ENV}"
   │   GitHub     │─────────────────────────────────────────────────────────────►
   │   Actions    │                                                              │
   └──────────────┘                                                              │
         │                                                                       ▼
         │ ENV=dev     ──────────────────────────────────────►  dev/default.tfstate
         │ ENV=staging ──────────────────────────────────────►  staging/default.tfstate
         │ ENV=prod    ──────────────────────────────────────►  prod/default.tfstate
```

### What's Inside the State File

```json
{
  "version": 4,
  "terraform_version": "1.9.0",
  "resources": [
    {
      "module": "module.gke_clusters[\"gke-asia\"]",
      "type": "google_container_cluster",
      "name": "cluster",
      "instances": [
        {
          "attributes": {
            "name": "gke-asia",
            "location": "asia-southeast1",
            "endpoint": "34.xxx.xxx.xxx",
            "node_pool": [...],
            ...
          }
        }
      ]
    },
    {
      "module": "module.gke_clusters[\"gke-europe\"]",
      "type": "google_container_cluster",
      ...
    }
  ]
}
```

### State Locking (Concurrent Access Protection)

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                            STATE LOCKING                                         │
└─────────────────────────────────────────────────────────────────────────────────┘

Developer A                                    Developer B
    │                                               │
    │ terraform apply                               │ terraform apply
    │      │                                        │      │
    ▼      ▼                                        ▼      ▼
┌──────────────────┐                        ┌──────────────────┐
│ 1. Try to LOCK   │                        │ 1. Try to LOCK   │
│    state file    │                        │    state file    │
└────────┬─────────┘                        └────────┬─────────┘
         │                                           │
         ▼                                           ▼
┌──────────────────┐                        ┌──────────────────┐
│ 2. LOCK acquired │                        │ 2. LOCK FAILED!  │
│    ✅ Proceed    │                        │    ❌ Wait...    │
└────────┬─────────┘                        └────────┬─────────┘
         │                                           │
         │ (making changes)                          │ (waiting)
         │                                           │
         ▼                                           │
┌──────────────────┐                                 │
│ 3. Release LOCK  │                                 │
└────────┬─────────┘                                 │
         │                                           ▼
         │                                  ┌──────────────────┐
         │                                  │ Now can proceed  │
         │                                  │    ✅            │
         │                                  └──────────────────┘
```

### Module Communication via Outputs

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                    HOW MODULES SHARE DATA                                        │
└─────────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────────┐
│  modules/gke-cluster/outputs.tf                                                  │
│  ─────────────────────────────                                                   │
│  output "cluster_id" {                                                           │
│    value = google_container_cluster.cluster.id                                   │
│  }                                                                               │
│  output "cluster_name" {                                                         │
│    value = google_container_cluster.cluster.name                                 │
│  }                                                                               │
│  output "endpoint" {                                                             │
│    value = google_container_cluster.cluster.endpoint                             │
│  }                                                                               │
└─────────────────────────────────────────────────────────────────────────────────┘
                                        │
                                        │ These outputs are used by...
                                        ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│  main.tf                                                                         │
│  ───────                                                                         │
│  module "fleet" {                                                                │
│    source = "./modules/fleet"                                                    │
│                                                                                  │
│    clusters = {                                                                  │
│      for k, v in module.gke_clusters : k => {                                   │
│        id       = v.cluster_id        # ← From gke-cluster output               │
│        location = v.location          # ← From gke-cluster output               │
│        endpoint = v.endpoint          # ← From gke-cluster output               │
│      }                                                                           │
│    }                                                                             │
│  }                                                                               │
└─────────────────────────────────────────────────────────────────────────────────┘
                                        │
                                        │ Fleet module uses cluster data to...
                                        ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│  modules/fleet/main.tf                                                           │
│  ─────────────────────                                                           │
│  resource "google_gke_hub_membership" "membership" {                             │
│    for_each = var.clusters                                                       │
│                                                                                  │
│    membership_id = each.key                                                      │
│    endpoint {                                                                    │
│      gke_cluster {                                                               │
│        resource_link = each.value.id   # ← Uses cluster ID from gke-cluster     │
│      }                                                                           │
│    }                                                                             │
│  }                                                                               │
└─────────────────────────────────────────────────────────────────────────────────┘
```

### Complete Deployment Example

```bash
# Step 1: Initialize - Downloads providers & configures backend
$ terraform init \
    -backend-config="bucket=bold-lantern-480305-k3-tf-state" \
    -backend-config="prefix=gke-platform/dev"

# Output:
# Initializing modules...
# - gke_clusters in modules/gke-cluster
# - fleet in modules/fleet
# - cloud_nat in modules/nat
# - load_balancer in modules/load-balancer
#
# Initializing the backend...
# Successfully configured the backend "gcs"!

# Step 2: Plan - Shows what will be created
$ terraform plan

# Output:
# Plan: 45 to add, 0 to change, 0 to destroy.
#
# Resources to create:
#   + google_project_service.apis (13 APIs)
#   + google_artifact_registry_repository.ping_iam
#   + module.gke_clusters["gke-asia"].google_service_account.gke_node_sa
#   + module.gke_clusters["gke-asia"].google_container_cluster.cluster
#   + module.gke_clusters["gke-asia"].google_container_node_pool.primary
#   + module.gke_clusters["gke-europe"].google_service_account.gke_node_sa
#   + module.gke_clusters["gke-europe"].google_container_cluster.cluster
#   + module.gke_clusters["gke-europe"].google_container_node_pool.primary
#   + module.cloud_nat["asia-southeast1"].google_compute_router.router
#   + module.cloud_nat["asia-southeast1"].google_compute_router_nat.nat
#   + module.cloud_nat["europe-west1"].google_compute_router.router
#   + module.cloud_nat["europe-west1"].google_compute_router_nat.nat
#   + module.fleet.google_gke_hub_fleet.fleet
#   + module.fleet.google_gke_hub_membership.membership["gke-asia"]
#   + module.fleet.google_gke_hub_membership.membership["gke-europe"]
#   + module.fleet.google_gke_hub_feature.mesh
#   + module.fleet.google_gke_hub_feature.mcs
#   + module.fleet.google_gke_hub_feature.mci
#   + module.load_balancer.google_compute_global_address.lb_ip
#   ... and more

# Step 3: Apply - Creates everything
$ terraform apply

# Output:
# google_project_service.apis["container.googleapis.com"]: Creating...
# google_project_service.apis["compute.googleapis.com"]: Creating...
# ...
# module.gke_clusters["gke-asia"].google_container_cluster.cluster: Creating...
# module.gke_clusters["gke-europe"].google_container_cluster.cluster: Creating...
# ...
# Apply complete! Resources: 45 added, 0 changed, 0 destroyed.
#
# Outputs:
# cluster_endpoints = {
#   "gke-asia"   = "34.xxx.xxx.xxx"
#   "gke-europe" = "35.xxx.xxx.xxx"
# }
```

---

## Quick Start

### 1. Clone Repository

```bash
git clone https://github.com/0019-KDU/gcp-gke-platform-terraform.git
cd gcp-gke-platform-terraform
```

### 2. Configure Variables

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`:
```hcl
project_id = "your-project-id"
region     = "asia-southeast1"
vpc_name   = "your-vpc-name"

clusters = {
  "gke-asia" = {
    region             = "asia-southeast1"
    subnet_name        = "subnet-asia"
    pod_range_name     = "pods-asia"
    service_range_name = "services-asia"
    node_count         = 1
    machine_type       = "e2-standard-2"
    disk_size_gb       = 50
  }
  "gke-europe" = {
    region             = "europe-west1"
    subnet_name        = "subnet-europe"
    pod_range_name     = "pods-europe"
    service_range_name = "services-europe"
    node_count         = 1
    machine_type       = "e2-standard-2"
    disk_size_gb       = 50
  }
}

environment = "dev"
```

### 3. Initialize Terraform

```bash
# Authenticate
gcloud auth application-default login

# Initialize with remote backend
terraform init \
  -backend-config="bucket=YOUR_STATE_BUCKET" \
  -backend-config="prefix=gke-platform/dev"
```

### 4. Deploy

```bash
# Preview changes
terraform plan

# Apply changes
terraform apply
```

### 5. Connect to Clusters

```bash
# Get credentials for Asia cluster
gcloud container clusters get-credentials gke-asia \
  --region asia-southeast1 \
  --project your-project-id

# Get credentials for Europe cluster
gcloud container clusters get-credentials gke-europe \
  --region europe-west1 \
  --project your-project-id
```

---

## CI/CD Pipelines

### Pipeline Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              CI/CD WORKFLOWS                                 │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│  Pull Request   │────►│  terraform-ci   │────►│   Infracost     │
│   Created       │     │  (Validate)     │     │   (Cost Est.)   │
└─────────────────┘     └─────────────────┘     └─────────────────┘
                                │
                                ▼
                        ┌─────────────────┐
                        │  terraform-docs │
                        │  (Update Docs)  │
                        └─────────────────┘

┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│  Manual Trigger │────►│terraform-deploy │────►│  Slack Notify   │
│  (Actions Tab)  │     │ (plan/apply/    │     │                 │
└─────────────────┘     │  destroy)       │     └─────────────────┘
                        └─────────────────┘

┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│  Daily 6 AM UTC │────►│  drift-detect   │────►│  GitHub Issue   │
│  (Scheduled)    │     │                 │     │  (if drift)     │
└─────────────────┘     └─────────────────┘     └─────────────────┘
```

### 1. Terraform CI (`terraform-ci.yml`)

**Triggers:** Pull requests to `main`

| Step | Description |
|------|-------------|
| Security Scan | Checkov & tfsec scanning |
| Format Check | `terraform fmt -check` |
| Validate | `terraform validate` |
| Plan | Generate plan for dev |

### 2. Terraform Deploy (`terraform-deploy.yml`)

**Triggers:** Manual (workflow_dispatch)

**Inputs:**
| Input | Options | Description |
|-------|---------|-------------|
| environment | dev, staging, prod | Target environment |
| action | plan, apply, destroy | Terraform action |
| auto_approve | true, false | Skip confirmation |

### 3. Infracost (`infracost.yml`)

**Triggers:** Pull requests, pushes to main

Provides cost estimation comments on PRs showing:
- Current monthly cost
- Cost changes from PR
- Cost breakdown by resource

### 4. Drift Detection (`terraform-drift-detection.yml`)

**Triggers:** Daily at 6 AM UTC, manual

- Runs `terraform plan` to detect drift
- Creates GitHub issue if drift detected
- Supports filtering by environment

### 5. Terraform Docs (`terraform-docs.yml`)

**Triggers:** Pull requests with `.tf` changes

- Auto-generates documentation
- Updates README.md files in modules

---

## Environments

### Environment Configuration

| Environment | State Prefix | GitHub Environment |
|-------------|--------------|-------------------|
| dev | `gke-platform/dev` | `dev` |
| staging | `gke-platform/staging` | `staging` |
| prod | `gke-platform/prod` | `production` |

### State Isolation

```
GCS Bucket: bold-lantern-480305-k3-tf-state
│
├── gke-platform/
│   ├── dev/
│   │   └── default.tfstate      # Dev environment state
│   ├── staging/
│   │   └── default.tfstate      # Staging environment state
│   └── prod/
│       └── default.tfstate      # Production environment state
```

---

## Cost Management

### Infracost Setup

1. Get free API key: https://www.infracost.io/
2. Add `INFRACOST_API_KEY` to GitHub secrets
3. Infracost runs automatically on PRs

### Estimated Costs

| Resource | Quantity | Monthly Cost |
|----------|----------|--------------|
| GKE Clusters (management) | 2 | Free |
| Compute (e2-standard-2) | 2-6 nodes | ~$100-300 |
| Cloud NAT | 2 | ~$30 |
| Load Balancer (Global) | 1 | ~$20 |
| Artifact Registry | 1 | ~$5 |
| **Total (Dev)** | | **~$150-350/month** |

> 💡 Use Infracost to get accurate estimates for your configuration

---

## Security

### Security Features

| Feature | Implementation |
|---------|----------------|
| **Private Clusters** | Nodes have no public IPs |
| **Workload Identity** | Pod-to-GCP auth without keys |
| **mTLS** | Automatic encryption via Service Mesh |
| **Shielded Nodes** | Secure boot, integrity monitoring |
| **Network Policies** | Datapath V2 with eBPF |
| **RBAC** | Kubernetes role-based access |

### Secrets Management

- GCP credentials stored in GitHub Secrets
- Service account keys rotated regularly
- Terraform state encrypted in GCS

---

## Troubleshooting

### Common Issues

#### 1. "Resource already exists" Error

**Cause:** Resources exist in GCP but not in Terraform state

**Solution:** Import existing resources
```bash
terraform import 'module.gke_clusters["gke-asia"].google_container_cluster.cluster' \
  'projects/PROJECT_ID/locations/asia-southeast1/clusters/gke-asia'
```

#### 2. State Lock Error

**Cause:** Previous Terraform run didn't complete

**Solution:**
```bash
terraform force-unlock LOCK_ID
```

#### 3. Quota Exceeded

**Cause:** GCP quota limits reached

**Solution:**
- Check quotas: GCP Console > IAM & Admin > Quotas
- Request quota increase

#### 4. Authentication Failed

**Cause:** Invalid or expired credentials

**Solution:**
```bash
gcloud auth application-default login
gcloud auth login
```

### Useful Commands

```bash
# Check Terraform state
terraform state list

# Show specific resource
terraform state show 'module.gke_clusters["gke-asia"].google_container_cluster.cluster'

# Refresh state from GCP
terraform refresh

# Validate configuration
terraform validate

# Format code
terraform fmt -recursive
```

---

## Contributing

### Workflow

1. Create feature branch from `main`
2. Make changes
3. Push and create PR
4. Wait for CI checks (terraform-ci, infracost)
5. Get code review
6. Merge to `main`
7. Deploy via `terraform-deploy` workflow

### Commit Message Format

```
type: description

Types:
- feat: New feature
- fix: Bug fix
- docs: Documentation
- refactor: Code refactoring
- test: Tests
- chore: Maintenance
```

---

## License

MIT License - See [LICENSE](LICENSE) for details.

---

## References

- [GKE Documentation](https://cloud.google.com/kubernetes-engine/docs)
- [Cloud Service Mesh](https://cloud.google.com/service-mesh/docs)
- [Multi-Cluster Services](https://cloud.google.com/kubernetes-engine/docs/how-to/multi-cluster-services)
- [Terraform GCP Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [Infracost](https://www.infracost.io/docs/)
