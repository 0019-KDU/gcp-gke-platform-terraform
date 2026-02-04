# ============================================================================
# Provider Configuration
# ============================================================================
provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}

# ============================================================================
# Kubernetes & Helm Providers
# NOTE: Provider blocks cannot use for_each, so these must match the cluster
# keys defined in var.clusters ("gke-asia" and "gke-europe").
# ============================================================================

# ============================================================================
# Kubernetes Provider for Asia Cluster
# ============================================================================
provider "kubernetes" {
  alias = "gke_asia"

  host                   = "https://${module.gke_clusters["gke-asia"].endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke_clusters["gke-asia"].ca_certificate)
}

# ============================================================================
# Kubernetes Provider for Europe Cluster
# ============================================================================
provider "kubernetes" {
  alias = "gke_europe"

  host                   = "https://${module.gke_clusters["gke-europe"].endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke_clusters["gke-europe"].ca_certificate)
}

# ============================================================================
# Helm Provider for Asia Cluster
# ============================================================================
provider "helm" {
  alias = "gke_asia"

  kubernetes {
    host                   = "https://${module.gke_clusters["gke-asia"].endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(module.gke_clusters["gke-asia"].ca_certificate)
  }
}

# ============================================================================
# Helm Provider for Europe Cluster
# ============================================================================
provider "helm" {
  alias = "gke_europe"

  kubernetes {
    host                   = "https://${module.gke_clusters["gke-europe"].endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(module.gke_clusters["gke-europe"].ca_certificate)
  }
}

# ============================================================================
# Data Sources
# ============================================================================
data "google_client_config" "default" {}

data "google_project" "project" {
  project_id = var.project_id
}
