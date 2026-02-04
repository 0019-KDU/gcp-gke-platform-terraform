# GitHub Actions CI/CD Pipeline for Terraform

This document describes the CI/CD pipeline setup for the GKE Platform Terraform infrastructure.

## 📁 Pipeline Structure

```
.github/workflows/
├── terraform-ci.yml           # CI validation on PRs
├── terraform-deploy.yml       # Deployment workflow
├── terraform-drift-detection.yml  # Scheduled drift detection
└── terraform-docs.yml         # Auto-generate documentation
```

## 🔧 Setup Instructions

### 1. Create GitHub Secrets

Navigate to your repository **Settings → Secrets and variables → Actions** and add:

| Secret Name | Description |
|-------------|-------------|
| `GCP_SA_KEY` | GCP Service Account JSON key with required permissions |
| `GCP_PROJECT_ID` | Your GCP Project ID |
| `TF_STATE_BUCKET` | GCS bucket name for Terraform state |
| `SLACK_WEBHOOK_URL` | (Optional) Slack webhook for notifications |

### 2. Create GCP Service Account

```bash
# Create service account
gcloud iam service-accounts create terraform-cicd \
    --display-name="Terraform CI/CD" \
    --project=YOUR_PROJECT_ID

# Grant required roles
gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
    --member="serviceAccount:terraform-cicd@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/editor"

gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
    --member="serviceAccount:terraform-cicd@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/container.admin"

gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
    --member="serviceAccount:terraform-cicd@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/iam.serviceAccountUser"

# Create and download key
gcloud iam service-accounts keys create terraform-cicd-key.json \
    --iam-account=terraform-cicd@YOUR_PROJECT_ID.iam.gserviceaccount.com
```

### 3. Create GCS Bucket for Terraform State

```bash
# Create bucket
gsutil mb -p YOUR_PROJECT_ID -l asia-southeast1 gs://YOUR_TF_STATE_BUCKET

# Enable versioning
gsutil versioning set on gs://YOUR_TF_STATE_BUCKET
```

### 4. Configure GitHub Environments

Create environments in **Settings → Environments**:

| Environment | Protection Rules |
|-------------|------------------|
| `dev` | None (auto-deploy) |
| `staging` | Required reviewers |
| `production` | Required reviewers, deployment branches (main only) |

### 5. Enable Remote Backend

Update `versions.tf` to use remote backend:

```hcl
terraform {
  backend "gcs" {
    # Configured via -backend-config during init
  }
}
```

## 🚀 Workflows

### Terraform CI (`terraform-ci.yml`)

**Triggered on:** Pull requests to `main` or `develop`

| Job | Description |
|-----|-------------|
| `security-scan` | Runs Checkov and tfsec for security issues |
| `format` | Validates Terraform formatting |
| `validate` | Validates Terraform configuration |
| `plan-dev` | Creates plan for dev environment |

### Terraform Deploy (`terraform-deploy.yml`)

**Triggered on:** 
- Push to `main` (auto-deploys to dev)
- Manual workflow dispatch

**Actions available:**
- `plan` - Preview changes
- `apply` - Apply changes
- `destroy` - Destroy infrastructure

### Drift Detection (`terraform-drift-detection.yml`)

**Triggered on:** 
- Daily at 6 AM UTC (scheduled)
- Manual workflow dispatch

Creates GitHub issues when drift is detected.

### Documentation (`terraform-docs.yml`)

**Triggered on:** PRs with `.tf` file changes

Auto-generates and commits README documentation.

## 🔒 Security Best Practices

1. **Least Privilege**: Service accounts have minimum required permissions
2. **State Encryption**: GCS bucket encrypts state at rest
3. **Secret Management**: Sensitive values stored in GitHub Secrets
4. **Security Scanning**: Checkov and tfsec scan for misconfigurations
5. **Branch Protection**: Require PR reviews before merging to main
6. **Environment Protection**: Production requires manual approval

## 📊 Workflow Diagram

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  Developer  │────▶│ Pull Request│────▶│   CI Jobs   │
└─────────────┘     └─────────────┘     └─────────────┘
                                              │
                           ┌──────────────────┼──────────────────┐
                           ▼                  ▼                  ▼
                    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
                    │Security Scan│    │Format/Valid │    │    Plan     │
                    └─────────────┘    └─────────────┘    └─────────────┘
                                              │
                                              ▼
                                       ┌─────────────┐
                                       │   Review    │
                                       └─────────────┘
                                              │
                                              ▼
                    ┌─────────────────────────┴─────────────────────────┐
                    ▼                                                   ▼
             ┌─────────────┐                                     ┌─────────────┐
             │  Merge PR   │                                     │   Reject    │
             └─────────────┘                                     └─────────────┘
                    │
                    ▼
             ┌─────────────┐
             │ Deploy Dev  │ (Automatic)
             └─────────────┘
                    │
                    ▼
             ┌─────────────┐
             │Deploy Stage │ (Manual Approval)
             └─────────────┘
                    │
                    ▼
             ┌─────────────┐
             │ Deploy Prod │ (Manual Approval)
             └─────────────┘
```

## 🛠 Troubleshooting

### Common Issues

1. **Authentication Failed**
   - Verify `GCP_SA_KEY` secret contains valid JSON
   - Ensure service account has required permissions

2. **State Lock Issues**
   - Check if another process holds the lock
   - Use `terraform force-unlock` if needed

3. **Plan Differences**
   - Review drift detection results
   - Ensure all changes go through Git

### Manual Intervention

```bash
# Manual state management (use with caution)
terraform state list
terraform state show <resource>
terraform state rm <resource>
terraform import <resource> <id>
```

## 📝 Contributing

1. Create feature branch from `develop`
2. Make changes and test locally
3. Open PR to `develop`
4. Review CI results
5. Merge after approval
6. PR from `develop` to `main` for production
