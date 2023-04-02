#!/bin/bash
source .env
git pull
docker pull stingle/stingle-api:latest
docker compose $COMPOSE_PARAMS -p $CONTAINER_NAME stop web && docker compose $COMPOSE_PARAMS -p $CONTAINER_NAME start web
for dir in addons/*; do (cd "$dir" && git pull); done
bin/deleteDockerCache.sh