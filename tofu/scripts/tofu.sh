#!/usr/bin/env bash
# Runs tofu in tofu/ with the provider credentials from tofu/.env
set -euo pipefail

dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ -f "$dir/.env" ]]; then
  set -a
  source "$dir/.env"
  set +a
fi

missing=()
for var in B2_APPLICATION_KEY_ID B2_APPLICATION_KEY PROXMOX_VE_API_TOKEN TF_VAR_state_bucket; do
  [[ -n "${!var:-}" ]] || missing+=("$var")
done
if (( ${#missing[@]} )); then
  echo "Missing in $dir/.env: ${missing[*]}" >&2
  exit 1
fi

exec tofu -chdir="$dir" "$@"
