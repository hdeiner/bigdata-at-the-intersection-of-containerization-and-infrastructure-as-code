#!/usr/bin/env bash

echo "$(tput bold)$(tput setaf 6)Run Hadoop Datanode$(tput sgr 0)"
source /home/ubuntu/.bash_profile

echo "$(tput bold)$(tput setaf 6)Update Instance Status Tag to provisioned$(tput sgr 0)"
aws ec2 create-tags --region us-east-1 --resources $INSTANCE_ID --tags Key=Status,Value=provisioned

echo "$(tput bold)$(tput setaf 6)Allow Hadoop Cluster SSH Access$(tput sgr 0)"
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
  node=$(echo $line | sed -r 's/^.*"HDFS (Name|Data)node Instance ([0-9]+)".*"([a-z0-9\.\-]+)".*"([ip0-9\-]+).*".*"([0-9\.]+)".*$/\3/')
  node_type=$(echo $line | sed -r 's/^.*"HDFS (Name|Data)node Instance ([0-9]+)".*"([a-z0-9\.\-]+)".*"([ip0-9\-]+).*".*"([0-9\.]+)".*$/\1/')
  if [[ ${node:0:1} != "[" ]]
  then
    node_status="provisioning"
    if [[ $node_status == "provisioning" ]]
    then
      node_description=$(echo $line | sed -r 's/^.*"(.*[0-9]+)".*"([a-z0-9\.\-]+)".*"([ip0-9\-]+).*".*"([0-9\.]+)".*$/\1/')
      node_status=$(aws ec2 describe-instances --region=us-east-1 | jq '.Reservations[].Instances[] | select(.PublicDnsName == "'$node'") | (.Tags[]|select(.Key=="Status")|.Value)')
      node_status=$(echo $node_status | sed 's/^"\(.*\)"$/\1/')
      if [[ $node_status != "provisioning" ]]
      then
        echo "$(tput bold)$(tput setaf 2)$INSTANCE_DESCRIPTION checks status of "$node_description" for not provisioning so it can ssh to it and finds it "$node_status$(tput sgr 0)
      else
        echo "$(tput bold)$(tput setaf 3)$INSTANCE_DESCRIPTION checks status of "$node_description" for not provisioning so it can ssh to it and finds it "$node_status$(tput sgr 0)
      fi
      sleep 5
    fi
    echo "$(tput bold)$(tput setaf 6)Adding $node_description to ssh authorized_keys for $INSTANCE_DESCRIPTION$(tput sgr 0)"
    aws s3api wait object-exists --bucket hadoop-scratchpad --key $CLUSTER_NAME-$node.id_rsa.pub
    aws s3 cp s3://hadoop-scratchpad/$CLUSTER_NAME-$node.id_rsa.pub /tmp/id_rsa.pub >> provision.log
    chmod 777 ~/.ssh/authorized_keys
    cat /tmp/id_rsa.pub >> ~/.ssh/authorized_keys
    chmod 755 ~/.ssh/authorized_keys
  fi
done < "AWS_INSTANCES"

echo "$(tput bold)$(tput setaf 6)Update Instance Status Tag to running$(tput sgr 0)"
aws ec2 create-tags --region us-east-1 --resources $INSTANCE_ID --tags Key=Status,Value=running