#!/usr/bin/env bash

set -euo pipefail

external_ip="$(cat /run/init/external-ip)"

exec reth node \
  --datadir /var/lib/reth \
  --chain mainnet \
  --minimal \
  --authrpc.addr 0.0.0.0 \
  --authrpc.jwtsecret /shared/jwt.hex \
  --nat "extip:$external_ip" \
  --max-peers 5 \
  --http \
  --http.addr 0.0.0.0 \
  --ws \
  --ws.addr 0.0.0.0 \
  --ws.origins '*' \
  --metrics 0.0.0.0:6060 \
  --engine.txpool-prewarming \
  --engine.prewarm-reuse \
  --engine.cross-block-cache-size 12288
