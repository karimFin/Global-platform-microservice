# MinIO Object Storage README

## Why we implemented MinIO

The event pipeline needs durable object storage for archived event data.
MinIO provides S3-compatible storage in-cluster for this purpose.

## How it works here

- Kafka Connect sink writes selected event topics to MinIO
- bucket bootstrap job ensures the events bucket exists
- downstream analytics can consume archived JSONL data

## Why this is useful

- low-friction local and cluster object storage
- S3-compatible tooling support
- clean separation between stream processing and long-term event storage

## Basic commands

```bash
kubectl get pods -n marketplace-dev -l app=minio
kubectl logs -n marketplace-dev job/minio-make-bucket
```
