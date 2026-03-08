# Postgres Datastore README

## Why we implemented Postgres

The platform needs strong consistency for transactional operations like orders and payments.
Postgres is used as the system of record.

## How it works here

- Postgres runs as a stateful workload in Kubernetes
- domain services persist transactional data in Postgres
- Debezium captures database changes for event streaming

## Why this is a strong choice

- reliable ACID transactions
- mature ecosystem and tooling
- clear separation between transactional storage and async event pipelines

## Basic commands

```bash
kubectl get statefulset -n marketplace-dev postgres
kubectl rollout status statefulset/postgres -n marketplace-dev
```
