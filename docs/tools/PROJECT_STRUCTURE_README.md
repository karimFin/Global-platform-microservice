# Project Structure README

## Why this structure exists

This repository separates application code, platform runtime, and cloud infrastructure.
That separation keeps ownership clear and reduces change risk.

## Structure overview

- `services/`: backend microservices
- `frontend/`: web application
- `platform/k8s/`: Kubernetes manifests and overlays
- `infra/terraform/`: cloud infrastructure provisioning
- `.github/workflows/`: CI/CD pipelines
- `docs/`: architecture and operational documentation

## How this helps the team

- app teams can change business logic without touching infra
- platform teams can evolve deployment/runtime policies cleanly
- infra teams can manage cloud resources through Terraform
- docs stay close to code changes

## Why this is best for scaling

- clear boundaries between layers
- easier code reviews by domain
- safer rollout process with fewer cross-area side effects
- faster onboarding for new engineers
