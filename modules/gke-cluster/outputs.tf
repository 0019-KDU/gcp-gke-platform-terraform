# ============================================================================
# GKE Cluster Module - Outputs
# ============================================================================

output "cluster_id" {
  description = "Cluster ID"
  value       = google_container_cluster.cluster.id
}

output "cluster_name" {
  description = "Cluster name"
  value       = google_container_cluster.cluster.name
}

output "location" {
  description = "Cluster location (region)"
  value       = google_container_cluster.cluster.location
}

output "endpoint" {
  description = "Cluster endpoint"
  value       = google_container_cluster.cluster.endpoint
  sensitive   = true
}

output "ca_certificate" {
  description = "Cluster CA certificate"
  value       = google_container_cluster.cluster.master_auth[0].cluster_ca_certificate
  sensitive   = true
}

output "node_service_account" {
  description = "Node service account email"
  value       = google_service_account.gke_node_sa.email
}

output "workload_identity_pool" {
  description = "Workload Identity Pool"
  value       = "${var.project_id}.svc.id.goog"
}

output "cluster_self_link" {
  description = "Cluster self link"
  value       = google_container_cluster.cluster.self_link
}
