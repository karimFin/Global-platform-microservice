#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TF_DIR="${ROOT_DIR}/infra/terraform/envs/dev"
NAMESPACE="${NAMESPACE:-marketplace-dev}"
GH_REPO="${GH_REPO:-}"
GH_REF="${GH_REF:-dev}"
WORKFLOW_NAME="${WORKFLOW_NAME:-Deploy Dev}"
INFRA_WORKFLOW_NAME="${INFRA_WORKFLOW_NAME:-Infra Dev}"
CREATE_NAMESPACE="${CREATE_NAMESPACE:-true}"
KUBECONFIG_FILE="${KUBECONFIG_FILE:-/tmp/kubeconfig-dev.yaml}"

extract_default() {
  local key="$1"
  awk -F'=' -v key="$key" '
    /^\[/ { in_default = ($0 == "[DEFAULT]") }
    in_default && $1 ~ "^[[:space:]]*" key "[[:space:]]*$" {
      val = $2
      sub(/^[[:space:]]+/, "", val)
      sub(/[[:space:]]+$/, "", val)
      gsub(/\r/, "", val)
      gsub(/"/, "", val)
      print val
      exit
    }
  ' "$HOME/.oci/config"
}

load_tf_env() {
  export TF_INPUT=0
  export TF_VAR_tenancy_ocid="${TF_VAR_tenancy_ocid:-$(extract_default tenancy)}"
  export TF_VAR_user_ocid="${TF_VAR_user_ocid:-$(extract_default user)}"
  export TF_VAR_fingerprint="${TF_VAR_fingerprint:-$(extract_default fingerprint)}"
  export TF_VAR_private_key_path="${TF_VAR_private_key_path:-$(extract_default key_file)}"
  export TF_VAR_region="${TF_VAR_region:-$(extract_default region)}"
  export TF_VAR_compartment_ocid="${TF_VAR_compartment_ocid:-$TF_VAR_tenancy_ocid}"
  TF_VAR_private_key_path="${TF_VAR_private_key_path/#\~/$HOME}"
  export TF_VAR_private_key_path
}

tf() {
  terraform -chdir="$TF_DIR" "$@"
}

detect_repo() {
  if [ -n "$GH_REPO" ]; then
    echo "$GH_REPO"
    return
  fi
  local remote
  remote="$(git -C "$ROOT_DIR" remote get-url origin 2>/dev/null || true)"
  if [[ "$remote" =~ github.com[:/]([^/]+/[^/.]+)(\.git)?$ ]]; then
    echo "${BASH_REMATCH[1]}"
    return
  fi
  gh repo view --json nameWithOwner -q .nameWithOwner
}

active_cluster_id() {
  load_tf_env
  oci ce cluster list \
    --compartment-id "$TF_VAR_compartment_ocid" \
    --all \
    --output json | jq -r '.data[] | select(.name=="gmp-oke-dev" and ."lifecycle-state"=="ACTIVE") | .id' | head -n 1
}

cmd_init() {
  tf init -reconfigure -upgrade
}

cmd_plan() {
  load_tf_env
  tf init -reconfigure
  tf plan
}

cmd_apply() {
  load_tf_env
  tf init -reconfigure
  tf apply -auto-approve
}

cmd_destroy() {
  load_tf_env
  tf init -reconfigure
  tf destroy -auto-approve
}

cmd_status() {
  load_tf_env
  tf init -reconfigure >/dev/null
  echo "Terraform state resources:"
  tf state list || true
  echo
  echo "Active OKE clusters:"
  oci ce cluster list --compartment-id "$TF_VAR_compartment_ocid" --all --output json | jq -r '.data[] | select(."lifecycle-state"=="ACTIVE") | .name + " " + .id'
  echo
  echo "Active Load Balancers:"
  oci lb load-balancer list --compartment-id "$TF_VAR_compartment_ocid" --all --output json | jq -r '.data[] | select(."lifecycle-state"=="ACTIVE") | ."display-name" + " " + .id'
}

cmd_kubeconfig() {
  local cid
  cid="$(active_cluster_id)"
  if [ -z "$cid" ]; then
    echo "No active gmp-oke-dev cluster found"
    exit 1
  fi
  load_tf_env
  oci ce cluster create-kubeconfig \
    --cluster-id "$cid" \
    --file "$KUBECONFIG_FILE" \
    --region "$TF_VAR_region" \
    --token-version 2.0.0 \
    --kube-endpoint PUBLIC_ENDPOINT
  echo "$KUBECONFIG_FILE"
}

cmd_secret() {
  local repo file
  repo="$(detect_repo)"
  file="${1:-$KUBECONFIG_FILE}"
  if [ ! -f "$file" ]; then
    echo "Kubeconfig file not found: $file"
    exit 1
  fi
  local payload
  payload="$(base64 < "$file" | tr -d '\n')"
  gh secret set KUBE_CONFIG_DEV --repo "$repo" --env dev --body "$payload"
}

cmd_deploy() {
  local repo
  repo="$(detect_repo)"
  gh workflow run "$WORKFLOW_NAME" \
    --repo "$repo" \
    --ref "$GH_REF" \
    -f create_namespace="$CREATE_NAMESPACE" \
    -f namespace="$NAMESPACE"
}

cmd_ci_apply() {
  local repo
  repo="$(detect_repo)"
  gh workflow run "$INFRA_WORKFLOW_NAME" \
    --repo "$repo" \
    --ref "$GH_REF" \
    -f action=apply
}

cmd_ci_destroy() {
  local repo
  repo="$(detect_repo)"
  gh workflow run "$INFRA_WORKFLOW_NAME" \
    --repo "$repo" \
    --ref "$GH_REF" \
    -f action=destroy
}

cmd_ship_dev() {
  git -C "$ROOT_DIR" push origin HEAD:dev
}

cmd_up() {
  cmd_apply
  cmd_kubeconfig
  cmd_secret "$KUBECONFIG_FILE"
  cmd_deploy
}

usage() {
  cat <<EOF
Usage: scripts/devctl.sh <command>
Commands:
  init         Terraform init for dev env
  plan         Terraform plan for dev env
  apply        Terraform apply for dev env
  destroy      Terraform destroy for dev env
  status       Show Terraform state + active OCI cluster/LB
  kubeconfig   Write kubeconfig for active gmp-oke-dev cluster
  secret       Update KUBE_CONFIG_DEV GitHub environment secret
  deploy       Trigger Deploy Dev workflow
  ci-apply     Trigger Infra Dev workflow apply
  ci-destroy   Trigger Infra Dev workflow destroy
  ship-dev     Push current HEAD to dev branch
  up           Apply infra + kubeconfig secret + deploy
EOF
}

main() {
  local cmd="${1:-}"
  case "$cmd" in
    init) cmd_init ;;
    plan) cmd_plan ;;
    apply) cmd_apply ;;
    destroy) cmd_destroy ;;
    status) cmd_status ;;
    kubeconfig) cmd_kubeconfig ;;
    secret) shift; cmd_secret "${1:-}" ;;
    deploy) cmd_deploy ;;
    ci-apply) cmd_ci_apply ;;
    ci-destroy) cmd_ci_destroy ;;
    ship-dev) cmd_ship_dev ;;
    up) cmd_up ;;
    *) usage; exit 1 ;;
  esac
}

main "$@"
