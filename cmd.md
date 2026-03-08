# Dev Infrastructure Quick Commands

## One-time setup

```bash
chmod +x scripts/devctl.sh
export TF_CLOUD_ORGANIZATION=<your_hcp_org>
export TF_WORKSPACE=gmp-dev
```

## Team default workflow

```bash
make ship-dev
```

This pushes current code to `dev`.  
`Deploy Dev` workflow auto-runs on push to `dev`.

PR previews are automatic:
- Add `preview` label on PR to `dev` → deploys into namespace `pr-<PR_NUMBER>`
- Workflow comments preview Web/API URLs on the PR
- Closing PR deletes the preview namespace
- Scheduled cleanup removes stale preview namespaces every 6 hours (24h TTL)

## Infra as one-command from GitHub Actions

```bash
make infra-apply-ci
make infra-destroy-ci
make infra-cleanup-ci
```

This is team-safe because infra is managed centrally with repo secrets in CI.
If state drift happened and `infra-destroy-ci` shows `0 destroyed`, use `infra-cleanup-ci`.

## Local full automation

```bash
make up-dev
```

This does apply + kubeconfig + secret update + deploy.

## Useful local commands

```bash
make infra-status
make infra-plan
make infra-apply
make infra-destroy
make kubeconfig-dev
make secret-kube-dev
make deploy-dev
NAMESPACE=my-dev make deploy-dev
GH_REF=dev make deploy-dev
GH_REPO=owner/repo make deploy-dev
KUBECONFIG_FILE=/tmp/custom-kube.yaml make kubeconfig-dev
```

## Simple daily commands

```bash
make lint
make format-check
make format-fix
```

## Quick fixes examples

```bash
# Fix only cart page formatting
make format-fix-cart

# Run checks before push
make lint
make format-check

# If format-check fails, auto-fix and re-run
make format-fix
make format-check
```

## GitHub governance IaC

```bash
export TF_VAR_github_owner=karimFin
export TF_VAR_github_token=<github_pat_with_repo_admin_permissions>
export TF_VAR_repository_name=gpm-microservices
export TF_VAR_tf_cloud_organization=<your_hcp_org>
export TF_VAR_tf_workspace=gmp-dev

make gh-iac-init
make gh-iac-plan
make gh-iac-apply
```
