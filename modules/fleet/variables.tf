# ============================================================================
# Fleet Module - Variables
# ============================================================================

variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "project_number" {
  description = "GCP Project Number"
  type        = string
}

variable "clusters" {
  description = "Map of cluster configurations"
  type = map(object({
    id       = string
    location = string
    endpoint = string
  }))
}

variable "mci_config_cluster" {
  description = "Cluster name that hosts the Multi-Cluster Ingress config"
  type        = string
}

variable "enable_multi_cluster_services" {
  description = "Enable Multi-Cluster Services feature"
  type        = bool
  default     = true
}

variable "labels" {
  description = "Labels to apply to resources"
  type        = map(string)
  default     = {}
}
