#!/usr/bin/env bash

echo "$(tput bold)$(tput setaf 6)Run Hive Server$(tput sgr 0)"
source /home/ubuntu/.bash_profile

echo "$(tput bold)$(tput setaf 6)Update Instance Status Tag to provisioned$(tput sgr 0)"
aws ec2 create-tags --region us-east-1 --resources $INSTANCE_ID --tags Key=Status,Value=provisioned

echo "$(tput bold)$(tput setaf 6)Wait for Hive Metastore to start running$(tput sgr 0)"
while IFS= read -r line
do
  host_description=$(echo $line | sed -r 's/^.*"(.*[0-9]+)".*"([a-z0-9\.\-]+)".*"([ip0-9\-]+).*".*"([0-9\.]+)".*$/\1/')
  host_dns=$(echo $line | sed -r 's/^.*".*([0-9]+)".*"([a-z0-9\.\-]+)".*"([ip0-9\-]+).*".*"([0-9\.]+)".*$/\2/')
  host_name=$(echo $line | sed -r 's/^.*".*([0-9]+)".*"([a-z0-9\.\-]+)".*"([ip0-9\-]+).*".*"([0-9\.]+)".*$/\3/')
  host_ip=$(echo $line | sed -r 's/^.*".*([0-9]+)".*"([a-z0-9\.\-]+)".*"([ip0-9\-]+).*".*"([0-9\.]+)".*$/\4/')
  if [ $INSTANCE_DNS_NAME == $host_dns ]
  then
    export INSTANCE_DESCRIPTION=$host_description
  fi
done < "AWS_INSTANCES"
while IFS= read -r line
do
  metastore_dns=$(echo $line | sed -r 's/^.*"Hive Metastore Instance ([0-9]+)".*"([a-z0-9\.\-]+)".*"([a-z0-9\.\-]+)".*"([ip0-9\.\-]+).*".*$/\2/')
  if [[ ${metastore_dns:0:1} != "[" ]]
  then
    metastore_status=""
    while [[ $metastore_status != "running" ]]; do
      metastore_description=$(echo $line | sed -r 's/^.*"(.*[0-9]+)".*"([a-z0-9\.\-]+)".*"([ip0-9\-]+).*".*"([0-9\.]+)".*$/\1/')
      metastore_status=$(aws ec2 describe-instances --region=us-east-1 | jq '.Reservations[].Instances[] | select(.PublicDnsName == "'$metastore_dns'") | (.Tags[]|select(.Key=="Status")|.Value)')
      metastore_status=$(echo $metastore_status | sed 's/^"\(.*\)"$/\1/')
      if [[ $metastore_status != "running" ]]
      then
        echo "$(tput bold)$(tput setaf 3)$INSTANCE_DESCRIPTION asks status of $metastore_description to see if it is running and finds it is "$metastore_status$(tput sgr 0)
      else
        echo "$(tput bold)$(tput setaf 2)$INSTANCE_DESCRIPTION asks status of $metastore_description to see if it is running and finds it is "$metastore_status$(tput sgr 0)
      fi
      sleep 10
    done
  fi
done < "AWS_INSTANCES"

echo "$(tput bold)$(tput setaf 6)Initialize Hive $HIVE_VERSION$(tput sgr 0)"
$HADOOP_HOME/bin/hdfs dfs -mkdir -p /tmp
$HADOOP_HOME/bin/hdfs dfs -chmod g+w /tmp
$HADOOP_HOME/bin/hdfs dfs -mkdir -p /user/hive/warehouse
$HADOOP_HOME/bin/hdfs dfs -chmod g+w /user/hive/warehouse

echo "$(tput bold)$(tput setaf 6)Start Hive "$HIVE_VERSION" Server Running$(tput sgr 0)"
nohup hiveserver2 &

echo "$(tput bold)$(tput setaf 6)Wait For Hive Server To Start$(tput sgr 0)"
while true ; do
  if [ -f /tmp/ubuntu/hive.log ]
  then
    result=$(grep -cE 'INFO \[main\] service\.AbstractService\: Service\:HiveServer2 is started\.' /tmp/ubuntu/hive.log)
    if [ $result = 1 ] ; then
      echo "$(tput bold)$(tput setaf 2)Hive has started$(tput sgr 0)"
      break
    else
      echo "$(tput bold)$(tput setaf 3)Hive hasn't started a log file yet$(tput sgr 0)"
    fi
  fi
  sleep 10
done

echo "$(tput bold)$(tput setaf 6)Update Instance Status Tag to running$(tput sgr 0)"
aws ec2 create-tags --region us-east-1 --resources $INSTANCE_ID --tags Key=Status,Value=running