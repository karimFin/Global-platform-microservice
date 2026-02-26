#!/usr/bin/env bash
set -euo pipefail

SERVICES=("api-gateway" "identity" "seller" "catalog" "search" "pricing" "inventory" "cart" "checkout" "payments" "orders" "fulfillment" "notifications" "reviews" "analytics")
REGISTRY="local"
SHA="$(git rev-parse --short HEAD || echo dev)"

echo "==> Install root dev deps"
npm install

echo "==> Lint"
npm run lint

echo "==> Unit tests"
for svc in "${SERVICES[@]}"; do
  echo "-- $svc"
  (cd "services/$svc" && npm ci && npm test)
done

echo "==> Build images"
for svc in "${SERVICES[@]}"; do
  echo "-- $svc"
  docker build -t "${REGISTRY}/${svc}:${SHA}" "services/${svc}"
done

echo "==> SBOM via Syft"
for svc in "${SERVICES[@]}"; do
  docker run --rm -v /var/run/docker.sock:/var/run/docker.sock anchore/syft:latest "${REGISTRY}/${svc}:${SHA}" -o spdx-json > "sbom-${svc}.spdx.json"
done

echo "==> Trivy scan"
for svc in "${SERVICES[@]}"; do
  docker run --rm -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy:latest image --no-progress --exit-code 0 --severity HIGH,CRITICAL "${REGISTRY}/${svc}:${SHA}"
done

echo "Local CI completed"
