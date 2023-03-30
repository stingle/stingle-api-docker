#!/bin/bash
source .env
docker pull stingle/stingle-api:latest
bin/dockerStop.sh
bin/dockerStart.sh