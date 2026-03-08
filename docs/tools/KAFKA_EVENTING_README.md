# Kafka Eventing README

## Why we implemented Kafka

Microservices need asynchronous communication for reliability and scale.
Kafka decouples producers and consumers so one service slowdown does not block the whole system.

## How it works here

- Kafka is the event backbone for domain events and CDC streams
- Debezium publishes Postgres changes into Kafka topics
- Kafka Connect forwards selected topics to object storage

Related bootstrap jobs:
- `kafka-topics-init`
- `debezium-register`
- `s3-sink-register`

## Why this is a good design

- resilient event-driven integration between services
- replayable event history
- supports analytics and downstream processing

## Basic commands

```bash
kubectl get pods -n marketplace-dev -l app=kafka
kubectl logs -n marketplace-dev job/kafka-topics-init
```
