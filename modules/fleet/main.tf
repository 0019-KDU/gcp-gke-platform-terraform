# ============================================================================
# Fleet Module - Main Configuration
# Multi-cluster Fleet Management with Multi-Cluster Services (MCS)
# ============================================================================

# ============================================================================
# Fleet (Hub) - Container for cluster memberships
# ============================================================================
resource "google_gke_hub_fleet" "fleet" {
  project      = var.project_id
  display_name = "mesh-fleet"

  default_cluster_config {
    security_posture_config {
      mode               = "BASIC"
      vulnerability_mode = "VULNERABILITY_BASIC"
    }
  }
}

# ============================================================================
# Fleet Memberships - Register clusters to the fleet
# ============================================================================
resource "google_gke_hub_membership" "membership" {
  for_each = var.clusters

  membership_id = each.key
  project       = var.project_id
  location      = "global"

  endpoint {
    gke_cluster {
      resource_link = "//container.googleapis.com/${each.value.id}"
    }
  }

  authority {
    issuer = "https://container.googleapis.com/v1/${each.value.id}"
  }

  depends_on = [google_gke_hub_fleet.fleet]
}

# ============================================================================
# Multi-Cluster Services Feature
# ============================================================================
resource "google_gke_hub_feature" "mcs" {
  count = var.enable_multi_cluster_services ? 1 : 0

  name     = "multiclusterservicediscovery"
  project  = var.project_id
  location = "global"

  depends_on = [google_gke_hub_membership.membership]
}

# ============================================================================
# IAM - MCS Importer Service Account Permissions
# Required for MCS to function with Workload Identity
# ============================================================================
resource "google_project_iam_member" "mcs_importer" {
  for_each = var.enable_multi_cluster_services ? var.clusters : {}

  project = var.project_id
  role    = "roles/compute.networkViewer"
  member  = "principal://iam.googleapis.com/projects/${var.project_number}/locations/global/workloadIdentityPools/${var.project_id}.svc.id.goog/subject/ns/gke-mcs/sa/gke-mcs-importer"

  depends_on = [google_gke_hub_feature.mcs]
}

# ============================================================================
# Multi-Cluster Ingress Feature
# Enables Gateway API for multi-cluster load balancing
# ============================================================================
resource "google_gke_hub_feature" "mci" {
  name     = "multiclusteringress"
  project  = var.project_id
  location = "global"

  spec {
    multiclusteringress {
      config_membership = google_gke_hub_membership.membership[var.mci_config_cluster].id
    }
  }

  depends_on = [google_gke_hub_membership.membership]
}

# ============================================================================
# Service Mesh Feature (Managed Cloud Service Mesh)
# ============================================================================
resource "google_gke_hub_feature" "mesh" {
  name     = "servicemesh"
  project  = var.project_id
  location = "global"

  depends_on = [google_gke_hub_membership.membership]
}

# ============================================================================
# Configure Service Mesh for each cluster membership
# ============================================================================
resource "google_gke_hub_feature_membership" "mesh_membership" {
  for_each = var.clusters

  project    = var.project_id
  location   = "global"
  feature    = google_gke_hub_feature.mesh.name
  membership = google_gke_hub_membership.membership[each.key].membership_id

  mesh {
    management = "MANAGEMENT_AUTOMATIC" # Managed Service Mesh
  }

  depends_on = [google_gke_hub_feature.mesh]
}
