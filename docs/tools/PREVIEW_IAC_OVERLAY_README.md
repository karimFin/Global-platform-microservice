# Preview IaC Overlay README

## Why we implemented this

Preview deployments had imperative steps in workflows:
- create secrets at runtime
- patch service type at runtime

That approach is harder to audit and can drift.

We moved preview behavior into declarative IaC.

## What was implemented

- New overlay: `platform/k8s/overlays/preview/kustomization.yaml`
- Preview workflow now uses `overlay: preview`
- Runtime preview secret creation and service patch steps removed from reusable workflow

## How it works in this project

The preview overlay extends dev overlay and adds preview-specific intent:
- `secretGenerator` for preview data secrets
- `web` service forced to `ClusterIP`

So every preview namespace gets reproducible behavior directly from Git state.

## Benefits

- fewer imperative kubectl mutations in CI
- clearer change history in pull requests
- easier rollback and troubleshooting
