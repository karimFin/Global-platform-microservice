#!/usr/bin/env bash
set -euo pipefail

THRESHOLD="2"
ERROR_BUDGET_RATIO="0.0005"
SERVICES_REGEX="api-gateway|checkout|payments|orders"
STATUS_CODE_REGEX="5.."
WINDOW="5m"
PRINT_QUERY="false"

usage() {
  cat <<'EOF'
Usage:
  scripts/slo-burn-rate-check.sh [options]

Required environment:
  PROMETHEUS_URL                 Prometheus base URL

Optional environment:
  PROMETHEUS_BEARER_TOKEN        Bearer token for Prometheus API auth

Options:
  --threshold <number>           Burn-rate threshold (default: 2)
  --error-budget-ratio <number>  Error budget ratio (default: 0.0005)
  --services <regex>             Service regex (default: api-gateway|checkout|payments|orders)
  --status-regex <regex>         Error status regex (default: 5..)
  --window <duration>            PromQL rate window (default: 5m)
  --print-query                  Print generated PromQL query
  -h, --help                     Show this help
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    --threshold)
      THRESHOLD="${2:-}"
      shift 2
      ;;
    --error-budget-ratio)
      ERROR_BUDGET_RATIO="${2:-}"
      shift 2
      ;;
    --services)
      SERVICES_REGEX="${2:-}"
      shift 2
      ;;
    --status-regex)
      STATUS_CODE_REGEX="${2:-}"
      shift 2
      ;;
    --window)
      WINDOW="${2:-}"
      shift 2
      ;;
    --print-query)
      PRINT_QUERY="true"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1"
      usage
      exit 1
      ;;
  esac
done

if [ -z "${PROMETHEUS_URL:-}" ]; then
  echo "PROMETHEUS_URL is required"
  exit 1
fi

if [ -z "$ERROR_BUDGET_RATIO" ] || [ "$ERROR_BUDGET_RATIO" = "0" ]; then
  echo "error-budget-ratio must be non-zero"
  exit 1
fi

QUERY="sum(rate(http_requests_total{service=~\"${SERVICES_REGEX}\",status_code=~\"${STATUS_CODE_REGEX}\"}[${WINDOW}])) / clamp_min(sum(rate(http_requests_total{service=~\"${SERVICES_REGEX}\"}[${WINDOW}])), 0.000001)"

if [ "$PRINT_QUERY" = "true" ]; then
  echo "PromQL query:"
  echo "$QUERY"
fi

ENCODED_QUERY=$(jq -rn --arg q "$QUERY" '$q|@uri')
if [ -n "${PROMETHEUS_BEARER_TOKEN:-}" ]; then
  RESPONSE=$(curl -fsSL -H "Authorization: Bearer ${PROMETHEUS_BEARER_TOKEN}" "${PROMETHEUS_URL%/}/api/v1/query?query=${ENCODED_QUERY}")
else
  RESPONSE=$(curl -fsSL "${PROMETHEUS_URL%/}/api/v1/query?query=${ENCODED_QUERY}")
fi

ERROR_RATIO=$(printf '%s' "$RESPONSE" | jq -r '.data.result[0].value[1] // empty')
if [ -z "$ERROR_RATIO" ]; then
  ERROR_RATIO="0"
fi

BURN_RATE=$(awk "BEGIN { printf \"%.6f\", ($ERROR_RATIO / $ERROR_BUDGET_RATIO) }")

echo "Prometheus: ${PROMETHEUS_URL}"
echo "Services regex: ${SERVICES_REGEX}"
echo "Status regex: ${STATUS_CODE_REGEX}"
echo "Window: ${WINDOW}"
echo "Error budget ratio: ${ERROR_BUDGET_RATIO}"
echo "Error ratio: ${ERROR_RATIO}"
echo "Burn rate: ${BURN_RATE}"
echo "Threshold: ${THRESHOLD}"

if awk "BEGIN {exit !($BURN_RATE > $THRESHOLD)}"; then
  echo "SLO gate: FAIL"
  exit 1
fi

echo "SLO gate: PASS"
