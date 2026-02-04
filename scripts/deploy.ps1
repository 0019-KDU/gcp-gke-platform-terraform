# ============================================================================
# GKE Multi-Region Service Mesh Deployment Script (PowerShell)
# ============================================================================

param(
    [string]$ProjectId,
    [switch]$Apply = $false
)

$RegionAsia = "asia-southeast1"
$RegionEurope = "europe-west1"
$ClusterAsia = "gke-asia"
$ClusterEurope = "gke-europe"

# Auto-detect project ID from gcloud if not provided
if (-not $ProjectId) {
    $ProjectId = gcloud config get-value project 2>$null
}
if (-not $ProjectId -or $ProjectId -eq "(unset)") {
    Write-Host "ERROR: ProjectId is not set." -ForegroundColor Red
    Write-Host "Usage: .\deploy.ps1 -ProjectId your-project-id [-Apply]"
    Write-Host "Or run: gcloud config set project your-project-id"
    exit 1
}

# Check terraform.tfvars exists
if (-not (Test-Path "terraform.tfvars")) {
    Write-Host "ERROR: terraform.tfvars not found." -ForegroundColor Red
    Write-Host "Copy the example and update it:"
    Write-Host "  cp terraform.tfvars.example terraform.tfvars"
    Write-Host "  # Edit terraform.tfvars with your project_id"
    exit 1
}

Write-Host "============================================" -ForegroundColor Green
Write-Host "GKE Multi-Region Service Mesh Deployment" -ForegroundColor Green
Write-Host "Project: $ProjectId" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green

# Step 1: Initialize Terraform
Write-Host "`nStep 1: Initializing Terraform..." -ForegroundColor Yellow
terraform init
if ($LASTEXITCODE -ne 0) { exit 1 }

# Step 2: Validate Terraform Configuration
Write-Host "`nStep 2: Validating Terraform configuration..." -ForegroundColor Yellow
terraform validate
if ($LASTEXITCODE -ne 0) { exit 1 }

# Step 3: Plan Terraform Changes
Write-Host "`nStep 3: Planning Terraform changes..." -ForegroundColor Yellow
terraform plan -out=tfplan
if ($LASTEXITCODE -ne 0) { exit 1 }

# Step 4: Apply Terraform
if ($Apply) {
    Write-Host "`nStep 4: Applying Terraform changes..." -ForegroundColor Yellow
    terraform apply tfplan
    if ($LASTEXITCODE -ne 0) { exit 1 }
} else {
    Write-Host "`nStep 4: Skipping apply (use -Apply flag to apply)" -ForegroundColor Red
}

# Step 5: Configure kubectl
Write-Host "`nStep 5: Configure kubectl for both clusters..." -ForegroundColor Yellow
Write-Host "# Asia cluster" -ForegroundColor Cyan
Write-Host "gcloud container clusters get-credentials $ClusterAsia --region $RegionAsia --project $ProjectId"
Write-Host ""
Write-Host "# Europe cluster" -ForegroundColor Cyan
Write-Host "gcloud container clusters get-credentials $ClusterEurope --region $RegionEurope --project $ProjectId"

Write-Host "`n============================================" -ForegroundColor Green
Write-Host "Deployment script completed!" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
