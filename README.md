# Multi-Region GKE Platform with Service Mesh

This project implements a multi-region GKE architecture with Cloud Service Mesh for high availability and service discovery across regions.

## Architecture Overview

```
                    ┌─────────────────────────────────────────────────────────────┐
                    │                     Google Cloud                             │
                    │  ┌─────────────────────────────────────────────────────────┐│
                    │  │           External Application Load Balancer             ││
                    │  │                   (Global Static IP)                     ││
                    │  └─────────────────────┬───────────────────────────────────┘│
                    │                        │                                     │
                    │  ┌─────────────────────┴─────────────────────────┐          │
                    │  │              Cloud Service Mesh                │          │
                    │  │         (Multi-Cluster Service Discovery)      │          │
                    │  └─────────────────────┬─────────────────────────┘          │
                    │                        │                                     │
       ┌────────────┼────────────────────────┼────────────────────────────────────┤
       │            │                        │                                     │
       │  Region 1  │              Region 2  │                                     │
       │  (Asia)    │              (Europe)  │                                     │
       │            │                        │                                     │
│ ┌────┴─────────┐  │  ┌────────────────────┴┐                                    │
│ │ GKE Cluster 1│  │  │  GKE Cluster 2      │                                    │
│ │   (mTLS)     │  │  │   (mTLS)            │                                    │
│ │              │◄─┼──┼─►                   │                                    │
│ │ Your Apps    │  │  │  Your Apps          │                                    │
│ └──────────────┘  │  └─────────────────────┘                                    │
│                   │                                                              │
└───────────────────┴──────────────────────────────────────────────────────────────┘
```

## Features

- **Multi-Region Deployment**: GKE clusters in Asia (asia-southeast1) and Europe (europe-west1)
- **Cloud Service Mesh**: Managed service mesh with automatic mTLS
- **Multi-Cluster Services (MCS)**: Service discovery across clusters
- **Multi-Cluster Gateway**: Global load balancing with Gateway API
- **Security Best Practices**:
  - Workload Identity
  - Private clusters
  - mTLS encryption
- **Lightweight Configuration**: Optimized for study/learning purposes

## Prerequisites

1. **GCP Account** with billing enabled
2. **gcloud CLI** installed and configured
3. **Terraform** >= 1.5.0
4. **kubectl** installed
5. **Existing VPC** with two subnets (already created based on your setup)

## Folder Structure

```
gcp-gke-platform-terraform/
├── main.tf                     # Root module configuration
├── variables.tf                # Input variables
├── outputs.tf                  # Output values
├── providers.tf                # Provider configuration
├── versions.tf                 # Terraform and provider versions
├── terraform.tfvars.example    # Example variable values
├── modules/
│   ├── gke-cluster/           # GKE cluster module
│   ├── fleet/                  # Fleet & MCS module
│   ├── service-mesh/          # Service Mesh documentation
│   └── load-balancer/         # Static IP & SSL cert
└── scripts/
    ├── deploy.sh               # Deployment script (Linux/Mac)
    └── deploy.ps1              # Deployment script (Windows)
```

## Quick Start

### 1. Configure Variables

```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your project ID
```

### 2. Update Your VPC Secondary Ranges

```bash
# Add secondary ranges to asia subnet
gcloud compute networks subnets update subnet-asia \
  --region=asia-southeast1 \
  --add-secondary-ranges=pods=10.30.0.0/16,services=10.31.0.0/20

# Add secondary ranges to europe subnet
gcloud compute networks subnets update subnet-europe \
  --region=europe-west1 \
  --add-secondary-ranges=pods=10.50.0.0/16,services=10.51.0.0/20
```

### 3. Deploy Infrastructure

```bash
terraform init
terraform plan -var="project_id=your-project-id"
terraform apply -var="project_id=your-project-id"
```

### 4. Configure kubectl

```bash
# Asia cluster
gcloud container clusters get-credentials gke-asia \
  --region asia-southeast1 --project your-project-id

# Europe cluster
gcloud container clusters get-credentials gke-europe \
  --region europe-west1 --project your-project-id
```

## What This Creates (Terraform)

| Resource | Description |
|----------|-------------|
| 2 GKE Clusters | Private, VPC-native clusters with Workload Identity |
| Fleet | Registers clusters for multi-cluster features |
| MCS Feature | Enables cross-cluster service discovery |
| Service Mesh | Managed Cloud Service Mesh with mTLS |
| Static IP | Global IP for load balancer |

## What You Need to Create (kubectl/GitOps)

After Terraform, deploy your own:
- Application Deployments
- Services with ServiceExport
- Gateway and HTTPRoute
- PeerAuthentication (mTLS policies)
- AuthorizationPolicy (access control)

## Cost Optimization

| Resource | Quantity | Est. Cost |
|----------|----------|-----------|
| GKE Management | 2 | $0 (Free) |
| Compute (e2-medium) | 2-4 nodes | ~$50-100 |
| Load Balancer | 1 Global | ~$20 |
| **Total** | | **~$70-120/month** |

## Cleanup

```bash
terraform destroy -var="project_id=your-project-id"
```

## References

- [Cloud Service Mesh](https://cloud.google.com/service-mesh/docs)
- [Multi-Cluster Services](https://cloud.google.com/kubernetes-engine/docs/how-to/multi-cluster-services)
- [Gateway API](https://cloud.google.com/kubernetes-engine/docs/concepts/gateway-api)
