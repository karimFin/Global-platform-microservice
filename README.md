# Global Marketplace Platform

## Overview
Global Marketplace Platform is a production‑oriented e‑commerce system built as a suite of Node.js microservices. It combines an operational data plane, a streaming event plane, and a Kubernetes‑first deployment model to support resilient, scalable commerce workflows.

## Architecture
**Edge and Routing**
- Clients access the platform through the API Gateway, which routes requests to domain services.

**Domain Services**
- Core business capabilities are implemented as independent services: Identity, Catalog, Orders, Payments, Inventory, Search, Pricing, Cart, Checkout, Fulfillment, Notifications, Reviews, and Analytics.

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

## Repository Structure
- `services/` → Backend microservices
- `frontend/` → Web application
- `platform/k8s/` → Kubernetes base and overlays
- `infra/` → Infrastructure configs and connector definitions

## Local Development
**Prereqs**: Docker Desktop, Node.js 20+

1. Start services and infrastructure:
   - `make dev` or `docker compose up --build`
2. Infrastructure endpoints:
   - Postgres: localhost:5432
   - Redis: localhost:6379
   - Kafka: localhost:9092
   - Kafka Connect: http://localhost:8083
   - OpenSearch: http://localhost:9200
   - MinIO: http://localhost:9000 (S3), http://localhost:9001 (console)

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

**Secrets**
- `KUBE_CONFIG_DEV` (base64 kubeconfig for dev)
- `KUBE_CONFIG_PROD` (base64 kubeconfig for prod)

## Operations
- Topics: `platform/k8s/base/topics-job.yaml`
- Connector configs: `infra/dev/*.json` and `platform/k8s/base/*-configmap.yaml`
- Rollback: `kubectl rollout undo deployment/<name> -n <namespace>`

## Roadmap
- OpenSearch indexing pipelines
- SLO dashboards and alerting
- Production policy controls (OPA/Gatekeeper)
