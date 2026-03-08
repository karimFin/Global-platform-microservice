# GitHub Governance IaC README

## Why we implemented this

Repository governance changed manually over time, which causes:
- inconsistent labels and branch rules
- weak auditability
- environment policy drift

We implemented governance as Terraform so changes are reviewable and repeatable.

## What was implemented

Terraform stack path: `infra/terraform/envs/github`

Managed resources include:
- labels (`preview`, `iac`, `reliability`)
- branch protection for `dev` and `main`
- repository environments (`dev`, `prod`)
- selected environment variables used by CI

## How it works in this project

Operators set Terraform variables for owner/repo/token and run:

```bash
make gh-iac-init
make gh-iac-plan
make gh-iac-apply
```

This applies governance configuration to GitHub using the provider, not manual UI edits.

## Benefits

- policy is versioned in Git
- PR reviews approve governance changes
- easy replication across repositories
