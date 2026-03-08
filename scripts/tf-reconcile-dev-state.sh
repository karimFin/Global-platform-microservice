#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TF_DIR="${ROOT_DIR}/infra/terraform/envs/dev"
TF_CLOUD_ORGANIZATION="${TF_CLOUD_ORGANIZATION:-}"
TF_WORKSPACE="${TF_WORKSPACE:-gmp-dev}"

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

export TF_INPUT=0
if [ -z "$TF_CLOUD_ORGANIZATION" ]; then
  echo "TF_CLOUD_ORGANIZATION is required for remote Terraform backend."
  exit 1
fi
export TF_CLOUD_ORGANIZATION
export TF_WORKSPACE
export TF_VAR_tenancy_ocid="${TF_VAR_tenancy_ocid:-$(extract_default tenancy)}"
export TF_VAR_user_ocid="${TF_VAR_user_ocid:-$(extract_default user)}"
export TF_VAR_fingerprint="${TF_VAR_fingerprint:-$(extract_default fingerprint)}"
export TF_VAR_private_key_path="${TF_VAR_private_key_path:-$(extract_default key_file)}"
export TF_VAR_region="${TF_VAR_region:-$(extract_default region)}"
export TF_VAR_compartment_ocid="${TF_VAR_compartment_ocid:-$TF_VAR_tenancy_ocid}"
TF_VAR_private_key_path="${TF_VAR_private_key_path/#\~/$HOME}"
export TF_VAR_private_key_path

tf() {
  terraform -chdir="$TF_DIR" "$@"
}

import_if_present() {
  local address="$1"
  local id="${2:-}"
  if [ -z "$id" ] || [ "$id" = "null" ]; then
    return
  fi
  if tf state show "$address" >/dev/null 2>&1; then
    return
  fi
  tf import "$address" "$id" >/dev/null
}

tf init -reconfigure >/dev/null

COMP="$TF_VAR_compartment_ocid"

ACTIVE_CLUSTER_JSON="$(oci ce cluster list --compartment-id "$COMP" --all --output json | jq -c '.data | map(select(."lifecycle-state"=="ACTIVE" and .name=="gmp-oke-dev")) | sort_by(."time-created") | last // empty')"
if [ -n "$ACTIVE_CLUSTER_JSON" ]; then
  CLUSTER_ID="$(printf '%s' "$ACTIVE_CLUSTER_JSON" | jq -r '.id')"
  VCN_ID="$(printf '%s' "$ACTIVE_CLUSTER_JSON" | jq -r '."vcn-id"')"
else
  CLUSTER_ID=""
  VCN_ID="$(oci network vcn list --compartment-id "$COMP" --all --output json | jq -r '.data | map(select(."lifecycle-state"=="AVAILABLE" and ."display-name"=="gmp-vcn")) | sort_by(."time-created") | last | .id // empty')"
fi

if [ -z "$VCN_ID" ]; then
  echo "No candidate gmp-vcn found; nothing to reconcile."
  exit 0
fi

IGW_ID="$(oci network internet-gateway list --compartment-id "$COMP" --all --output json | jq -r --arg V "$VCN_ID" '.data | map(select(."lifecycle-state"=="AVAILABLE" and ."vcn-id"==$V and ."display-name"=="gmp-igw")) | sort_by(."time-created") | last | .id // empty')"
NAT_ID="$(oci network nat-gateway list --compartment-id "$COMP" --all --output json | jq -r --arg V "$VCN_ID" '.data | map(select(."lifecycle-state"=="AVAILABLE" and ."vcn-id"==$V and ."display-name"=="gmp-nat")) | sort_by(."time-created") | last | .id // empty')"

PUB_RT_ID="$(oci network route-table list --compartment-id "$COMP" --all --output json | jq -r --arg V "$VCN_ID" '.data | map(select(."lifecycle-state"=="AVAILABLE" and ."vcn-id"==$V and ."display-name"=="gmp-public-rt")) | sort_by(."time-created") | last | .id // empty')"
PRV_RT_ID="$(oci network route-table list --compartment-id "$COMP" --all --output json | jq -r --arg V "$VCN_ID" '.data | map(select(."lifecycle-state"=="AVAILABLE" and ."vcn-id"==$V and ."display-name"=="gmp-private-rt")) | sort_by(."time-created") | last | .id // empty')"

PUB_SL_ID="$(oci network security-list list --compartment-id "$COMP" --all --output json | jq -r --arg V "$VCN_ID" '.data | map(select(."lifecycle-state"=="AVAILABLE" and ."vcn-id"==$V and ."display-name"=="gmp-public-sl")) | sort_by(."time-created") | last | .id // empty')"
PRV_SL_ID="$(oci network security-list list --compartment-id "$COMP" --all --output json | jq -r --arg V "$VCN_ID" '.data | map(select(."lifecycle-state"=="AVAILABLE" and ."vcn-id"==$V and ."display-name"=="gmp-private-sl")) | sort_by(."time-created") | last | .id // empty')"

PUB_SUBNET_ID="$(oci network subnet list --compartment-id "$COMP" --all --output json | jq -r --arg V "$VCN_ID" '.data | map(select(."lifecycle-state"=="AVAILABLE" and ."vcn-id"==$V and ."display-name"=="gmp-public-subnet")) | sort_by(."time-created") | last | .id // empty')"
PRV_SUBNET_ID="$(oci network subnet list --compartment-id "$COMP" --all --output json | jq -r --arg V "$VCN_ID" '.data | map(select(."lifecycle-state"=="AVAILABLE" and ."vcn-id"==$V and ."display-name"=="gmp-private-subnet")) | sort_by(."time-created") | last | .id // empty')"

if [ -n "$CLUSTER_ID" ]; then
  NODE_POOL_ID="$(oci ce node-pool list --compartment-id "$COMP" --cluster-id "$CLUSTER_ID" --all --output json | jq -r '.data | map(select(."lifecycle-state"=="ACTIVE" and .name=="gmp-oke-dev-pool")) | sort_by(."time-created") | last | .id // empty')"
else
  NODE_POOL_ID=""
fi

import_if_present "module.network.oci_core_vcn.this" "$VCN_ID"
import_if_present "module.network.oci_core_internet_gateway.igw" "$IGW_ID"
import_if_present "module.network.oci_core_nat_gateway.nat" "$NAT_ID"
import_if_present "module.network.oci_core_route_table.public_rt" "$PUB_RT_ID"
import_if_present "module.network.oci_core_route_table.private_rt" "$PRV_RT_ID"
import_if_present "module.network.oci_core_security_list.public_sl" "$PUB_SL_ID"
import_if_present "module.network.oci_core_security_list.private_sl" "$PRV_SL_ID"
import_if_present "module.network.oci_core_subnet.public" "$PUB_SUBNET_ID"
import_if_present "module.network.oci_core_subnet.private" "$PRV_SUBNET_ID"
import_if_present "module.oke.oci_containerengine_cluster.this" "$CLUSTER_ID"
import_if_present "module.oke.oci_containerengine_node_pool.pool" "$NODE_POOL_ID"

echo "Reconcile complete."
