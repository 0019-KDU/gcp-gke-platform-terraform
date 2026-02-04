# ============================================================================
# GCP Project Variables
# ============================================================================
variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "Primary GCP region"
  type        = string
  default     = "asia-southeast1"
}

# ============================================================================
# VPC Variables
# ============================================================================
variable "vpc_name" {
  description = "Name of the existing VPC"
  type        = string
  default     = "mesh-vpc"
}

# ============================================================================
# GKE Cluster Variables
# ============================================================================
variable "clusters" {
  description = "Map of GKE cluster configurations"
  type = map(object({
    region             = string
    subnet_name        = string
    pod_range_name     = string
    service_range_name = string
    node_count         = number
    machine_type       = string
    disk_size_gb       = number
  }))
}

# ============================================================================
# MCI (Multi-Cluster Ingress) Variables
# ============================================================================
variable "mci_config_cluster" {
  description = "Cluster name that hosts the Multi-Cluster Ingress config (Gateway API)"
  type        = string
  default     = "gke-asia"
}

# ============================================================================
# Environment Variables
# ============================================================================
variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

# ============================================================================
# Labels
# ============================================================================
variable "labels" {
  description = "Labels to apply to all resources"
  type        = map(string)
  default     = {}
}

# ============================================================================
# Multi-Cluster Services Variables
# ============================================================================
variable "enable_multi_cluster_services" {
  description = "Enable Multi-Cluster Services (MCS)"
  type        = bool
  default     = true
}
