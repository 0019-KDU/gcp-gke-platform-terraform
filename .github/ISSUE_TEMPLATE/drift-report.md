---
name: Infrastructure Drift
about: Report infrastructure drift detected by automation
title: '🚨 Infrastructure Drift Detected - [ENVIRONMENT]'
labels: 'infrastructure-drift, automated'
assignees: ''
---

## Drift Detection Report

**Environment:** <!-- dev/staging/prod -->
**Detected at:** <!-- timestamp -->
**Workflow Run:** <!-- link to GitHub Actions run -->

## Summary
<!-- Brief description of the drift -->

## Drift Details

<details>
<summary>Terraform Plan Output</summary>

```terraform
# Plan output will be inserted here
```

</details>

## Root Cause Analysis
<!-- To be filled by reviewer -->

- [ ] Intentional manual change
- [ ] Unauthorized change
- [ ] Configuration drift
- [ ] External system change
- [ ] Unknown

## Resolution

### Option 1: Update Terraform to Match Reality
<!-- If the change was intentional, update the Terraform code -->

### Option 2: Remediate with Terraform Apply
<!-- If the change was unintentional, apply Terraform to restore desired state -->

## Checklist
- [ ] Root cause identified
- [ ] Resolution approach decided
- [ ] Changes reviewed
- [ ] Remediation applied
- [ ] Verification completed

## Notes
<!-- Additional context or information -->
