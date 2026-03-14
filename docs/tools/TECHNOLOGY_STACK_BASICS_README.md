# Technology Stack Basics README

## Purpose

This guide explains the core technologies used in this repository in a simple way:
- what each technology is
- why it is used here
- basic command or usage pattern

## Application layer

### Node.js
- What: JavaScript runtime for backend services
- Why here: most microservices are implemented in Node for consistency
- Basic usage: `node services/api-gateway/src/server.js`

### Express
- What: lightweight HTTP framework for Node
- Why here: fast API service development with clear routing
- Basic usage: routes in `services/*/src/app.js`

### Next.js
- What: React framework for web apps
- Why here: frontend with routing, SSR support, production build tooling
- Basic usage: `npm --prefix frontend run dev`

### Python + FastAPI
- What: Python API framework
- Why here: used by `transformer-api` for ML inference endpoints
- Basic usage: run container/service for `services/transformer-api/app.py`

## Container and orchestration layer

### Docker
- What: container runtime and image build format
- Why here: reproducible local and CI builds for services
- Basic usage: `docker compose up --build`

### Kubernetes
- What: orchestration platform for container workloads
- Why here: deploy, scale, isolate, and recover microservices
- Basic usage: `kubectl apply -k platform/k8s/overlays/dev`

### Kustomize
- What: Kubernetes manifest customization tool
- Why here: environment overlays for dev/prod/preview
- Basic usage: `kustomize build platform/k8s/overlays/dev`

## Data and eventing layer

### Postgres
- What: relational transactional database
- Why here: source of truth for core business writes
- Basic usage: stateful workload in `platform/k8s/base/postgres-statefulset.yaml`

### Redis
- What: in-memory key-value store
- Why here: cache layer for lower read latency
- Basic usage: deployment in `platform/k8s/base/redis-deployment.yaml`

### OpenSearch
- What: distributed search/index engine
- Why here: search and query acceleration separate from transactional DB
- Basic usage: stateful workload in `platform/k8s/base/opensearch-statefulset.yaml`

### Kafka
- What: distributed event streaming platform
- Why here: asynchronous backbone between services and data consumers
- Basic usage: `kubectl logs -n <ns> job/kafka-topics-init`

### Debezium
- What: change data capture connector
- Why here: streams Postgres changes into Kafka topics
- Basic usage: `platform/k8s/base/debezium-register-job.yaml`

### Kafka Connect
- What: connector runtime for Kafka integrations
- Why here: sink selected streams into object storage
- Basic usage: `platform/k8s/base/s3-sink-register-job.yaml`

### MinIO
- What: S3-compatible object storage
- Why here: event archive/lake-style storage target for sink connectors
- Basic usage: `platform/k8s/base/minio-deployment.yaml`

## Infrastructure and governance layer

### Terraform
- What: infrastructure as code tool
- Why here: OCI infra and GitHub governance are declarative
- Basic usage: `make infra-plan` or `make gh-iac-plan`

### OCI
- What: Oracle Cloud Infrastructure
- Why here: VCN + OKE + cloud resources for runtime environment
- Basic usage: infra modules in `infra/terraform/modules/`

### GitHub Actions
- What: CI/CD workflow engine
- Why here: test, build, deploy, preview, cleanup, scorecards
- Basic usage: workflow files in `.github/workflows/`

### GHCR
- What: GitHub Container Registry
- Why here: stores deployable service and frontend images
- Basic usage: run `publish-ghcr-package.yml` workflow

## Reliability and policy layer

### Prometheus
- What: metrics collection and query system
- Why here: source for SLI/SLO metrics and burn-rate queries
- Basic usage: queried by deploy SLO gate via PromQL API

### Alertmanager
- What: alert routing and grouping component
- Why here: routes burn-rate alerts by severity class
- Basic usage: `platform/k8s/observability/reliability/alertmanager-config.yaml`

### Grafana
- What: dashboard and visualization platform
- Why here: service, journey, and executive reliability dashboards
- Basic usage: `make grafana-install`

### OpenTelemetry
- What: open standard for traces/telemetry
- Why here: trace ID propagation and OTEL-ready spans in Tier0 services
- Basic usage: `@opentelemetry/api` in `services/*/src/app.js`

### OPA Conftest
- What: policy-as-code validation with Rego
- Why here: CI policy checks for probes/resources/service exposure
- Basic usage: policies in `policy/` used by reusable CI policy check

### Kyverno
- What: Kubernetes admission policy engine
- Why here: enforce required probes/resources and preview service guardrails
- Basic usage: `kubectl apply -k platform/k8s/policy/kyverno`

## Quality and test layer

### Jest
- What: JavaScript test framework
- Why here: unit tests for backend services
- Basic usage: `npm --prefix services/api-gateway test`

### ESLint
- What: static code linting for JS/TS
- Why here: consistency and defect prevention in service/frontend code
- Basic usage: `make lint`

### Prettier
- What: code formatting tool
- Why here: consistent formatting across frontend codebase
- Basic usage: `make format-check`
