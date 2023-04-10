#!/bin/bash
source .env
docker compose -p $CONTAINER_NAME exec web bash -c "cd /var/www/html/ && ./bin/setup.php $@"