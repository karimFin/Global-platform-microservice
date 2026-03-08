# Platform SRE Blueprint (FAANG-Style)

## 1) SRE mission and operating model

Platform SRE owns reliability as a product:
- define reliability targets with product owners
- encode those targets into measurable SLOs
- run proactive detection through golden-signal telemetry
- reduce toil with automation and safe-by-default release policies
- drive post-incident learning into architecture and runbooks

Ownership split:
- **Service teams** own service correctness and instrumentation
- **Platform SRE** owns reliability standards, tooling, alert quality, incident process
- **Incident commander rotation** runs coordinated response for high-severity events

---

## 2) Reliability tiers and service catalog

Create a tiered service catalog first:
- **Tier 0**: API Gateway, Orders, Payments
- **Tier 1**: Catalog, Search, Inventory, Checkout, Identity
- **Tier 2**: Notifications, Reviews, Analytics, Seller, Fulfillment
- **Platform deps**: Postgres, Redis, Kafka, OpenSearch, Kafka Connect, MinIO

For each service, store:
- owner team
- pager rotation
- dependencies
- customer journey impact
- error budget policy

---

## 3) SLO design (request + dependency + platform)

Define SLOs per tier with fixed measurement windows.

### API request SLOs
- **Availability SLO** (per endpoint class):
  - Tier 0: 99.95% / 30d
  - Tier 1: 99.90% / 30d
  - Tier 2: 99.50% / 30d
- **Latency SLO**:
  - Tier 0 write APIs: p95 < 300ms
  - Tier 0 read APIs: p95 < 200ms
  - Tier 1 APIs: p95 < 400ms

### Platform dependency SLOs
- Postgres primary availability: 99.95%
- Kafka produce availability: 99.90%
- Redis availability: 99.90%
- OpenSearch query success: 99.50%

### Event pipeline SLOs
- CDC lag SLO: p95 lag < 60s (Postgres -> Kafka)
- Sink freshness SLO: p95 < 3m (Kafka -> MinIO)

### Error budget policy
- 100% budget healthy: normal release velocity
- 50% consumed: require reliability sign-off on risky changes
- 80% consumed: freeze non-critical releases for affected tier
- 100% consumed: reliability-only changes until recovery

---

## 4) Golden signals framework

For every request-serving component, enforce four golden signals:
- **Latency**: p50/p95/p99, split by route and status class
- **Traffic**: RPS, queue depth, consumer throughput
- **Errors**: 5xx rate, dependency error rate, business-failure rate
- **Saturation**: CPU, memory, pod restart rate, connection pool usage

For stateful and event infrastructure:
- Postgres: lock wait, slow query, replication lag, connection usage
- Kafka: partition under-replicated count, producer error rate, consumer lag
- Redis: evictions, memory ratio, command latency
- OpenSearch: indexing latency, query latency, heap pressure

---

## 5) Telemetry stack implementation

Recommended reference stack:
- **Metrics**: Prometheus + Alertmanager
- **Visualization**: Grafana
- **Logs**: Loki or OpenSearch log index
- **Tracing**: OpenTelemetry SDK + OTEL Collector + Tempo/Jaeger
- **SLO math**: Sloth or native recording rules + Grafana SLO dashboards

Instrumentation baseline:
- add OpenTelemetry auto/manual instrumentation in all Node services
- enforce structured JSON logs with trace_id/span_id
- expose `/metrics` endpoints for service + business metrics
- define shared metric naming conventions and labels

---

## 6) Dashboard architecture

Use a layered dashboard model:

1. **Executive reliability dashboard**
   - SLO attainment by tier
   - error-budget burn by service
   - active incidents and MTTR trend

2. **Journey dashboards** (Browse, Cart, Checkout, Payment)
   - API latency/error per journey step
   - dependency health overlays
   - conversion-impact hints

3. **Service dashboards**
   - golden signals + top dependencies
   - deployment markers and config changes
   - per-endpoint latency and error cardinality

4. **Platform dashboards**
   - Postgres, Kafka, Redis, OpenSearch, OKE node/pod health

All dashboards should include:
- fixed “what changed” panel (deploys, config, feature flags)
- runbook links
- SLO panels with current burn rate

---

## 7) Alerting strategy (high signal, low noise)

Adopt multi-window multi-burn-rate alerting for SLO breaches:
- fast burn alert (e.g., 5m / 1h windows)
- slow burn alert (e.g., 1h / 6h windows)

Alert classes:
- **Page**: immediate user impact or imminent SLO breach
- **Ticket**: reliability risk without acute user impact
- **Info**: trend/anomaly investigation

Alert quality rules:
- every page alert must have runbook URL
- every alert must map to one owner and one escalation path
- deduplicate correlated platform alerts through dependency graph routing

---

## 8) Incident management and runbooks

Define severity model:
- **SEV-1**: major customer impact, core journey unavailable
- **SEV-2**: partial outage/degradation in critical path
- **SEV-3**: contained issue with workaround

Incident roles:
- Incident Commander
- Operations Lead
- Communications Lead
- Subject Matter Experts (service/platform)

Runbook template per service:
- symptoms and trigger conditions
- immediate mitigation actions
- rollback and safe-mode toggles
- dependency isolation checks
- verification checklist
- escalation matrix

Post-incident standard:
- blameless RCA within 48h
- remediation tasks tagged by prevention/detection/mitigation
- follow-up SLO or alert updates

---

## 9) Progressive delivery and safety rails

For dev->prod reliability hardening:
- canary rollout with automated health gates
- rollback on latency/error SLO breach
- deploy freeze hooks when error budget burn is critical
- config and feature flag guardrails for risky paths (checkout/payment)

Preview environments (already in platform) should include:
- namespace-isolated smoke checks
- short SLI probes for API gateway and critical routes
- teardown and TTL cleanup validation

---

## 10) 90-day implementation roadmap

### Phase 1 (Weeks 1–3): Foundation
- service catalog + reliability tiering
- baseline metrics/log schema standard
- initial dashboards for gateway + tier 0 services
- SEV process and on-call schedule

### Phase 2 (Weeks 4–7): SLO + alert maturity
- formal SLOs and error-budget policy
- burn-rate alerts and alert routing cleanup
- core runbooks for API Gateway, Orders, Payments, Postgres, Kafka

### Phase 3 (Weeks 8–12): Automation + scale
- canary and rollback gates tied to SLO signals
- tracing coverage across key request journeys
- quarterly game day and chaos drills
- reliability scorecards per team

---

## 11) Success metrics for SRE program

Track these program KPIs:
- paging volume per week (target down)
- actionable alert ratio (target up)
- MTTD / MTTR by severity
- change failure rate
- percent services with production SLOs
- percent services with complete runbooks
- error budget policy compliance rate

This converts reliability from ad-hoc firefighting into a measurable engineering system.
