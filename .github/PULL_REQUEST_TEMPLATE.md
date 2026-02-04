---
name: Pull Request
about: Standard pull request template
title: ''
labels: ''
assignees: ''
---

## Description
<!-- Describe your changes in detail -->

## Type of Change
- [ ] 🐛 Bug fix (non-breaking change that fixes an issue)
- [ ] ✨ New feature (non-breaking change that adds functionality)
- [ ] 💥 Breaking change (fix or feature that would cause existing functionality to change)
- [ ] 📝 Documentation update
- [ ] 🔧 Configuration change
- [ ] 🏗️ Infrastructure change

## Environment(s) Affected
- [ ] Dev
- [ ] Staging
- [ ] Production

## Terraform Changes
<!-- List the resources that will be created/modified/destroyed -->

### Resources to be Created
- 

### Resources to be Modified
- 

### Resources to be Destroyed
- 

## Checklist
- [ ] I have run `terraform fmt` locally
- [ ] I have run `terraform validate` locally
- [ ] I have run `terraform plan` and reviewed the output
- [ ] I have updated documentation if needed
- [ ] I have added/updated tests if applicable
- [ ] Security scan (Checkov/tfsec) passes
- [ ] This change requires a database migration (if yes, describe below)

## Screenshots/Plan Output
<!-- If applicable, add screenshots or terraform plan output -->

<details>
<summary>Terraform Plan Output</summary>

```terraform
# Paste plan output here
```

</details>

## Additional Notes
<!-- Any additional information that reviewers should know -->
