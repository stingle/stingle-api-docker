#!/bin/bash
source .env
docker pull stingle/stingle-api:latest
docker compose $COMPOSE_PARAMS -p $CONTAINER_NAME stop web && docker compose -p $CONTAINER_NAME up -d web