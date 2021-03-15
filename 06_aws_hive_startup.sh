#!/usr/bin/env bash
echo "$(tput bold)$(tput setaf 6)Startup Apache Hive in AWS$(tput sgr 0)"

aws s3 mb s3://hadoop-scratchpad > /dev/null 2> /dev/null

terraform init
terraform apply -auto-approve