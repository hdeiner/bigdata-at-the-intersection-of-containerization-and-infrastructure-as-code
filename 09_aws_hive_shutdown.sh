#!/usr/bin/env bash
echo "$(tput bold)$(tput setaf 6)Shutdown Apache Hive AWS$(tput sgr 0)"

terraform destroy -auto-approve

aws s3 rb s3://hadoop-scratchpad --force > /dev/null 2> /dev/null
