# Secrets Governance and Rotation README

## Why we implemented this

Environment secrets are critical for deployments and infra workflows.
Without policy controls:
- secret names become inconsistent
- required secrets can be missing
- rotation is risky and ad-hoc

We implemented guardrails in Terraform and added a rotation workflow scaffold.

## What was implemented

- Terraform secret policy metadata in `infra/terraform/envs/github`:
  - `REQUIRED_SECRETS`
  - `DECLARED_SECRETS`
- Validation checks to enforce policy consistency
- Optional Terraform-managed secret values (`managed_environment_secrets`)
- Rotation scaffold workflow:
  - `.github/workflows/rotate-environment-secret.yml`

## How it works in this project

- Terraform defines required and allowed secret names per environment.
- The rotation workflow validates secret name against declared policy before update.
- Dry-run mode allows safe validation before writing a new secret value.

## Why this is safer

- secrets policy is auditable in Git
- less chance of accidental secret misuse
- repeatable rotation with approval workflow support

## Related deep-dive

- `docs/GITHUB_SECRETS_GOVERNANCE.md`
