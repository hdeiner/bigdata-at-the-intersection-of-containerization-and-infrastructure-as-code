#!/usr/bin/env bash

echo "$(tput bold)$(tput setaf 6)Run Hive Metastore$(tput sgr 0)"
source /home/ubuntu/.bash_profile

echo "$(tput bold)$(tput setaf 6)Update Instance Status Tag to provisioned$(tput sgr 0)"
aws ec2 create-tags --region us-east-1 --resources $INSTANCE_ID --tags Key=Status,Value=provisioned

echo "$(tput bold)$(tput setaf 6)Initialize Hive $HIVE_VERSION Metastore$(tput sgr 0)"
schematool -dbType postgres -initSchema

echo "$(tput bold)$(tput setaf 6)Start Hive "$HIVE_VERSION" Metastore Running$(tput sgr 0)"
nohup hive --service metastore &

echo "$(tput bold)$(tput setaf 6)Wait For Metastore To Start$(tput sgr 0)"
while true ; do
  result=$(grep -cE 'INFO \[main\] metastore\.HiveMetaStore\: TCP keepalive \= true' /tmp/ubuntu/hive.log)
  if [ $result = 1 ] ; then
    echo "$(tput bold)$(tput setaf 2)Metastore has started$(tput sgr 0)"
    break
  fi
  sleep 10
done

echo "$(tput bold)$(tput setaf 6)Update Instance Status Tag to running$(tput sgr 0)"
aws ec2 create-tags --region us-east-1 --resources $INSTANCE_ID --tags Key=Status,Value=running