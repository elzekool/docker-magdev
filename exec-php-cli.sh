#!/bin/bash
docker exec -it -u www-data $(docker-compose ps | grep w | awk '{print $1;}') /usr/local/bin/php $*
