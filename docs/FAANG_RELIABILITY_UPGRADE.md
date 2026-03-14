# FAANG Reliability Upgrade Implementation

## Implemented controls

This repository now includes implementation for the five high-maturity reliability controls:

1. Service-level metrics and OTEL-ready trace propagation for Tier0 services
2. PrometheusRule and Alertmanager routing as code
3. SLO burn-rate deployment gate in CI/CD
4. Policy-as-code admission and CI policy checks
5. Scheduled game day and reliability scorecard automation

## 1) Tier0 metrics and tracing

Services upgraded:
- `services/api-gateway`
- `services/checkout`
- `services/payments`
- `services/orders`

Added:
- `/metrics` endpoint using Prometheus client
- request counter and latency histogram
- request trace ID propagation via `x-trace-id`
- OTEL API span creation hooks

## 2) Reliability alerts as code

Added manifests:
- `platform/k8s/observability/reliability/prometheus-rules.yaml`
- `platform/k8s/observability/reliability/alertmanager-config.yaml`
- `platform/k8s/observability/reliability/kustomization.yaml`

The rules define fast and slow burn-rate alerts for Tier0 availability.

## 3) SLO burn-rate gate

Reusable deploy workflow now supports:
- `enforce_slo_gate`
- `slo_burn_rate_threshold`
- secret `SLO_GATE_ENDPOINT`

When enabled, deployment fails if reported burn-rate exceeds threshold.

Default enforcement enabled in:
- `.github/workflows/deploy-dev.yml`
- `.github/workflows/deploy-prod.yml`

## 4) Policy-as-code

CI policy checks:
- `policy/required-probes.rego`
- `policy/required-resources.rego`
- `policy/preview-service-type.rego`

Admission policies:
- `platform/k8s/policy/kyverno/`

Kyverno bundle enforces:
- required liveness and readiness probes
- required CPU/memory requests and limits
- restricted `LoadBalancer` usage in preview namespaces

## 5) Game day and scorecards

Automation workflows:
- `.github/workflows/game-day-drill.yml`
- `.github/workflows/reliability-scorecard.yml`

Support files:
- `.github/ISSUE_TEMPLATE/reliability-incident.yml`
- `scripts/reliability-scorecard.sh`

Outputs:
- scheduled scorecard markdown in `docs/reliability/scorecards/`
- recurring reliability issues for drill tracking and follow-up

## Operator setup checklist

1. Configure `SLO_GATE_ENDPOINT` secret in GitHub environments.
2. Ensure Prometheus Operator CRDs exist before applying reliability manifests.
3. Install Kyverno controller in the target cluster before applying ClusterPolicies.
4. Confirm `reliability` label exists in repository labels.
5. Review weekly scorecard issues and monthly game day outcomes.
