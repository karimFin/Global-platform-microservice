# GPM

[![CI](https://github.com/karimFin/gpm-microservices/actions/workflows/ci.yml/badge.svg)](https://github.com/karimFin/gpm-microservices/actions/workflows/ci.yml)
[![CI Extended](https://github.com/karimFin/gpm-microservices/actions/workflows/ci-extended.yml/badge.svg)](https://github.com/karimFin/gpm-microservices/actions/workflows/ci-extended.yml)
[![Preview PR](https://github.com/karimFin/gpm-microservices/actions/workflows/preview-pr.yml/badge.svg)](https://github.com/karimFin/gpm-microservices/actions/workflows/preview-pr.yml)
[![Publish GHCR Package](https://github.com/karimFin/gpm-microservices/actions/workflows/publish-ghcr-package.yml/badge.svg)](https://github.com/karimFin/gpm-microservices/actions/workflows/publish-ghcr-package.yml)

Production-oriented marketplace platform with microservices, event streaming, and Kubernetes-first operations.

## Why this repository

- Demonstrates a realistic commerce microservice architecture
- Combines transactional workloads, eventing, search, and object storage
- Uses Infrastructure as Code for cloud, Kubernetes, and GitHub governance
- Includes SRE-focused observability and operational playbooks

## Architecture at a glance

- Request plane: `Web -> API Gateway -> Domain services`
- Data plane: `Postgres + Redis + OpenSearch`
- Event plane: `Postgres CDC -> Debezium -> Kafka -> Kafka Connect -> MinIO`
- Deployment plane: `GitHub Actions -> Kustomize overlays -> OKE`

Architecture visual:
- `docs/assets/global-marketplace-architecture.gif`

## Quick start

Prerequisites:
- Docker
- kubectl and kustomize
- Terraform (for infra and governance flows)

Local development:

```bash
make dev
```

Quality checks:

```bash
make lint
make format-check
```

## Deployment and infrastructure

Kubernetes overlays:
- Dev: `platform/k8s/overlays/dev`
- Prod: `platform/k8s/overlays/prod`
- Preview: `platform/k8s/overlays/preview`

OCI and Terraform lifecycle:
- `make infra-plan`
- `make infra-apply`
- `make infra-destroy`
- `make infra-status`

GitHub governance as Terraform:
- `make gh-iac-init`
- `make gh-iac-plan`
- `make gh-iac-apply`

## CI/CD highlights

- `ci.yml`: core service tests
- `ci-extended.yml`: lint, tests, image/security tasks
- `preview-pr.yml`: preview namespaces on `preview` label
- `deploy-dev.yml` and `deploy-prod.yml`: environment deployments
- `publish-ghcr-package.yml`: manual and `v*` tag-based package publishing

## Reliability gate checks

Local SLO burn-rate gate commands:

```bash
export PROMETHEUS_URL=https://prometheus.example.com
make slo-gate-check
make slo-gate-check-prod
```

Full command reference:
- `docs/tools/SLO_GATE_LOCAL_CLI_README.md`

## Packages

GitHub Packages uses GHCR container packages.

- Manual publish: run `Publish GHCR Package` workflow
- Auto publish: push tag like `v0.1.0`
- Packages page: `https://github.com/karimFin/gpm-microservices/packages`

## Documentation

- Start here: `docs/README.md`
- Tools map: `docs/tools/TOOLS_MAP.md`
- Architecture deep dive: `docs/ARCHITECTURE_DEEP_DIVE.md`
- IaC adoption plan: `docs/IAC_ADOPTION_PLAN.md`
- Secrets governance: `docs/GITHUB_SECRETS_GOVERNANCE.md`

## Community and governance

- Contributing: `CONTRIBUTING.md`
- Code of Conduct: `CODE_OF_CONDUCT.md`
- Security Policy: `SECURITY.md`
- Support: `SUPPORT.md`
- Team and credits: `docs/TEAM_AND_CREDITS.md`

## Roadmap

- OpenSearch indexing pipelines
- SLO dashboards and alerting hardening
- Policy enforcement with OPA/Gatekeeper
