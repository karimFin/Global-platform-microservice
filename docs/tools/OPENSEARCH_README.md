# OpenSearch README

## Why we implemented OpenSearch

Marketplace workloads need strong product/search discovery.
OpenSearch gives optimized indexing and query capabilities beyond transactional databases.

## How it works here

- OpenSearch runs in the Kubernetes stack
- services index searchable data for fast query responses
- search workloads are separated from transactional writes

## Why this is beneficial

- better search latency and relevance tuning
- keeps Postgres focused on transactions
- supports analytics-style query patterns

## Basic commands

```bash
kubectl get statefulset -n marketplace-dev opensearch
kubectl rollout status statefulset/opensearch -n marketplace-dev
```
