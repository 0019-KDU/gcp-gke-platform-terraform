# ============================================================================
# Terraform and Provider Versions
# ============================================================================
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0.0, < 7.0.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = ">= 5.0.0, < 7.0.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.20.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.10.0"
    }
  }

  # Remote state backend - configured via -backend-config during CI/CD
  # For local development: terraform init -backend-config=backend.hcl
  # For CI/CD: terraform init -backend-config="bucket=..." -backend-config="prefix=..."
  backend "gcs" {}
}
