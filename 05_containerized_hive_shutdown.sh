#!/usr/bin/env bash
echo "$(tput bold)$(tput setaf 6)Shutdown Apache Hive Locally$(tput sgr 0)"

docker-compose -f docker-compose.yml down

docker volume rm bigdata-at-the-intersection-of-containerization-and-infrastructure-as-code_namenode
docker volume rm bigdata-at-the-intersection-of-containerization-and-infrastructure-as-code_datanode
docker volume rm bigdata-at-the-intersection-of-containerization-and-infrastructure-as-code_postgresql