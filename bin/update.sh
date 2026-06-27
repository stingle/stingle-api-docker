#!/bin/bash
set -e
source .env
git pull

# Default to the public floating tag. When a private composition manifest is
# configured (MANIFEST_REPO in .env), pin addons + lock + core image from it
# instead; otherwise keep the legacy "pull addons to latest" behaviour so the
# public repo works standalone.
WEB_IMAGE="stingle/stingle-api:latest"
if [ -n "${MANIFEST_REPO:-}" ]; then
  bin/applyManifest.sh
  WEB_IMAGE="$(jq -r '.core.image' manifest/manifest.json)"
else
  for dir in addons/*/; do [ -d "$dir/.git" ] && (cd "$dir" && git pull); done
fi
export WEB_IMAGE

docker pull "$WEB_IMAGE"
docker compose $COMPOSE_PARAMS -p $CONTAINER_NAME up -d
bin/composer.sh install --no-interaction
bin/deleteDockerCache.sh
