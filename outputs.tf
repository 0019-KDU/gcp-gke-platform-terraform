# ============================================================================
# Outputs
# ============================================================================

# ============================================================================
# GKE Cluster Outputs
# ============================================================================
output "cluster_endpoints" {
  description = "GKE cluster endpoints"
  value = {
    for name, cluster in module.gke_clusters : name => cluster.endpoint
  }
  sensitive = true
}

output "cluster_names" {
  description = "GKE cluster names"
  value = {
    for name, cluster in module.gke_clusters : name => cluster.cluster_name
  }
}

output "cluster_locations" {
  description = "GKE cluster locations"
  value = {
    for name, cluster in module.gke_clusters : name => cluster.location
  }
}

# ============================================================================
# Fleet Outputs
# ============================================================================
output "fleet_membership_ids" {
  description = "Fleet membership IDs"
  value       = module.fleet.membership_ids
}

# ============================================================================
# Load Balancer Outputs
# ============================================================================
output "load_balancer_ip" {
  description = "External Application Load Balancer IP"
  value       = module.load_balancer.external_ip
}

# ============================================================================
# Kubectl Config Commands
# ============================================================================
output "kubectl_config_commands" {
  description = "Commands to configure kubectl for each cluster"
  value = {
    for name, cluster in module.gke_clusters : name =>
    "gcloud container clusters get-credentials ${cluster.cluster_name} --region ${cluster.location} --project ${var.project_id}"
  }
}

# ============================================================================
# Feature Status
# ============================================================================
output "service_mesh_status" {
  description = "Service Mesh enablement status (managed via Fleet)"
  value       = "Enabled (Managed)"
}

output "mcs_status" {
  description = "Multi-Cluster Services status"
  value       = var.enable_multi_cluster_services ? "Enabled" : "Disabled"
}
