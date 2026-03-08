# Grafana Observability Stack README

## Why we implemented this

We needed production-style visibility for reliability:
- SLO tracking
- golden signals
- service and platform health

Manual dashboards are easy to drift. Dashboards as code stay consistent.

## What was implemented

- Kubernetes manifests for Grafana under `platform/k8s/observability/grafana`
- Provisioned dashboards:
  - executive SLO overview
  - customer journey health
  - platform golden signals
- Make targets:
  - `make grafana-install`
  - `make grafana-port-forward`
  - `make grafana-uninstall`

## How it works in this project

- Kustomize creates Grafana deployment, service, and dashboard configmaps.
- Grafana auto-loads datasource and dashboards from mounted provisioning files.
- Installation uses refreshed kubeconfig to avoid stale cluster endpoint failures.

## Expected operator flow

```bash
make grafana-install
make grafana-port-forward
```

Open `http://localhost:3000` and use environment credentials.
