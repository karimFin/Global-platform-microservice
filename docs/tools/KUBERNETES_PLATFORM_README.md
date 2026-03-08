# Kubernetes Platform README

## Why we implemented Kubernetes

This project runs many services that must scale and recover independently.
Kubernetes gives:
- service isolation
- self-healing pods
- declarative deployments
- environment overlays for dev/prod/preview

## How it works here

- Base manifests: `platform/k8s/base`
- Environment overlays: `platform/k8s/overlays/dev`, `platform/k8s/overlays/prod`, `platform/k8s/overlays/preview`
- Deploy pattern: `kubectl apply -k <overlay>`

## Why this is a good fit

- each microservice can roll out independently
- infrastructure services and app services live in one consistent runtime model
- preview namespaces are easy to create and clean up

## Basic commands

```bash
kubectl apply -k platform/k8s/overlays/dev
kubectl get pods -n marketplace-dev
kubectl rollout status deployment/api-gateway -n marketplace-dev
```
