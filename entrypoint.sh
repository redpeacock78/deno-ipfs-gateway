#!/bin/sh

ALLOW_ORIGINS="${ALLOW_ORIGINS:?ALLOW_ORIGINS is required}"
[ -z "${ALLOW_ORIGINS}" ] && echo "ALLOW_ORIGINS is required" && exit 1

echo "Starting IPFS Gateway..."

CONTAINER_NAME="$(curl -s --unix-socket /run/docker.sock "http://docker/containers/${HOSTNAME}/json" | jq -r .Name)"
DOCKER_SCALE_NUM="$(echo "${CONTAINER_NAME}" | awk -F"_" '{print $NF}')"
[ "${DOCKER_SCALE_NUM}" = "${CONTAINER_NAME}" ] && DOCKER_SCALE_NUM="$(echo "${CONTAINER_NAME}" | awk -F"-" '{print $NF}')"
[ "${DOCKER_SCALE_NUM}" = "${CONTAINER_NAME}" ] && DOCKER_SCALE_NUM="1"
IPFS_DIR="/ipfs/${DOCKER_SCALE_NUM}"

mkdir -p "${IPFS_DIR}"
ln -s "${IPFS_DIR}" /root/.ipfs >/dev/null 2>&1

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
