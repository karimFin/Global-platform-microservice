# Redis Cache README

## Why we implemented Redis

Some application reads need low latency.
Redis is used as a fast cache layer to reduce load on primary databases and improve response time.

## How it works here

- Redis runs in the Kubernetes platform stack
- services can read frequently accessed data from Redis first
- primary source of truth remains Postgres

## Why this is best practice

- lower response latency on hot paths
- reduced pressure on transactional database
- better overall throughput for read-heavy operations

## Basic commands

```bash
kubectl get pods -n marketplace-dev -l app=redis
kubectl rollout status deployment/redis -n marketplace-dev
```
