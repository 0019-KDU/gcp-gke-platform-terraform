# ============================================================================
# GCS Backend Configuration for Terraform State
# ============================================================================
# This file configures remote state storage in Google Cloud Storage
# 
# Usage: terraform init -backend-config=backend.hcl
# Or use environment-specific configs during CI/CD
# ============================================================================

bucket = "your-terraform-state-bucket"
prefix = "gke-platform"
