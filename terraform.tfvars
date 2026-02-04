# ============================================================================
# GCP Project Configuration
# Note: project_id can be overridden by TF_VAR_project_id in CI/CD
# ============================================================================
project_id = "bold-lantern-480305-k3"
region     = "asia-southeast1"

# ============================================================================
# Existing VPC Configuration
# ============================================================================
vpc_name = "mesh-vpc"

# ============================================================================
# GKE Cluster Configuration
# ============================================================================
clusters = {
  "gke-asia" = {
    region             = "asia-southeast1"
    subnet_name        = "subnet-asia"
    pod_range_name     = "pods-asia"     # 10.30.0.0/16
    service_range_name = "services-asia" # 10.40.0.0/20
    node_count         = 1
    machine_type       = "e2-standard-2" # 2 vCPU, 8GB (fits 16 CPU quota)
    disk_size_gb       = 50
  }
  "gke-europe" = {
    region             = "europe-west1"
    subnet_name        = "subnet-europe"
    pod_range_name     = "pods-europe"     # 10.50.0.0/16
    service_range_name = "services-europe" # 10.60.0.0/20
    node_count         = 1
    machine_type       = "e2-standard-2" # 2 vCPU, 8GB (fits 16 CPU quota)
    disk_size_gb       = 50
  }
}

# ============================================================================
# MCI Configuration
# ============================================================================
mci_config_cluster = "gke-asia"

# ============================================================================
# Environment
# ============================================================================
environment = "dev"

# ============================================================================
# Labels
# ============================================================================
labels = {
  project     = "ping-iam-gke"
  environment = "dev"
  managed-by  = "terraform"
}
