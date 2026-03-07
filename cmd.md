# Dev Infrastructure Quick Commands

## One-time setup

```bash
chmod +x scripts/devctl.sh
```

## Team default workflow

```bash
make ship-dev
```

This pushes current code to `dev`.  
`Deploy Dev` workflow auto-runs on push to `dev`.

## Infra as one-command from GitHub Actions

```bash
make infra-apply-ci
make infra-destroy-ci
```

This is team-safe because infra is managed centrally with repo secrets in CI.

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
