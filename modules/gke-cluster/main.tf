# ============================================================================
# GKE Cluster Module - Main Configuration
# ============================================================================

# ============================================================================
# Data Sources
# ============================================================================
data "google_compute_subnetwork" "subnet" {
  name    = var.subnet_name
  region  = var.region
  project = var.project_id
}

# ============================================================================
# Service Account for GKE Nodes
# ============================================================================
resource "google_service_account" "gke_node_sa" {
  account_id   = "${var.cluster_name}-node-sa"
  display_name = "GKE Node Service Account for ${var.cluster_name}"
  project      = var.project_id
}

# ============================================================================
# IAM Bindings for Node Service Account
# ============================================================================
resource "google_project_iam_member" "gke_node_roles" {
  for_each = toset([
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer",
    "roles/stackdriver.resourceMetadata.writer",
    "roles/artifactregistry.reader",
    "roles/container.nodeServiceAccount",
  ])

  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.gke_node_sa.email}"
}

# ============================================================================
# GKE Cluster
# ============================================================================
resource "google_container_cluster" "cluster" {
  provider = google-beta

  name     = var.cluster_name
  location = var.region
  project  = var.project_id

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1
  deletion_protection      = false

  # ============================================================================
  # Network Configuration
  # ============================================================================
  network    = var.vpc_name
  subnetwork = var.subnet_name

  # VPC-native cluster with alias IP ranges
  ip_allocation_policy {
    cluster_secondary_range_name  = var.pod_range_name
    services_secondary_range_name = var.service_range_name
  }

  # ============================================================================
  # Security Configuration
  # ============================================================================
  # Workload Identity - Required for Service Mesh
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  # Private cluster configuration for security
  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = var.master_ipv4_cidr_block
  }

  # Master authorized networks
  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = "0.0.0.0/0"  # For study purposes - restrict in production
      display_name = "All networks"
    }
  }

  # ============================================================================
  # Cluster Features
  # ============================================================================
  # Enable Dataplane V2 (eBPF-based dataplane) - Recommended for Service Mesh
  datapath_provider = "ADVANCED_DATAPATH"

  # Gateway API support for multi-cluster ingress
  gateway_api_config {
    channel = "CHANNEL_STANDARD"
  }

  # DNS configuration
  dns_config {
    cluster_dns        = "CLOUD_DNS"
    cluster_dns_scope  = "VPC_SCOPE"
    cluster_dns_domain = "${var.cluster_name}.local"
  }

  # ============================================================================
  # Add-ons Configuration
  # ============================================================================
  addons_config {
    http_load_balancing {
      disabled = false  # Required for MCS
    }
    horizontal_pod_autoscaling {
      disabled = false
    }
    gce_persistent_disk_csi_driver_config {
      enabled = true
    }
    dns_cache_config {
      enabled = true
    }
    config_connector_config {
      enabled = false  # Enable if needed
    }
  }

  # ============================================================================
  # Maintenance Window
  # ============================================================================
  maintenance_policy {
    daily_maintenance_window {
      start_time = "03:00"  # 3 AM UTC
    }
  }

  # ============================================================================
  # Logging and Monitoring
  # ============================================================================
  logging_config {
    enable_components = ["SYSTEM_COMPONENTS", "WORKLOADS"]
  }

  monitoring_config {
    enable_components = ["SYSTEM_COMPONENTS"]
    managed_prometheus {
      enabled = true
    }
  }

  # ============================================================================
  # Release Channel
  # ============================================================================
  release_channel {
    channel = "REGULAR"  # Balanced stability and features
  }

  # ============================================================================
  # Security Posture
  # ============================================================================
  security_posture_config {
    mode               = "BASIC"
    vulnerability_mode = "VULNERABILITY_BASIC"
  }

  # ============================================================================
  # Labels
  # ============================================================================
  resource_labels = merge(var.labels, {
    cluster = var.cluster_name
    region  = var.region
  })

  # ============================================================================
  # Lifecycle
  # ============================================================================
  lifecycle {
    ignore_changes = [
      node_pool,
      initial_node_count,
    ]
  }
}

# ============================================================================
# Node Pool
# ============================================================================
resource "google_container_node_pool" "primary" {
  name     = "${var.cluster_name}-primary-pool"
  location = var.region
  cluster  = google_container_cluster.cluster.name
  project  = var.project_id

  # Lightweight configuration for study purposes
  node_count = var.node_count

  # Auto-scaling configuration
  autoscaling {
    min_node_count  = 1
    max_node_count  = 3
    location_policy = "BALANCED"
  }

  # Node management
  management {
    auto_repair  = true
    auto_upgrade = true
  }

  # Upgrade settings
  upgrade_settings {
    max_surge       = 1
    max_unavailable = 0
    strategy        = "SURGE"
  }

  # ============================================================================
  # Node Configuration
  # ============================================================================
  node_config {
    machine_type = var.machine_type
    disk_size_gb = var.disk_size_gb
    disk_type    = "pd-standard"
    image_type   = "COS_CONTAINERD"

    # Service account
    service_account = google_service_account.gke_node_sa.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    # Workload Identity
    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    # Security settings
    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }

    # Labels
    labels = merge(var.labels, {
      pool = "primary"
    })

    # Taints (optional - add if needed for dedicated workloads)
    # taint {
    #   key    = "dedicated"
    #   value  = "service-mesh"
    #   effect = "NO_SCHEDULE"
    # }

    # Metadata
    metadata = {
      disable-legacy-endpoints = "true"
    }
  }

  lifecycle {
    ignore_changes = [
      node_config[0].labels,
    ]
  }
}
