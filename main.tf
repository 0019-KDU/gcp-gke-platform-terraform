# ============================================================================
# Main Configuration - Multi-Region GKE Platform with Service Mesh
# ============================================================================

# ============================================================================
# Local values for computed configurations
# ============================================================================
locals {
  # Generate unique /28 CIDR blocks for GKE master networks
  # Each cluster needs a non-overlapping /28 block
  cluster_master_cidrs = {
    for idx, name in sort(keys(var.clusters)) :
    name => cidrsubnet("172.16.0.0/16", 12, idx) # /28 blocks: 172.16.0.0/28, 172.16.0.16/28, ...
  }
}

# ============================================================================
# Enable Required APIs
# ============================================================================
resource "google_project_service" "apis" {
  for_each = toset([
    "container.googleapis.com",           # GKE
    "gkehub.googleapis.com",              # Fleet Management
    "multiclusterservicediscovery.googleapis.com", # Multi-Cluster Services
    "trafficdirector.googleapis.com",     # Traffic Director for MCS
    "dns.googleapis.com",                 # Cloud DNS for MCS
    "connectgateway.googleapis.com",      # Connect Gateway
    "mesh.googleapis.com",                # Cloud Service Mesh
    "meshconfig.googleapis.com",          # Mesh Config
    "cloudresourcemanager.googleapis.com", # Resource Manager
    "iam.googleapis.com",                 # IAM
    "compute.googleapis.com",             # Compute Engine
    "monitoring.googleapis.com",          # Cloud Monitoring
    "logging.googleapis.com",             # Cloud Logging
    "artifactregistry.googleapis.com",    # Artifact Registry for container images
  ])

  project            = var.project_id
  service            = each.key
  disable_on_destroy = false
}

# ============================================================================
# Artifact Registry for Container Images
# ============================================================================
resource "google_artifact_registry_repository" "ping_iam" {
  project       = var.project_id
  location      = var.region
  repository_id = "ping-iam"
  description   = "Container images for Ping IAM Lab"
  format        = "DOCKER"

  labels = var.labels

  depends_on = [google_project_service.apis]
}

# ============================================================================
# GKE Clusters
# ============================================================================
module "gke_clusters" {
  source   = "./modules/gke-cluster"
  for_each = var.clusters

  project_id            = var.project_id
  cluster_name          = each.key
  region                = each.value.region
  vpc_name              = var.vpc_name
  subnet_name           = each.value.subnet_name
  pod_range_name        = each.value.pod_range_name
  service_range_name    = each.value.service_range_name
  master_ipv4_cidr_block = local.cluster_master_cidrs[each.key]
  node_count            = each.value.node_count
  machine_type          = each.value.machine_type
  disk_size_gb          = each.value.disk_size_gb
  environment           = var.environment
  labels                = var.labels

  depends_on = [google_project_service.apis]
}

# ============================================================================
# GKE Fleet (Hub) - Register Clusters
# ============================================================================
module "fleet" {
  source = "./modules/fleet"

  project_id   = var.project_id
  project_number = data.google_project.project.number
  clusters     = {
    for name, cluster in module.gke_clusters : name => {
      id       = cluster.cluster_id
      location = cluster.location
      endpoint = cluster.endpoint
    }
  }
  mci_config_cluster            = var.mci_config_cluster
  enable_multi_cluster_services = var.enable_multi_cluster_services

  depends_on = [module.gke_clusters]
}

# ============================================================================
# External Application Load Balancer (Multi-Cluster Gateway)
# ============================================================================
module "load_balancer" {
  source = "./modules/load-balancer"

  project_id = var.project_id
  vpc_name   = var.vpc_name
  clusters   = {
    for name, cluster in module.gke_clusters : name => {
      name     = name
      location = cluster.location
      endpoint = cluster.endpoint
      ca_cert  = cluster.ca_certificate
    }
  }
  environment = var.environment
  labels      = var.labels

  depends_on = [module.fleet]
}
# ============================================================================
# Cloud NAT - Enable Outbound Internet for Private GKE Nodes
# ============================================================================
# Private GKE nodes require Cloud NAT to reach external services like:
# - Ping Identity license server (license.pingidentity.com)
# - External container registries
# - Any outbound internet connectivity
# ============================================================================
module "cloud_nat" {
  source   = "./modules/nat"
  for_each = toset(distinct([for name, cluster in var.clusters : cluster.region]))

  project_id  = var.project_id
  region      = each.key
  vpc_name    = var.vpc_name
  router_name = "gke-${each.key}"

  depends_on = [google_project_service.apis]
}