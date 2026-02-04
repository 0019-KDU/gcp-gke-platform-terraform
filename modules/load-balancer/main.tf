# ============================================================================
# Load Balancer Module - Main Configuration
# External Application Load Balancer with Multi-Cluster Gateway
# ============================================================================

# ============================================================================
# Static IP for Load Balancer
# ============================================================================
resource "google_compute_global_address" "lb_ip" {
  name         = "mesh-lb-ip"
  project      = var.project_id
  address_type = "EXTERNAL"
  ip_version   = "IPV4"
}

# ============================================================================
# SSL Certificate (Self-managed for study - use managed in production)
# ============================================================================
resource "google_compute_managed_ssl_certificate" "mesh_cert" {
  count = var.domain_name != "" ? 1 : 0

  name    = "mesh-certificate"
  project = var.project_id

  managed {
    domains = [var.domain_name]
  }
}

# ============================================================================
# NOTE: Gateway and HTTPRoute manifests should be created separately
# based on YOUR application requirements.
# 
# Example manifests are NOT included - you need to create:
# 1. Gateway resource pointing to this static IP
# 2. HTTPRoute resources for your services
# 3. HealthCheckPolicy for your services
#
# See: https://cloud.google.com/kubernetes-engine/docs/how-to/gatewayclass-capabilities
# ============================================================================
