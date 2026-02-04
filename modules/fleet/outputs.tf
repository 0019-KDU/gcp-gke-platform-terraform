# ============================================================================
# Fleet Module - Outputs
# ============================================================================

output "fleet_id" {
  description = "Fleet ID"
  value       = google_gke_hub_fleet.fleet.id
}

output "membership_ids" {
  description = "Map of membership IDs"
  value = {
    for name, membership in google_gke_hub_membership.membership : name => membership.id
  }
}

output "mcs_feature_id" {
  description = "Multi-Cluster Services feature ID"
  value       = var.enable_multi_cluster_services ? google_gke_hub_feature.mcs[0].id : null
}

output "mci_feature_id" {
  description = "Multi-Cluster Ingress feature ID"
  value       = google_gke_hub_feature.mci.id
}

output "mesh_feature_id" {
  description = "Service Mesh feature ID"
  value       = google_gke_hub_feature.mesh.id
}
