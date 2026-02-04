# ============================================================================
# Cloud NAT Module - Outputs
# ============================================================================

output "router_name" {
  description = "The name of the Cloud Router"
  value       = google_compute_router.router.name
}

output "router_id" {
  description = "The ID of the Cloud Router"
  value       = google_compute_router.router.id
}

output "nat_name" {
  description = "The name of the Cloud NAT"
  value       = google_compute_router_nat.nat.name
}

output "nat_id" {
  description = "The ID of the Cloud NAT"
  value       = google_compute_router_nat.nat.id
}
