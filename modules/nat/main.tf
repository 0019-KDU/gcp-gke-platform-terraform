# ============================================================================
# Cloud NAT Module - Enable Outbound Internet for Private GKE Nodes
# ============================================================================
# Private GKE nodes have no public IPs and cannot reach the internet without
# Cloud NAT. This is required for:
# - Pulling container images from external registries
# - Fetching Ping Identity evaluation licenses
# - Any outbound connectivity from pods
# ============================================================================

# ============================================================================
# Cloud Router - Required for Cloud NAT
# ============================================================================
resource "google_compute_router" "router" {
  name    = "${var.router_name}-router"
  project = var.project_id
  region  = var.region
  network = var.vpc_name

  bgp {
    asn = 64514
  }
}

# ============================================================================
# Cloud NAT - Enable outbound internet for private nodes
# ============================================================================
resource "google_compute_router_nat" "nat" {
  name                               = "${var.router_name}-nat"
  project                            = var.project_id
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }

  # Timeouts for NAT connections
  min_ports_per_vm                    = 64
  max_ports_per_vm                    = 4096
  enable_dynamic_port_allocation      = true
  enable_endpoint_independent_mapping = false

  # UDP idle timeout
  udp_idle_timeout_sec = 30

  # TCP timeouts
  tcp_established_idle_timeout_sec = 1200
  tcp_transitory_idle_timeout_sec  = 30
  tcp_time_wait_timeout_sec        = 120

  # ICMP idle timeout
  icmp_idle_timeout_sec = 30
}
