# Docs Index

## Core architecture
- `ARCHITECTURE_DEEP_DIVE.md`: full runtime/data/event/deploy architecture breakdown
- `TEAM_AND_CREDITS.md`: maintainer credits and open contributor roles
- `assets/global-marketplace-architecture.gif`: animated architecture walkthrough

## SRE and observability
- `PLATFORM_SRE_FAANG_IMPLEMENTATION.md`: SRE operating model and Grafana implementation
- `SRE_PLATFORM_BLUEPRINT.md`: reliability blueprint with SLOs, alerts, runbooks
- `FAANG_RELIABILITY_UPGRADE.md`: implemented reliability controls and operator setup

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
- `tools/KUBERNETES_PLATFORM_README.md`
- `tools/DOCKER_LOCAL_STACK_README.md`
- `tools/KAFKA_EVENTING_README.md`
- `tools/REDIS_CACHE_README.md`
- `tools/POSTGRES_DATASTORE_README.md`
- `tools/OPENSEARCH_README.md`
- `tools/MINIO_OBJECT_STORAGE_README.md`
- `tools/PROJECT_STRUCTURE_README.md`
- `tools/TOOLS_MAP.md`
- `tools/GITHUB_PACKAGES_PUBLISHING_README.md`
- `tools/CONTRIBUTOR_SHOWCASE_TEMPLATE_README.md`
- `tools/TECHNOLOGY_STACK_BASICS_README.md`

## Tool matrix
| Tool | Purpose | Owner | Operational command |
|---|---|---|---|
| Kubernetes | Run microservices with declarative deployment | Platform/DevOps | `kubectl apply -k platform/k8s/overlays/dev` |
| Docker Compose | Run full stack locally for development | App + Platform teams | `make dev` |
| Kafka | Event backbone for async integration | Platform/Data | `kubectl logs -n marketplace-dev job/kafka-topics-init` |
| Redis | Low-latency cache for hot reads | Service teams | `kubectl rollout status deployment/redis -n marketplace-dev` |
| Postgres | Transactional source of truth | Service teams | `kubectl rollout status statefulset/postgres -n marketplace-dev` |
| OpenSearch | Search indexing and query acceleration | Search/Platform | `kubectl rollout status statefulset/opensearch -n marketplace-dev` |
| MinIO | S3-compatible event archive storage | Platform/Data | `kubectl logs -n marketplace-dev job/minio-make-bucket` |
| Grafana | Dashboards for SLOs and golden signals | SRE/Platform | `make grafana-install` |
| Preview IaC overlay | Declarative preview environment behavior | Platform/DevOps | `kubectl apply -k platform/k8s/overlays/preview` |
| GitHub governance IaC | Labels, protections, environments as code | Platform/DevOps | `make gh-iac-apply` |
| Secret governance + rotation | Policy metadata + controlled secret rotation | Platform/Security | `gh workflow run rotate-environment-secret.yml` |
| GitHub Packages publish | Manual and tag-based GHCR publishing | Platform/Release | `gh workflow run publish-ghcr-package.yml` |
| Kyverno policy bundle | Admission guardrails for workloads and services | Platform/SRE | `kubectl apply -k platform/k8s/policy/kyverno` |
| Reliability automation | Weekly scorecards and monthly game day drills | Platform/SRE | `gh workflow run reliability-scorecard.yml` |
