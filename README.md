# GPM

## Overview
GPM is a production‑oriented system built as a suite of microservices. It combines an operational data plane, a streaming event plane, and a Kubernetes‑first deployment model to support resilient, scalable workflows.

## Architecture
**Edge and Routing**
- Clients access the platform through the API Gateway, which routes requests to domain services.

**Operational Data Plane**
- Postgres is the system of record for transactional data.
- Redis provides low‑latency caching.
- OpenSearch supports search and analytics use cases.

**Eventing and Streaming**
- Kafka (KRaft) is the event backbone for domain events and CDC streams.
- Debezium captures Postgres changes and publishes CDC to Kafka.
- Kafka Connect sinks selected topics to S3‑compatible storage.

**Object Storage**
- MinIO provides S3‑compatible storage for event archives and lake‑style exports.

**Deployment and Orchestration**
- Kubernetes manifests live in `platform/k8s` with Kustomize overlays for dev and prod.
- GitHub Actions handles CI and deployment workflows.

## Request Flow (Example)
1. Client → API Gateway
2. API Gateway → Domain service
3. Service → Postgres/Redis/OpenSearch
4. Data changes → Debezium → Kafka topics
5. Kafka Connect → MinIO (JSONL event archives)

## Kubernetes
**Prereqs**
- Secrets:
  - `postgres-credentials` with `username`, `password`
  - `minio-credentials` with `accesskey`, `secretkey`

**Apply base**
```
kubectl apply -k platform/k8s/base
```

**Apply overlays**
- Dev: `kubectl apply -k platform/k8s/overlays/dev`
- Prod: `kubectl apply -k platform/k8s/overlays/prod`
- Preview: `kubectl apply -k platform/k8s/overlays/preview`

**Bootstrap Jobs**
- `kafka-topics-init` creates core topics.
- `debezium-register` registers the CDC source.
- `minio-make-bucket` creates the `events` bucket.
- `s3-sink-register` registers the S3 sink connector.

## CI/CD
**Workflows**
- `.github/workflows/ci.yml` runs service tests.
- `.github/workflows/ci-extended.yml` runs lint, tests, image builds, SBOM, and vulnerability scans.
- `.github/workflows/deploy.yml` deploys to dev on `dev` branch push; prod canary and promotion are manual dispatch.
- `.github/workflows/preview-pr.yml` deploys PR previews to `pr-<number>` namespace with the `preview` overlay when PR has `preview` label, comments URLs on the PR, and auto-cleans stale previews every 6 hours (24h TTL).

**Secrets**
- `KUBE_CONFIG_DEV` (base64 kubeconfig for dev)
- `KUBE_CONFIG_PROD` (base64 kubeconfig for prod)

## Operations
- Topics: `platform/k8s/base/topics-job.yaml`
- Connector configs: `infra/dev/*.json` and `platform/k8s/base/*-configmap.yaml`
- Rollback: `kubectl rollout undo deployment/<name> -n <namespace>`
- IaC adoption plan: `docs/IAC_ADOPTION_PLAN.md`

## OCI Dev Automation
Use one command entrypoints for learning lifecycle:
- `make ship-dev` → Push current branch to `dev` (auto-triggers `Deploy Dev`)
- `make infra-apply-ci` → Run Terraform apply in GitHub Actions (`Infra Dev`)
- `make infra-destroy-ci` → Run Terraform destroy in GitHub Actions (`Infra Dev`)
- `make infra-cleanup-ci` → Force cleanup in OCI when Terraform state drift happened (`Infra Dev Cleanup`)
- `make infra-plan` → Terraform plan for `infra/terraform/envs/dev`
- `make infra-apply` → Create/update dev OCI infrastructure
- `make infra-destroy` → Destroy dev OCI infrastructure
- `make up-dev` → Apply infra + generate kubeconfig + update `KUBE_CONFIG_DEV` + trigger `Deploy Dev`
- `make infra-status` → Show Terraform state and active OCI cluster/LB
- `make gh-iac-plan` → Plan GitHub labels/branch protection/environments as Terraform
- `make gh-iac-apply` → Apply GitHub governance IaC

Required for remote backend locking:
- `TF_CLOUD_ORGANIZATION` (local shell env)
- `TF_WORKSPACE` (recommended: `gmp-dev`)
- GitHub `dev` environment secrets: `TF_CLOUD_ORGANIZATION`, `TF_API_TOKEN`

Script entrypoint: `scripts/devctl.sh`  
Full quick commands: `cmd.md`
Docs index: `docs/README.md`

## Roadmap
- OpenSearch indexing pipelines
- SLO dashboards and alerting
- Production policy controls (OPA/Gatekeeper)
