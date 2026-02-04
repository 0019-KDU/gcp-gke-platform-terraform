# ============================================================================
# GKE Cluster Module - Variables
# ============================================================================

variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "cluster_name" {
  description = "Name of the GKE cluster"
  type        = string
}

variable "region" {
  description = "GCP region for the cluster"
  type        = string
}

variable "vpc_name" {
  description = "Name of the VPC network"
  type        = string
}

variable "subnet_name" {
  description = "Name of the subnet"
  type        = string
}

variable "pod_range_name" {
  description = "Name of the secondary range for pods"
  type        = string
}

variable "service_range_name" {
  description = "Name of the secondary range for services"
  type        = string
}

variable "master_ipv4_cidr_block" {
  description = "CIDR block for the GKE master network (/28 required)"
  type        = string
}

variable "node_count" {
  description = "Number of nodes per zone"
  type        = number
  default     = 1
}

variable "machine_type" {
  description = "Machine type for nodes"
  type        = string
  default     = "e2-medium"
}

variable "disk_size_gb" {
  description = "Disk size in GB for nodes"
  type        = number
  default     = 30
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
