# ============================================================================
# Cloud NAT Module - Variables
# ============================================================================

variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region for the Cloud Router and NAT"
  type        = string
}

variable "vpc_name" {
  description = "The VPC network name"
  type        = string
}

variable "router_name" {
  description = "Base name for the Cloud Router and NAT resources"
  type        = string
}
