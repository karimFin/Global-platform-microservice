# Platform SRE Layer Implementation (FAANG-Style)

## Objective

Implement a production-grade SRE layer for this platform using:
- SLOs and error budgets
- golden-signal observability
- Grafana dashboards with business + platform views
- incident runbooks and response workflow

---

## 1) SLO model for this codebase

### Tiering
- **Tier 0**: api-gateway, checkout, payments, orders
- **Tier 1**: catalog, search, cart, inventory, identity
- **Tier 2**: reviews, notifications, analytics, seller, fulfillment
- **Platform**: postgres, redis, kafka, opensearch, kafka-connect, minio

### Baseline SLOs
- Tier 0 availability: 99.95% / 30d
- Tier 1 availability: 99.90% / 30d
- Tier 2 availability: 99.50% / 30d
- API p95 latency:
  - Tier 0: < 300ms
  - Tier 1: < 400ms

### Error budget policy
- < 50% budget burn: normal release
- 50-80% burn: reliability signoff required
- > 80% burn: risky change freeze

---

## 2) Golden signals design

Track these everywhere:
- **Latency**: p50/p95/p99 by route and service
- **Traffic**: request rate by endpoint and service
- **Errors**: 5xx rate and error ratio by service
- **Saturation**: CPU, memory, restart counts, queue lag

Platform-specific signals:
- Postgres availability and slow query pressure
- Kafka consumer lag and throughput
- Redis memory pressure and evictions
- Kubernetes API latency and pod restart spikes

---

## 3) Grafana implementation in this repo

Implemented Kubernetes Grafana stack:
- [kustomization.yaml](file:///Users/mdmirajulkarim/Documents/k8s/global-marketplace-platform/platform/k8s/observability/grafana/kustomization.yaml)
- [grafana-deployment.yaml](file:///Users/mdmirajulkarim/Documents/k8s/global-marketplace-platform/platform/k8s/observability/grafana/grafana-deployment.yaml)
- [grafana-service.yaml](file:///Users/mdmirajulkarim/Documents/k8s/global-marketplace-platform/platform/k8s/observability/grafana/grafana-service.yaml)
- [datasources.yaml](file:///Users/mdmirajulkarim/Documents/k8s/global-marketplace-platform/platform/k8s/observability/grafana/provisioning/datasources/datasources.yaml)
- [dashboard-provider.yaml](file:///Users/mdmirajulkarim/Documents/k8s/global-marketplace-platform/platform/k8s/observability/grafana/provisioning/dashboards/dashboard-provider.yaml)

Provisioned dashboards:
- [executive-slo.json](file:///Users/mdmirajulkarim/Documents/k8s/global-marketplace-platform/platform/k8s/observability/grafana/dashboards/executive-slo.json)
- [customer-journey.json](file:///Users/mdmirajulkarim/Documents/k8s/global-marketplace-platform/platform/k8s/observability/grafana/dashboards/customer-journey.json)
- [platform-golden-signals.json](file:///Users/mdmirajulkarim/Documents/k8s/global-marketplace-platform/platform/k8s/observability/grafana/dashboards/platform-golden-signals.json)

---

## 4) Deploy commands

Simple commands added in Makefile:
- `make grafana-install`
- `make grafana-port-forward`
- `make grafana-uninstall`

Manual equivalent:

```bash
kubectl create secret generic grafana-admin \
  -n observability \
  --from-literal=username=admin \
  --from-literal=password=adminadmin \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl apply -k platform/k8s/observability/grafana
kubectl -n observability port-forward svc/grafana 3000:3000
```

Open: `http://localhost:3000`

---

## 5) Incident runbook standard

Every critical alert should map to a runbook with:
- impact statement and SEV level
- triage query links (dashboard + logs + traces)
- mitigation sequence
- rollback criteria
- owner escalation chain

Minimum runbooks to create first:
- API gateway high 5xx
- checkout/payment latency regression
- kafka lag growth
- postgres availability/degraded write path

---

## 6) Dashboard operating cadence

Weekly reliability review:
- SLO attainment trend by tier
- top burn-rate contributors
- noisy alerts removed or tuned
- runbook quality improvements

Monthly engineering review:
- error budget consumption by domain team
- MTTR and paging health
- reliability roadmap updates

---

## 7) Next hardening steps

1. Add service-level `/metrics` instrumentation in all Node services
2. Add OpenTelemetry traces and trace-to-log correlation
3. Add Alertmanager routes by service ownership
4. Add burn-rate alert rules and escalation policy
5. Add game day drills for checkout + payment failure scenarios

This creates an SRE layer consistent with high-scale engineering organizations while fitting this repository architecture.
