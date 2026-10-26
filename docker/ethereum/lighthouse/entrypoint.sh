#!/usr/bin/env bash

set -euo pipefail

external_ip="$(cat /run/init/external-ip)"
exec lighthouse beacon_node \
  --datadir /var/lib/lighthouse \
  --network mainnet \
  --execution-endpoint "http://reth-${POD_ORDINAL}.reth:8551" \
  --execution-jwt /shared/jwt.hex \
  --http \
  --http-address 0.0.0.0 \
  --checkpoint-sync-url https://mainnet.checkpoint.sigp.io \
  --enr-address "$external_ip" \
  --disable-upnp \
  --target-peers 30 \
  --disable-enr-auto-update \
  --metrics \
  --metrics-address 0.0.0.0
