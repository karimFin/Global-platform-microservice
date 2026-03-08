# Docs Index

## Core architecture
- `ARCHITECTURE_DEEP_DIVE.md`: full runtime/data/event/deploy architecture breakdown
- `assets/global-marketplace-architecture.gif`: animated architecture walkthrough

## SRE and observability
- `PLATFORM_SRE_FAANG_IMPLEMENTATION.md`: SRE operating model and Grafana implementation
- `SRE_PLATFORM_BLUEPRINT.md`: reliability blueprint with SLOs, alerts, runbooks

## IaC and platform governance
- `IAC_ADOPTION_PLAN.md`: what is already declarative and what to convert next
- `GITHUB_SECRETS_GOVERNANCE.md`: Terraform-based secret policy and rotation model

### GitHub governance IaC
Terraform stack path:
- `infra/terraform/envs/github`

What it manages:
- repository labels (`preview`, `iac`, `reliability`)
- branch protection (`dev`, `main`)
- repository environments (`dev`, `prod`)
- selected environment variables (`TF_WORKSPACE`, optional `TF_CLOUD_ORGANIZATION`)

Required environment variables:

```bash
export TF_VAR_github_owner=karimFin
export TF_VAR_github_token=<github_pat_with_repo_admin_permissions>
export TF_VAR_repository_name=gpm-microservices
export TF_VAR_tf_cloud_organization=<your_hcp_org>
export TF_VAR_tf_workspace=gmp-dev
```

Run commands:

```bash
make gh-iac-init
make gh-iac-plan
make gh-iac-apply
```

Destroy only when intentionally removing governance:

```bash
make gh-iac-destroy
```

## Independent tool READMEs
- `tools/ARCHITECTURE_DOCUMENTATION_README.md`
- `tools/GRAFANA_OBSERVABILITY_README.md`
- `tools/PREVIEW_IAC_OVERLAY_README.md`
- `tools/GITHUB_GOVERNANCE_IAC_README.md`
- `tools/SECRETS_GOVERNANCE_ROTATION_README.md`
