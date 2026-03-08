# Architecture Documentation Tool README

## Why we implemented this

We needed one place where any engineer can quickly understand:
- how requests flow across services
- how data and events move through the platform
- how Kubernetes, Terraform, and CI/CD fit together

Without this, onboarding is slower and incident response is harder.

## What was implemented

- Deep architecture guide: `docs/ARCHITECTURE_DEEP_DIVE.md`
- Animated architecture visual: `docs/assets/global-marketplace-architecture.gif`

## How it works in this project

The deep-dive document explains the three planes:
- request plane (client -> gateway -> services)
- data plane (services -> Postgres/Redis/OpenSearch)
- event plane (CDC -> Kafka -> Connect -> MinIO)

The GIF provides a quick visual walkthrough of the same runtime flow.

## When to use it

- onboarding new developers
- debugging cross-service request issues
- explaining system design in PRs and design reviews
- validating deployment assumptions before infra changes
