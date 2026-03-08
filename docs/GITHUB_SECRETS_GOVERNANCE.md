# GitHub Secrets Governance in This Project

## Why this exists

This project uses GitHub Actions environments (`dev`, `prod`) for deployment.
Those environments depend on secrets like kubeconfigs and cloud credentials.

If secret policy is managed manually in GitHub UI:
- environments drift over time
- required secret names become inconsistent
- security expectations are not visible in pull requests

We implemented governance as code so policy is reviewable, repeatable, and auditable.

## What is managed by Terraform

Terraform stack path:
- `infra/terraform/envs/github`

It now manages:
- environment secret policy metadata
  - `REQUIRED_SECRETS`
  - `DECLARED_SECRETS`
- optional environment secret values (when explicitly provided through Terraform variables)
- branch protection, labels, and environments from earlier governance setup

## How policy metadata works

In Terraform variables:
- `required_environment_secrets` defines minimum mandatory secret names per environment
- `declared_environment_secret_names` defines full allowed secret names per environment
- `managed_environment_secrets` optionally provides actual secret values to manage with Terraform

Validation rules:
- every required secret must be present in declared secrets
- every managed secret must be listed in declared secrets

This prevents accidental or unauthorized secret-name sprawl.

## Why we do not force all secret values in Terraform

Some secrets are highly sensitive and rotate often.
Teams may prefer updating those through secure rotation workflows or external vault tooling.

So this project uses a hybrid model:
- policy and naming rules in Terraform
- values optionally in Terraform, or rotated with controlled workflow

## Secret rotation workflow scaffolding

Workflow file:
- `.github/workflows/rotate-environment-secret.yml`

It provides manual rotation with guardrails:
- select target environment (`dev` or `prod`)
- choose secret name and new value
- validate secret name against `DECLARED_SECRETS`
- optional dry-run mode
- update secret via `gh secret set ... --env ...`

Required workflow secret:
- `GH_ADMIN_TOKEN` with permission to manage repository environment secrets

## How this works in this project

Current environments:
- `dev`: used by Deploy Dev / Preview pipelines
- `prod`: used by production deployment workflows

Typical required secrets:
- `KUBE_CONFIG_DEV`, `TF_API_TOKEN` for `dev`
- `KUBE_CONFIG_PROD` for `prod`

OCI and registry-related secrets should also be declared in policy metadata to keep CI expectations explicit.

## Operator workflow

1. Update policy in Terraform (`required_environment_secrets`, `declared_environment_secret_names`)
2. Run:
   - `make gh-iac-plan`
   - `make gh-iac-apply`
3. Rotate secret values via:
   - Terraform `managed_environment_secrets`, or
   - `Rotate Environment Secret` workflow
4. Confirm deployment workflows pass with updated secrets

This gives consistent governance and safer secret operations with clear change history.
