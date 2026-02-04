# ============================================================================
# Load Balancer Module - Outputs
# ============================================================================

output "external_ip" {
  description = "External IP address of the load balancer"
  value       = google_compute_global_address.lb_ip.address
}

output "external_ip_name" {
  description = "Name of the external IP resource"
  value       = google_compute_global_address.lb_ip.name
}

output "ssl_certificate_id" {
  description = "SSL certificate ID (if created)"
  value       = var.domain_name != "" ? google_compute_managed_ssl_certificate.mesh_cert[0].id : null
}
