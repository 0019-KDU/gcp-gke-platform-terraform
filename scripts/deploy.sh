#!/bin/bash
# ============================================================================
# GKE Multi-Region Service Mesh Deployment Script
# ============================================================================
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Configuration - read from gcloud config or environment variable
PROJECT_ID="${PROJECT_ID:-$(gcloud config get-value project 2>/dev/null)}"
REGION_ASIA="asia-southeast1"
REGION_EUROPE="europe-west1"
CLUSTER_ASIA="gke-asia"
CLUSTER_EUROPE="gke-europe"

if [ -z "$PROJECT_ID" ] || [ "$PROJECT_ID" = "(unset)" ]; then
  echo -e "${RED}ERROR: PROJECT_ID is not set.${NC}"
  echo "Set it with: export PROJECT_ID=your-project-id"
  echo "Or run: gcloud config set project your-project-id"
  exit 1
fi

echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}GKE Multi-Region Service Mesh Deployment${NC}"
echo -e "${GREEN}Project: ${PROJECT_ID}${NC}"
echo -e "${GREEN}============================================${NC}"

# Step 1: Check if terraform.tfvars exists
if [ ! -f "terraform.tfvars" ]; then
  echo -e "${RED}ERROR: terraform.tfvars not found.${NC}"
  echo "Copy the example and update it:"
  echo "  cp terraform.tfvars.example terraform.tfvars"
  echo "  # Edit terraform.tfvars with your project_id"
  exit 1
fi

# Step 2: Initialize Terraform
echo -e "\n${YELLOW}Step 1: Initializing Terraform...${NC}"
terraform init

# Step 3: Validate Terraform Configuration
echo -e "\n${YELLOW}Step 2: Validating Terraform configuration...${NC}"
terraform validate

# Step 4: Plan Terraform Changes
echo -e "\n${YELLOW}Step 3: Planning Terraform changes...${NC}"
terraform plan -out=tfplan

# Step 5: Apply Terraform (prompt for confirmation)
echo -e "\n${YELLOW}Step 4: Apply Terraform changes?${NC}"
read -p "Type 'yes' to apply: " confirm
if [ "$confirm" = "yes" ]; then
  terraform apply tfplan
  echo -e "${GREEN}Terraform apply completed!${NC}"
else
  echo -e "${YELLOW}Skipped apply. Run manually: terraform apply tfplan${NC}"
fi

# Step 6: Configure kubectl
echo -e "\n${YELLOW}Step 5: Configure kubectl for both clusters...${NC}"
echo ""
echo "# Asia cluster"
echo "gcloud container clusters get-credentials $CLUSTER_ASIA --region $REGION_ASIA --project $PROJECT_ID"
echo ""
echo "# Europe cluster"
echo "gcloud container clusters get-credentials $CLUSTER_EUROPE --region $REGION_EUROPE --project $PROJECT_ID"

echo -e "\n${GREEN}============================================${NC}"
echo -e "${GREEN}Deployment script completed!${NC}"
echo -e "${GREEN}============================================${NC}"
