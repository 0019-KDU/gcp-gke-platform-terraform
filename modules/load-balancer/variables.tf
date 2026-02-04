# ============================================================================
# Load Balancer Module - Variables
# ============================================================================

variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "vpc_name" {
  description = "VPC network name"
  type        = string
}

variable "clusters" {
  description = "Map of cluster configurations"
  type = map(object({
    name     = string
    location = string
    endpoint = string
    ca_cert  = string
  }))
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "labels" {
  description = "Labels to apply to resources"
  type        = map(string)
  default     = {}
}

variable "domain_name" {
  description = "Domain name for TLS certificate"
  type        = string
  default     = ""
}
