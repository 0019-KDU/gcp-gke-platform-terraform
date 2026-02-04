# ============================================================================
# Terraform Import Script - Import existing GCP resources into state
# Run this script after terraform init
# ============================================================================

param(
    [Parameter(Mandatory=$false)]
    [string]$StateBucket = "bold-lantern-480305-k3-tf-state",

    [Parameter(Mandatory=$false)]
    [string]$Environment = "dev"
)

$ErrorActionPreference = "Stop"

# Configuration
$PROJECT_ID = "bold-lantern-480305-k3"

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Terraform Resource Import Script" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Project ID: $PROJECT_ID"
Write-Host "Environment: $Environment"
Write-Host ""

# Check if terraform is available
if (-not (Get-Command terraform -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: terraform not found in PATH" -ForegroundColor Red
    exit 1
}

# Initialize Terraform if bucket provided
if ($StateBucket -ne "") {
    Write-Host "Initializing Terraform..." -ForegroundColor Yellow
    terraform init `
        -backend-config="bucket=$StateBucket" `
        -backend-config="prefix=gke-platform/$Environment" `
        -reconfigure

    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Terraform init failed" -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Write-Host "Starting resource imports..." -ForegroundColor Yellow
Write-Host ""

# Function to import resource
function Import-TerraformResource {
    param(
        [string]$Address,
        [string]$ID,
        [string]$Description
    )

    Write-Host "Importing: $Description" -ForegroundColor Cyan
    Write-Host "  Address: $Address"
    Write-Host "  ID: $ID"

    terraform import $Address $ID 2>&1

    if ($LASTEXITCODE -eq 0) {
        Write-Host "  SUCCESS" -ForegroundColor Green
    } else {
        Write-Host "  SKIPPED (may already exist in state)" -ForegroundColor Yellow
    }
    Write-Host ""
}

# Import Service Accounts
Import-TerraformResource `
    -Address 'module.gke_clusters["gke-asia"].google_service_account.gke_node_sa' `
    -ID "projects/$PROJECT_ID/serviceAccounts/gke-asia-node-sa@$PROJECT_ID.iam.gserviceaccount.com" `
    -Description "GKE Asia Node Service Account"

Import-TerraformResource `
    -Address 'module.gke_clusters["gke-europe"].google_service_account.gke_node_sa' `
    -ID "projects/$PROJECT_ID/serviceAccounts/gke-europe-node-sa@$PROJECT_ID.iam.gserviceaccount.com" `
    -Description "GKE Europe Node Service Account"

# Import Cloud Routers
Import-TerraformResource `
    -Address 'module.cloud_nat["asia-southeast1"].google_compute_router.router' `
    -ID "projects/$PROJECT_ID/regions/asia-southeast1/routers/gke-asia-southeast1-router" `
    -Description "Cloud Router Asia"

Import-TerraformResource `
    -Address 'module.cloud_nat["europe-west1"].google_compute_router.router' `
    -ID "projects/$PROJECT_ID/regions/europe-west1/routers/gke-europe-west1-router" `
    -Description "Cloud Router Europe"

# Import Cloud NAT
Import-TerraformResource `
    -Address 'module.cloud_nat["asia-southeast1"].google_compute_router_nat.nat' `
    -ID "projects/$PROJECT_ID/regions/asia-southeast1/routers/gke-asia-southeast1-router/gke-asia-southeast1-nat" `
    -Description "Cloud NAT Asia"

Import-TerraformResource `
    -Address 'module.cloud_nat["europe-west1"].google_compute_router_nat.nat' `
    -ID "projects/$PROJECT_ID/regions/europe-west1/routers/gke-europe-west1-router/gke-europe-west1-nat" `
    -Description "Cloud NAT Europe"

# Import GKE Clusters
Import-TerraformResource `
    -Address 'module.gke_clusters["gke-asia"].google_container_cluster.cluster' `
    -ID "projects/$PROJECT_ID/locations/asia-southeast1/clusters/gke-asia" `
    -Description "GKE Cluster Asia"

Import-TerraformResource `
    -Address 'module.gke_clusters["gke-europe"].google_container_cluster.cluster' `
    -ID "projects/$PROJECT_ID/locations/europe-west1/clusters/gke-europe" `
    -Description "GKE Cluster Europe"

# Import Node Pools
Import-TerraformResource `
    -Address 'module.gke_clusters["gke-asia"].google_container_node_pool.primary' `
    -ID "projects/$PROJECT_ID/locations/asia-southeast1/clusters/gke-asia/nodePools/primary" `
    -Description "GKE Node Pool Asia"

Import-TerraformResource `
    -Address 'module.gke_clusters["gke-europe"].google_container_node_pool.primary' `
    -ID "projects/$PROJECT_ID/locations/europe-west1/clusters/gke-europe/nodePools/primary" `
    -Description "GKE Node Pool Europe"

# Import Artifact Registry
Import-TerraformResource `
    -Address 'google_artifact_registry_repository.ping_iam' `
    -ID "projects/$PROJECT_ID/locations/asia-southeast1/repositories/ping-iam" `
    -Description "Artifact Registry Repository"

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "Import complete!" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Run 'terraform plan' to verify state matches infrastructure"
Write-Host "2. Review any differences and update configuration if needed"
Write-Host "3. Run 'terraform apply' only if plan shows expected changes"
Write-Host ""
