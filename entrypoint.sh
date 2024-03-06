#!/bin/sh

DOCKER_SCALE_NUM="$(curl -s --unix-socket /run/docker.sock "http://docker/containers/${HOSTNAME}/json" | jq -r .Name | cut -d _ -f 3)"
IPFS_DIR="/ipfs/${DOCKER_SCALE_NUM:-1}"

mkdir -p "${IPFS_DIR}"
ln -s "${IPFS_DIR}" /root/.ipfs >/dev/null 2>&1

ALLOW_ORIGINS="${ALLOW_ORIGINS:?ALLOW_ORIGINS is required}"

[ -z "${ALLOW_ORIGINS}" ] && echo "ALLOW_ORIGINS is required" && exit 1

echo "Starting IPFS Gateway..."
ipfs init

ipfs config Swarm.ConnMgr.Type "none"
ipfs config --json API.HTTPHeaders.Access-Control-Allow-Origin "[\"${ALLOWGINS}\"]"
ipfs config --json API.HTTPHeaders.Access-Control-Allow-Methods "[\"HEAD\", \"GET\", \"OPTIONS\"]"
ipfs config --json Datastore.StorageMax '"2GB"'

ipfs daemon --enable-gc &
sleep 3

echo "IPFS Gateway is ready!"

echo "Starting server..."

/app/proxy_app

tail -f /dev/null
