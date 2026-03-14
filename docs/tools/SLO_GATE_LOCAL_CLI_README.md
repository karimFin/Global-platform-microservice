# SLO Gate Local CLI README

## Purpose

This guide documents every command related to local SLO burn-rate checks so you can validate the same gate logic used by deployments.

## Script

- Path: `scripts/slo-burn-rate-check.sh`
- Requires:
  - `curl`
  - `jq`
  - `awk`
  - `PROMETHEUS_URL` environment variable

## Base command

```bash
bash scripts/slo-burn-rate-check.sh
```

## Required environment command

```bash
export PROMETHEUS_URL=https://prometheus.example.com
```

## Optional auth command

```bash
export PROMETHEUS_BEARER_TOKEN=<token>
```

## Full command with all options

```bash
bash scripts/slo-burn-rate-check.sh \
  --threshold 2 \
  --error-budget-ratio 0.0005 \
  --services "api-gateway|checkout|payments|orders" \
  --status-regex "5.." \
  --window 5m \
  --print-query
```

## Option reference

- `--threshold <number>`: burn-rate threshold; gate fails when burn-rate is higher
- `--error-budget-ratio <number>`: SLO error budget ratio
- `--services <regex>`: regex filter for service label
- `--status-regex <regex>`: regex for error status codes
- `--window <duration>`: PromQL rate window
- `--print-query`: prints exact PromQL query before evaluation
- `-h`, `--help`: usage output

## Makefile commands

Default dev-style threshold:

```bash
make slo-gate-check
```

Prod-style threshold:

```bash
make slo-gate-check-prod
```

Custom threshold command:

```bash
SLO_BURN_RATE_THRESHOLD=1.5 make slo-gate-check
```

Custom error budget command:

```bash
SLO_ERROR_BUDGET_RATIO=0.001 make slo-gate-check
```

Custom service regex command:

```bash
SLO_SERVICES_REGEX="api-gateway|orders" make slo-gate-check
```

Custom status regex command:

```bash
SLO_STATUS_REGEX="5..|429" make slo-gate-check
```

Custom window command:

```bash
SLO_WINDOW=10m make slo-gate-check
```

## CI parity commands

The deploy workflows use the same formula and query pattern:
- `.github/workflows/reusable-cicd.yml`
- Inputs:
  - `enforce_slo_gate`
  - `slo_burn_rate_threshold`
  - `slo_error_budget_ratio`
- Secrets:
  - `PROMETHEUS_URL`
  - `PROMETHEUS_BEARER_TOKEN` (optional)

## Exit behavior

- exit `0`: gate passed
- exit `1`: gate failed or misconfigured
