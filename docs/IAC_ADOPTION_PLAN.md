# IaC Adoption Plan

## Current state

Infrastructure is already partially declarative:
- OCI networking and OKE are provisioned with Terraform in `infra/terraform`.
- Application runtime is declared with Kubernetes manifests in `platform/k8s`.
- CI/CD is versioned as code in `.github/workflows`.

The remaining gap is imperative runtime mutation in workflows and ad-hoc operator commands.

## What was converted now

### 1) Preview deploy uses a dedicated declarative overlay
- Added `platform/k8s/overlays/preview/kustomization.yaml`.
- Preview pipeline now deploys `overlay: preview` instead of `overlay: dev`.
- This makes preview behavior explicit in versioned manifests.

### 2) Preview data secrets moved from workflow commands into Kustomize IaC
- `postgres-credentials` and `minio-credentials` are generated via `secretGenerator` in the preview overlay.
- Removed imperative secret creation steps from reusable CI workflow.

### 3) Preview web exposure moved from runtime patching to overlay patch
- `web` service type override to `ClusterIP` now lives in preview overlay patch.
- Removed imperative `kubectl patch svc web ...` from reusable CI workflow.

## High-value next conversions

### A) GitHub repository/platform controls as Terraform
- Add Terraform GitHub provider for:
  - labels (`preview`)
  - branch protections
  - environment variables
  - selected repository secrets metadata lifecycle

### B) Secret management via external secret operator
- Replace plaintext/static secret generation with:
  - External Secrets Operator
  - OCI Vault backed secret sync
  - namespace-scoped ExternalSecret resources

### C) Job lifecycle as GitOps hooks
- Bootstrap jobs are still deleted imperatively before apply due immutable templates.
- Move to one of:
  - Argo CD hooks / Helm hooks
  - versioned job names using suffix strategy
  - CronJob + controller pattern for idempotent reconcile

### D) Policy as code
- Add OPA Gatekeeper/Kyverno policies for:
  - required probes and resource limits
  - restricted service types in preview namespaces
  - image source and tag policies

### E) Observability as code hardening
- Keep Grafana dashboards in Git (done).
- Add PrometheusRule resources for burn-rate alerts.
- Add Alertmanager route config in manifests.

## Priority order (recommended)

1. External secrets + vault integration
2. PrometheusRule + Alertmanager config as code
3. GitHub org/repo guardrails in Terraform
4. Replace bootstrap-job deletion strategy with GitOps hook model
5. Policy-as-code admission controls

## Success criteria

- Zero manual `kubectl patch/create secret` in CI for app behavior.
- Preview and dev environments fully reproducible from Git state.
- Drift detection for infra and platform controls.
- Auditable change history for reliability, security, and release guardrails.
