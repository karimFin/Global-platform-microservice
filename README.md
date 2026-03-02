# Global Marketplace Platform

## Overview
Enterprise‑grade e‑commerce microservices with FAANG s data and eventing foundations. This repo provides:
- Service mesh of Node.js microservices (API Gateway, Identity, Catalog, Orders, Payments, etc.)
- Data plane: Postgres (OLTP), Redis (cache), OpenSearch (search)
- Event plane: Kafka (KRaft), Kafka Connect with Debezium CDC and S3 sink
- Object storage: MinIO (S3‑compatible) for data lake style archives
- Kubernetes with Kustomize overlays and GitHub Actions CI/CD

## Architecture (High Level)
- Ingress → API Gateway → Domain microservices
- Postgres as system of record; Debezium streams CDC to Kafka
- Kafka topics:
  - orders.events, payments.events (domain events)
  - inventory.cdc (CDC from Postgres)
- Kafka Connect sinks selected topics to S3 (MinIO) as JSONL (gz)
- OpenSearch for search indexing (future pipelines can consume Kafka topics)

## Local Development
Prereqs: Docker Desktop, Node 20+

1. Build and run services + infra
   - `make dev` (or) `docker compose up --build`
2. Services exposed on 9000+ range (see docker-compose.yml).
3. Infra endpoints:
   - Postgres: localhost:5432 (market/marketpass)
   - Redis: localhost:6379
   - Kafka: localhost:9092 (PLAINTEXT)
   - Kafka Connect: http://localhost:8083
   - OpenSearch: http://localhost:9200
   - MinIO: S3 http://localhost:9000, Console http://localhost:9001 (admin/adminadmin)

### Eventing & Data Lake (Local)
- Debezium Postgres connector registers automatically and streams to `inventory.cdc`.
- Aiven S3 Sink connector registers automatically and writes JSONL files to `events` bucket in MinIO.
- Verify connectors:
  - `curl http://localhost:8083/connectors` → should list `inventory-postgres-connector` and `s3-sink`
  - MinIO console → bucket `events` populated as topics flow

## Kubernetes
Prereqs (cluster and secrets):
- Namespace and base manifests: `platform/k8s/base`
- Provide Secrets in the cluster:
  - `postgres-credentials` with `username`, `password`
  - `minio-credentials` with `accesskey`, `secretkey`

Apply base:
```
kubectl apply -k platform/k8s/base
```

Overlays:
- Dev: `kubectl apply -k platform/k8s/overlays/dev`
- Prod: `kubectl apply -k platform/k8s/overlays/prod`

Jobs:
- `kafka-topics-init` creates core topics.
- `debezium-register` registers CDC source.
- `minio-make-bucket` creates `events` bucket.
- `s3-sink-register` registers Aiven S3 sink.

## CI/CD (FAANG)
Workflows:
- `ci-extended.yml`:
  - Lint (ESLint), unit tests across services
  - Build Docker images per service and push to GHCR
  - SBOM via Syft; vulnerability scan via Trivy
- `deploy.yml`:
  - Manual dispatch; deploys to Dev
  - Canary on `api-gateway` in Prod; auto‑rollback on failure
  - Promote all services to Prod; rollback any failed rollout

Required GitHub secrets:
- `KUBE_CONFIG_DEV` (base64 kubeconfig for dev)
- `KUBE_CONFIG_PROD` (base64 kubeconfig for prod)

## Operational Runbooks
- Kafka topics: defined in `topics-job.yaml`
- Connector configs: `infra/dev/*.json` and `platform/k8s/base/*-configmap.yaml`
- Rollbacks: `kubectl rollout undo deployment/<name> -n <ns>`
- SBOMs: workflow artifacts named `sbom-<service>.spdx.json`

## Next Steps
- Add OpenSearch indexing pipelines
- Add SLO dashboards and alerting rules
- Add policy controls for production (OPA/Gatekeeper)

