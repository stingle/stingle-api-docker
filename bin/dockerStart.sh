#!/bin/bash
source .env
docker compose $COMPOSE_PARAMS -p $CONTAINER_NAME up -d