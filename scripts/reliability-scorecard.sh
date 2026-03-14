#!/usr/bin/env bash
set -euo pipefail

REPO="${1:-}"
if [ -z "$REPO" ]; then
  echo "Usage: reliability-scorecard.sh <owner/repo>"
  exit 1
fi

TMP_JSON="$(mktemp)"
gh run list --repo "$REPO" --limit 100 --json name,conclusion,createdAt > "$TMP_JSON"

TOTAL=$(jq 'length' "$TMP_JSON")
SUCCESS=$(jq '[.[] | select(.conclusion=="success")] | length' "$TMP_JSON")
FAILED=$(jq '[.[] | select(.conclusion=="failure")] | length' "$TMP_JSON")
CANCELLED=$(jq '[.[] | select(.conclusion=="cancelled")] | length' "$TMP_JSON")

if [ "$TOTAL" -gt 0 ]; then
  SUCCESS_RATE=$(awk "BEGIN { printf \"%.2f\", ($SUCCESS/$TOTAL)*100 }")
else
  SUCCESS_RATE="0.00"
fi

DATE_UTC="$(date -u +%F)"

cat <<EOF
# Reliability Scorecard ($DATE_UTC)

- Total workflow runs sampled: $TOTAL
- Successful runs: $SUCCESS
- Failed runs: $FAILED
- Cancelled runs: $CANCELLED
- Success rate: ${SUCCESS_RATE}%

## Focus checklist

- [ ] Review Tier0 burn-rate alerts
- [ ] Review incident count and MTTR trend
- [ ] Tune noisy alerts
- [ ] Validate runbook freshness for top incidents
- [ ] Plan next reliability hardening tasks
EOF
