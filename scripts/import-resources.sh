#!/bin/bash
# ============================================================================
# Terraform Import Script - Import existing GCP resources into state
# Run this script after terraform init
# ============================================================================

set -e

# Configuration
PROJECT_ID="bold-lantern-480305-k3"
STATE_BUCKET="${1:-bold-lantern-480305-k3-tf-state}"
ENVIRONMENT="${2:-dev}"

echo "============================================"
echo "Terraform Resource Import Script"
echo "============================================"
echo "Project ID: $PROJECT_ID"
echo "Environment: $ENVIRONMENT"
echo ""

# Check if terraform is available
if ! command -v terraform &> /dev/null; then
    echo "ERROR: terraform not found in PATH"
    exit 1
fi

# Initialize Terraform if bucket provided
if [ -n "$STATE_BUCKET" ]; then
    echo "Initializing Terraform..."
    terraform init \
        -backend-config="bucket=$STATE_BUCKET" \
        -backend-config="prefix=gke-platform/$ENVIRONMENT"
fi

echo ""
echo "Starting resource imports..."
echo ""

# Function to import resource
import_resource() {
    local address="$1"
    local id="$2"
    local description="$3"

    echo "Importing: $description"
    echo "  Address: $address"
    echo "  ID: $id"

    if terraform import "$address" "$id" 2>&1; then
        echo "  SUCCESS"
    else
        echo "  SKIPPED (may already exist in state)"
    fi
    echo ""
}

# Import Service Accounts
import_resource \
    'module.gke_clusters["gke-asia"].google_service_account.gke_node_sa' \
    "projects/$PROJECT_ID/serviceAccounts/gke-asia-node-sa@$PROJECT_ID.iam.gserviceaccount.com" \
    "GKE Asia Node Service Account"

import_resource \
    'module.gke_clusters["gke-europe"].google_service_account.gke_node_sa' \
    "projects/$PROJECT_ID/serviceAccounts/gke-europe-node-sa@$PROJECT_ID.iam.gserviceaccount.com" \
    "GKE Europe Node Service Account"

# Import Cloud Routers
import_resource \
    'module.cloud_nat["asia-southeast1"].google_compute_router.router' \
    "projects/$PROJECT_ID/regions/asia-southeast1/routers/gke-asia-southeast1-router" \
    "Cloud Router Asia"

import_resource \
    'module.cloud_nat["europe-west1"].google_compute_router.router' \
    "projects/$PROJECT_ID/regions/europe-west1/routers/gke-europe-west1-router" \
    "Cloud Router Europe"

# Import Cloud NAT
import_resource \
    'module.cloud_nat["asia-southeast1"].google_compute_router_nat.nat' \
    "projects/$PROJECT_ID/regions/asia-southeast1/routers/gke-asia-southeast1-router/gke-asia-southeast1-nat" \
    "Cloud NAT Asia"

import_resource \
    'module.cloud_nat["europe-west1"].google_compute_router_nat.nat' \
    "projects/$PROJECT_ID/regions/europe-west1/routers/gke-europe-west1-router/gke-europe-west1-nat" \
    "Cloud NAT Europe"

# Import GKE Clusters
import_resource \
    'module.gke_clusters["gke-asia"].google_container_cluster.cluster' \
    "projects/$PROJECT_ID/locations/asia-southeast1/clusters/gke-asia" \
    "GKE Cluster Asia"

import_resource \
    'module.gke_clusters["gke-europe"].google_container_cluster.cluster' \
    "projects/$PROJECT_ID/locations/europe-west1/clusters/gke-europe" \
    "GKE Cluster Europe"

# Import Node Pools
import_resource \
    'module.gke_clusters["gke-asia"].google_container_node_pool.primary' \
    "projects/$PROJECT_ID/locations/asia-southeast1/clusters/gke-asia/nodePools/primary" \
    "GKE Node Pool Asia"

import_resource \
    'module.gke_clusters["gke-europe"].google_container_node_pool.primary' \
    "projects/$PROJECT_ID/locations/europe-west1/clusters/gke-europe/nodePools/primary" \
    "GKE Node Pool Europe"

# Import Artifact Registry
import_resource \
    'google_artifact_registry_repository.ping_iam' \
    "projects/$PROJECT_ID/locations/asia-southeast1/repositories/ping-iam" \
    "Artifact Registry Repository"

echo "============================================"
echo "Import complete!"
echo "============================================"
echo ""
echo "Next steps:"
echo "1. Run 'terraform plan' to verify state matches infrastructure"
echo "2. Review any differences and update configuration if needed"
echo "3. Run 'terraform apply' only if plan shows expected changes"
echo ""
