# System Design Interview Q&A Playbook (Project-Based)

## Purpose

This guide helps you answer system design interviews using this repository as a real case study.

It includes:
- beginner-friendly Q&A
- architecture-level Q&A
- FAANG-style interview patterns
- tech lead answer frameworks for dev, infra, reliability, and operations

---

## 1) 60-second project pitch

Use this opening in interviews:

> This project is a Kubernetes-first global marketplace platform built with microservices.  
> It separates request, data, and event planes:
> - request plane: web -> API gateway -> domain services
> - data plane: Postgres, Redis, OpenSearch
> - event plane: Debezium CDC -> Kafka -> Kafka Connect -> MinIO  
> It uses GitHub Actions for CI/CD, preview environments per PR, and reliability controls like SLO burn-rate gates and policy-as-code.

---

## 2) Core architecture questions and basic answers

### Q1: Why microservices instead of monolith?
**Answer:**  
Microservices let us scale and deploy domains independently, reduce blast radius, and align team ownership with business capabilities like catalog, checkout, and orders.

### Q2: Why do we keep both Postgres and OpenSearch?
**Answer:**  
Postgres is optimized for transactions and consistency. OpenSearch is optimized for search queries and indexing. This split prevents search traffic from degrading core write paths.

### Q3: Why add Redis?
**Answer:**  
Redis serves hot reads and transient state with low latency, reducing repeated load on transactional stores.

### Q4: Why event-driven architecture?
**Answer:**  
It decouples producers and consumers, allows async processing, and supports downstream analytics/archive without blocking transactional request latency.

### Q5: Why CDC with Debezium?
**Answer:**  
CDC captures real DB changes reliably, minimizing dual-write risks and creating a consistent change stream for Kafka consumers.

---

## 3) Architecture-level interview questions and answer style

### Q6: How does a checkout request flow through the system?
**Answer structure:**
1. Client calls API Gateway  
2. Gateway routes to checkout service  
3. Checkout orchestrates downstream calls and order creation  
4. Orders persist to Postgres  
5. CDC emits events to Kafka  
6. Kafka Connect sinks selected topics to MinIO

### Q7: How do you handle scale spikes?
**Answer:**  
Horizontal scaling at stateless service layer in Kubernetes, caching with Redis, independent scaling of read/search systems, and async buffering through Kafka.

### Q8: What are the key failure domains?
**Answer:**  
Gateway ingress, stateful data dependencies, event pipeline lag, cluster quota limits, and deployment control-plane failures. We isolate via namespaces, overlays, rollouts, and diagnostics.

### Q9: How do you design for isolation in preview environments?
**Answer:**  
Per-PR namespace isolation (`pr-<number>`), overlay-based config, TTL labels for cleanup, and restricted exposure policy.

### Q10: How do you approach trade-offs?
**Answer:**  
Prefer consistency for financial/ordering paths, availability and async processing for non-critical workflows, and explicit SLO/error-budget policy for release decisions.

---

## 4) FAANG-style system design interview questions (with project examples)

### Q11: Design a global marketplace backend
**How to answer:**
- functional requirements: browse, search, cart, checkout, orders
- non-functional: latency, availability, consistency, scalability
- APIs: gateway routes and service contracts
- storage strategy: transactional + cache + search + object storage
- eventing: change streams and async consumers
- reliability: SLOs, alerts, runbooks, canary gates
- security: policy-as-code, secrets governance, branch protections
- cost: right-size stateful infra, separate hot/cold paths

**Project example:**  
This repo implements all major planes with Kubernetes overlays and CI/CD automation.

### Q12: Design for 10x traffic growth
**Answer approach:**
- scale stateless services horizontally
- partition and tune Kafka topics
- increase Redis/OpenSearch capacity
- introduce read models and async fan-out
- tighten SLO-based release gates

### Q13: Design a reliable checkout system
**Answer approach:**
- idempotency keys
- payment/order state machine
- timeout/retry/circuit-breaker patterns
- compensating actions for partial failures
- audit/event log for reconciliation

### Q14: Design observability for this architecture
**Answer approach:**
- golden signals per service
- tiered SLOs
- burn-rate alerts
- dashboard layers: executive, journey, service, platform
- runbook-linked alert routing

### Q15: Design secure multi-environment deployment
**Answer approach:**
- branch protections
- environment-scoped secrets
- immutable image tags
- policy checks in CI + admission controls in cluster
- canary and rollback workflows

---

## 5) Tech lead interview: how to answer at architecture/dev/infra levels

Use this framing:

### A) Architecture level
- define boundaries and ownership per domain
- explain consistency model per workflow
- identify scaling bottlenecks and mitigation
- show trade-offs and why chosen

### B) Development level
- API contracts and backward compatibility
- testing strategy and CI quality gates
- rollout safety and blast-radius minimization
- developer experience and onboarding paths

### C) Infrastructure level
- cluster topology and namespace strategy
- stateful service constraints and capacity planning
- IaC workflows for repeatability
- policy enforcement and security posture

### D) Reliability level
- SLO targets and error-budget policy
- alert quality and incident response flow
- game days and scorecard operating cadence
- data-driven release governance

### E) Business/leadership level
- map technical choices to customer impact
- explain cost/performance trade-offs
- prioritize roadmap by risk and value
- show decision logs and communication clarity

---

## 6) High-value interview Q&A bank (short answers)

### Q16: How do you avoid tight coupling across services?
Use clear service ownership boundaries, explicit API contracts, and async events for non-immediate dependencies.

### Q17: How do you prevent preview environments from resource sprawl?
Use TTL labels, scheduled cleanup, and namespace-level isolation with controlled exposure.

### Q18: How do you enforce reliability before deploy?
Use SLO burn-rate gates, policy checks, canary rollout criteria, and rollback automation.

### Q19: How do you enforce platform standards?
Use CI policy-as-code checks and cluster admission policies (Kyverno) for required probes/resources.

### Q20: How do you handle incident learning?
Use incident templates, runbooks, RCAs, and reliability scorecards to convert incidents into backlog improvements.

### Q21: How do you reduce MTTR?
Use layered dashboards, trace IDs, actionable alerts, and predefined mitigation runbooks.

### Q22: How do you talk about cost optimization?
Right-size stateful resources, control LB exposure, use async architecture, and evaluate storage tiering (hot/warm/archive).

### Q23: How do you design for compliance/auditability?
Use immutable artifacts, declarative configs, policy controls, and event archive for traceability.

### Q24: How do you explain eventual consistency to interviewers?
Critical writes stay strongly consistent in transaction path; downstream read models and analytics update asynchronously through events.

### Q25: How do you mentor engineers in this architecture?
Provide reading order, service ownership map, runbook-driven operations, and small scoped tasks per domain.

---

## 7) “As Tech Lead, my final answer” template

Use this template in interviews:

1. clarify requirements and SLO expectations  
2. define architecture planes and service boundaries  
3. choose storage/eventing per access pattern  
4. design failure handling and retries/idempotency  
5. define observability and incident response  
6. define CI/CD + policy/security controls  
7. describe trade-offs, risks, and next iterations

Short close:

> I optimize for correctness on critical paths, scalability through decoupling, and operational excellence through measurable SLO governance.

---

## 8) Practice scenarios using this project

Use these mock prompts:
- “Design checkout for 99.95% availability in 30 days.”
- “Design multi-region expansion plan for this platform.”
- “Reduce p95 latency in product search by 40%.”
- “Recover from Kafka lag surge during peak events.”
- “Deploy safely when error budget burn is high.”

For each scenario, answer with:
- requirements
- current architecture constraints
- proposed design changes
- rollout plan
- observability and success metrics

---

## 9) Suggested prep order

1. `README.md`
2. `docs/ARCHITECTURE_DEEP_DIVE.md`
3. `docs/SRE_PLATFORM_BLUEPRINT.md`
4. `docs/PLATFORM_SRE_FAANG_IMPLEMENTATION.md`
5. `docs/FAANG_RELIABILITY_UPGRADE.md`
6. `docs/tools/TECHNOLOGY_STACK_BASICS_README.md`

Then practice answering 5–10 questions from this guide out loud in 2 formats:
- 60-second executive answer
- 5-minute deep technical answer
