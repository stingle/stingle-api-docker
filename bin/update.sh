#!/bin/bash
source .env
git pull
docker pull stingle/stingle-api:latest
bin/dockerStop.sh
bin/dockerStart.sh
for dir in addons/*; do (cd "$dir" && git pull); done
bin/deleteDockerCache.sh