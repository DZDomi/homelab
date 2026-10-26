#!/usr/bin/env bash
# Runs helmfile against helm/helmfile.yaml with the chart secrets from helm/.env
set -euo pipefail

dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ -f "$dir/.env" ]]; then
  set -a
  source "$dir/.env"
  set +a
fi

missing=()
for var in TRUENAS_API_KEY REGISTRY_HA_SHARED_SECRET; do
  [[ -n "${!var:-}" ]] || missing+=("$var")
done
if (( ${#missing[@]} )); then
  echo "Missing in $dir/.env: ${missing[*]}" >&2
  exit 1
fi

exec helmfile -f "$dir/helmfile.yaml" "$@"
