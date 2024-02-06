#!/bin/sh

ALLOW_ORIGINS="${ALLOW_ORIGINS:?ALLOW_ORIGINS is required}"

[ -z "${ALLOW_ORIGINS}" ] && echo "ALLOW_ORIGINS is required" && exit 1

echo "Starting IPFS Gateway..."
ipfs init
ipfs daemon &
sleep 3

echo "IPFS Gateway is ready!"

ipfs config Swarm.ConnMgr.Type "none"
ipfs config --json API.HTTPHeaders.Access-Control-Allow-Origin "[\"${ALLOW_ORIGINS}\"]"
ipfs config --json API.HTTPHeaders.Access-Control-Allow-Methods "[\"HEAD\", \"GET\", \"OPTIONS\"]"

ipfs config --json show

echo "Starting server..."

/app/proxy_app

tail -f /dev/null
