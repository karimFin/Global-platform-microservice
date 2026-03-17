# FAANG System Design Interview Guide (Beginner-Friendly, Project-Based)

## How to use this guide

If you are new, use this flow in every interview answer:

1. clarify requirements
2. list scale and reliability targets
3. draw high-level architecture
4. choose data stores and event flow
5. explain bottlenecks and failure handling
6. explain trade-offs
7. end with next improvements

Use this project as your real example.

---

## 1) 30-second and 90-second intro answers

### 30-second version

> This is a marketplace microservices platform.  
> Request flow is web to API gateway to domain services.  
> Data uses Postgres, Redis, and OpenSearch.  
> Event flow uses Debezium CDC to Kafka to Kafka Connect and MinIO.  
> Deployment is Kubernetes with GitHub Actions and reliability controls.

### 90-second version

> We split architecture into three planes.  
> Request plane handles user APIs through gateway and domain services.  
> Data plane separates transactional data from caching and search for performance.  
> Event plane publishes database changes to Kafka for async workflows and archival.  
> Operationally, we use Kubernetes overlays, preview namespaces, CI/CD gates, policy checks, and SLO burn-rate controls.

---

## 2) Basic architecture interview questions and answers

### Q: Why not one big database for everything?
**A:**  
One database causes mixed workload contention. We keep transactions in Postgres, fast cache in Redis, and search in OpenSearch so each workload is optimized.

### Q: Why use API Gateway?
**A:**  
Gateway gives one entry point, central auth/rate limits, and clean routing to domain services.

### Q: Why use Kafka here?
**A:**  
Kafka decouples producers and consumers. Services can publish events once and multiple downstream systems consume independently.

### Q: Why use Debezium CDC?
**A:**  
CDC gives reliable change capture from Postgres without risky dual writes.

### Q: Why Kubernetes?
**A:**  
Kubernetes provides scaling, rollouts, health checks, and environment consistency.

---

## 3) FAANG-style system design questions with project examples

### Q: Design an e-commerce backend for high scale
**Answer shape:**
- functional: browse, search, cart, checkout, orders
- non-functional: p95 latency, availability, consistency
- services: gateway + domain services
- data: Postgres + Redis + OpenSearch
- events: CDC -> Kafka -> consumers
- deploy: CI/CD + canary + rollback

**Project mapping:**  
This repository already implements this separation and deploy model.

### Q: How would you support 10x traffic?
**Answer shape:**
- horizontally scale stateless services
- tune Redis and OpenSearch cluster sizes
- partition Kafka topics and scale consumers
- add stricter SLO gate thresholds for safe rollouts

### Q: How do you design checkout reliability?
**Answer shape:**
- idempotency for order/checkout
- timeout and retry policies
- fallback behavior for dependency failures
- event audit for reconciliation

### Q: How do you design observability?
**Answer shape:**
- metrics per service (`/metrics`)
- request traces with trace-id propagation
- burn-rate alerts and runbook links
- dashboards for executive, journey, and service views

### Q: How do you secure multi-env deployments?
**Answer shape:**
- environment secrets and branch protections
- policy checks in CI
- admission controls in cluster
- immutable image tags and signed pipeline flow

---

## 4) Technical deep-dive Q&A

### Q: Where can bottlenecks appear first?
**A:**  
API gateway saturation, Postgres connection pressure, Kafka lag, OpenSearch heap pressure, or Kubernetes quota limits.

### Q: How do you reduce p95 latency quickly?
**A:**  
Cache hot paths in Redis, optimize heavy queries, move expensive sync operations to async event handlers.

### Q: How do you prevent bad deployments?
**A:**  
Use lint/tests, kustomize validation, policy checks, SLO burn-rate gate, and canary rollout with rollback.

### Q: How do you explain eventual consistency simply?
**A:**  
Critical transaction is saved first. Other read models and analytics update shortly after through events.

---

## 5) Architecture-level tech lead Q&A

### Q: How do you split service boundaries?
**A:**  
By business capability and ownership: catalog, cart, checkout, orders, payments, etc. Each service owns its API and change lifecycle.

### Q: How do you decide sync vs async?
**A:**  
Keep customer-critical confirmations synchronous. Move fan-out, analytics, notifications, and heavy downstream processing to async events.

### Q: How do you prioritize roadmap as a lead?
**A:**  
By impact and risk: reliability for tier0 flows first, then scale optimization, then feature expansion.

### Q: How do you communicate trade-offs in interview?
**A:**  
Use this line:  
“I choose consistency for payment/order paths, and eventual consistency for downstream read models to keep throughput high.”

---

## 6) Infrastructure and platform Q&A

### Q: How do you manage env differences?
**A:**  
Kustomize overlays for dev/prod/preview with shared base manifests.

### Q: How do you enforce platform standards?
**A:**  
Conftest Rego checks in CI and Kyverno admission policies in cluster.

### Q: How do you handle cloud resource cleanup?
**A:**  
Use Terraform destroy/cleanup workflow paths and verify action run status for completion.

### Q: How do you avoid preview environment sprawl?
**A:**  
Use namespace TTL labels and scheduled cleanup automation.

---

## 7) Simple answer template for beginners

Use this exact script:

1. “Let me confirm requirements and scale.”  
2. “I will split into request, data, and event planes.”  
3. “For data, I choose Postgres for transactions, Redis for cache, OpenSearch for search.”  
4. “For asynchronous processing, I use CDC and Kafka.”  
5. “For reliability, I enforce SLO gates, alerts, and rollback.”  
6. “Main trade-off is complexity vs scalability. This design prefers long-term scale and team autonomy.”

---

## 8) Practice prompts

Practice these out loud:
- design marketplace for 1M daily users
- reduce checkout failure rate by 50%
- scale search traffic 5x without database overload
- handle Kafka lag spike during campaign traffic
- deploy safely while error budget burn is high

For each prompt, answer in 4 parts:
- design
- reliability
- trade-offs
- rollout plan

---

## 9) Study plan to pass interviews

### Week 1
- learn architecture planes and service map
- practice 30-second and 90-second intro

### Week 2
- practice top 10 Q&A from this guide
- focus on sync vs async and data-store trade-offs

### Week 3
- practice reliability and incident questions
- rehearse canary, rollback, SLO, and policy answers

### Week 4
- do mock interviews with timer
- use this project diagrams and flows as examples

---

## 10) Final interview closing line

> I design systems by balancing correctness, scalability, and operability.  
> In this project, I use clear service boundaries, workload-specific data stores, event-driven decoupling, and reliability gates to keep customer-critical paths safe at scale.
