#!/usr/bin/env bash

echo "$(tput bold)$(tput setaf 6)Run Hadoop Namenode$(tput sgr 0)"
source /home/ubuntu/.bash_profile

echo "$(tput bold)$(tput setaf 6)Update Instance Status Tag to provisioned$(tput sgr 0)"
aws ec2 create-tags --region us-east-1 --resources $INSTANCE_ID --tags Key=Status,Value=provisioned

echo "$(tput bold)$(tput setaf 6)Wait for Datanodes to start running$(tput sgr 0)"
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
  datanode=$(echo $line | sed -r 's/^.*"HDFS Datanode Instance ([0-9]+)".*"([a-z0-9\.\-]+)".*"([ip0-9\-]+).*".*"([0-9\.]+)".*$/\2/')
  if [[ ${datanode:0:1} != "[" ]]
  then
    datanode_status=""
    while [[ $datanode_status != "running" ]]; do
      datanode_description=$(echo $line | sed -r 's/^.*"(.*[0-9]+)".*"([a-z0-9\.\-]+)".*"([ip0-9\-]+).*".*"([0-9\.]+)".*$/\1/')
      datanode_status=$(aws ec2 describe-instances --region=us-east-1 | jq '.Reservations[].Instances[] | select(.PublicDnsName == "'$datanode'") | (.Tags[]|select(.Key=="Status")|.Value)')
      datanode_status=$(echo $datanode_status | sed 's/^"\(.*\)"$/\1/')
      if [[ $datanode_status != "running" ]]
      then
        echo "$(tput bold)$(tput setaf 3)$INSTANCE_DESCRIPTION checks status of $datanode_description to see if it is running and finds it is "$datanode_status$(tput sgr 0)
      else
        echo "$(tput bold)$(tput setaf 2)$INSTANCE_DESCRIPTION checks status of $datanode_description to see if it is running and finds it is "$datanode_status$(tput sgr 0)
      fi
      sleep 10
    done
  fi
  namenode=$(echo $line | sed -r 's/^.*"HDFS Namenode Instance ([0-9]+)".*$/\1/')
  if [[ ${namenode:0:1} != "[" ]]
  then
      yarnnode_dns=$(echo $line | sed -r 's/^.*".*([0-9]+)".*"([a-z0-9\.\-]+)".*"([ip0-9\-]+).*".*"([0-9\.]+)".*$/\2/')
      yarnnode_host=$(echo $line | sed -r 's/^.*".*([0-9]+)".*"([a-z0-9\.\-]+)".*"([ip0-9\-]+).*".*"([0-9\.]+)".*$/\3/')
  fi
done < "AWS_INSTANCES"

echo "$(tput bold)$(tput setaf 6)Allow Hadoop Cluster SSH Access$(tput sgr 0)"
while IFS= read -r line
do
  node=$(echo $line | sed -r 's/^.*"HDFS (Name|Data)node Instance ([0-9]+)".*"([a-z0-9\.\-]+)".*"([ip0-9\-]+).*".*"([0-9\.]+)".*$/\3/')
  node_type=$(echo $line | sed -r 's/^.*"HDFS (Name|Data)node Instance ([0-9]+)".*"([a-z0-9\.\-]+)".*"([ip0-9\-]+).*".*"([0-9\.]+)".*$/\1/')
  if [[ ${node:0:1} != "[" ]]
  then
    node_description=$(echo $line | sed -r 's/^.*"(.*[0-9]+)".*"([a-z0-9\.\-]+)".*"([ip0-9\-]+).*".*"([0-9\.]+)".*$/\1/')
    node_status="provisioning"
    if [[ $node_status == "provisioning" ]]
    then
      node_status=$(aws ec2 describe-instances --region=us-east-1 | jq '.Reservations[].Instances[] | select(.PublicDnsName == "'$node'") | (.Tags[]|select(.Key=="Status")|.Value)')
      node_status=$(echo $node_status | sed 's/^"\(.*\)"$/\1/')
      if [[ $node_status != "provisioning" ]]
        then
          echo "$(tput bold)$(tput setaf 2)$INSTANCE_DESCRIPTION checks status of $node_description for not provisioning so it can ssh to it and finds it "$node_status$(tput sgr 0)
        else
          echo "$(tput bold)$(tput setaf 3)$INSTANCE_DESCRIPTION checks status of $node_description for not provisioning so it can ssh to it and finds it "$node_status$(tput sgr 0)
        fi
      sleep 10
    fi
    echo "$(tput bold)$(tput setaf 6)Adding $node_description to ssh authorized_keys for $INSTANCE_DESCRIPTION$(tput sgr 0)"
    aws s3api wait object-exists --bucket hadoop-scratchpad --key $CLUSTER_NAME-$node.id_rsa.pub
    aws s3 cp s3://hadoop-scratchpad/$CLUSTER_NAME-$node.id_rsa.pub /tmp/id_rsa.pub  >> provision.log
    chmod 777 ~/.ssh/authorized_keys
    cat /tmp/id_rsa.pub >> ~/.ssh/authorized_keys
    chmod 755 ~/.ssh/authorized_keys
  fi
done < "AWS_INSTANCES"

echo "$(tput bold)$(tput setaf 6)Configure YARN$(tput sgr 0)"
sudo cp /tmp/capacity-scheduler.xml /etc/hadoop/capacity-scheduler.xml
sudo cp /tmp/mapred-queues.xml /etc/hadoop/mapred-queues.xml

sudo cp /tmp/yarn-site.xml /etc/hadoop/yarn-site.xml
sudo sed --in-place "s/YARNNODE_DNS/$yarnnode_dns/g" /etc/hadoop/yarn-site.xml
sudo sed --in-place "s/YARNNODE_HOSTNAME/$yarnnode_host/g" /etc/hadoop/yarn-site.xml

sudo cp /tmp/mapred-site.xml /etc/hadoop/mapred-site.xml
sudo sed --in-place "s/YARNNODE_HOSTNAME/$yarnnode_host/g" /etc/hadoop/mapred-site.xml

echo "$(tput bold)$(tput setaf 6)Initialize HDFS$(tput sgr 0)"
namedir=file:///hadoop-data/namenode
echo "$(tput bold)$(tput setaf 6)Format namenode name directory: $namedir$(tput sgr 0)"
hdfs namenode -format 2> /dev/null

echo "$(tput bold)$(tput setaf 6)Start HDFS$(tput sgr 0)"
start-dfs.sh
echo "$(tput bold)$(tput setaf 3)Wait For HDFS To Start$(tput sgr 0)"
while true ; do
  result=$(jps | grep -cE "^[0-9 ]*((Name|SecondaryName)Node)$")
  if [ $result == 2 ] ; then
    echo "$(tput bold)$(tput setaf 2)HDFS has started$(tput sgr 0)"
    break
  fi
  sleep 10
done

echo "$(tput bold)$(tput setaf 6)Start YARN ResourceManager$(tput sgr 0)"
nohup start-yarn.sh
echo "$(tput bold)$(tput setaf 3)Wait For HDFS To Start$(tput sgr 0)"
while true ; do
  result=$(jps | grep -cE "^[0-9 ]*ResourceManager$")
  if [ $result == 1 ] ; then
    echo "$(tput bold)$(tput setaf 2)YARN ResourceManager has started$(tput sgr 0)"
    break
  fi
  sleep 10
done

echo "$(tput bold)$(tput setaf 6)Start YARN NodeManager$(tput sgr 0)"
nohup yarn --daemon start nodemanager
echo "$(tput bold)$(tput setaf 3)Wait For YARN NodeManager To Start$(tput sgr 0)"
while true ; do
  result=$(jps | grep -cE "^[0-9 ]*NodeManager$")
  if [ $result == 1 ] ; then
    echo "$(tput bold)$(tput setaf 2)YARN NodeManager has started$(tput sgr 0)"
    break
  fi
  sleep 10
done

echo "$(tput bold)$(tput setaf 6)Start Job History Server$(tput sgr 0)"
nohup mapred --daemon start historyserver
echo "$(tput bold)$(tput setaf 3)Wait For Job History Server To Start$(tput sgr 0)"
while true ; do
  result=$(jps | grep -cE "^[0-9 ]*JobHistoryServer")
  if [ $result == 1 ] ; then
    echo "$(tput bold)$(tput setaf 2)Job History Server has started$(tput sgr 0)"
    break
  fi
  sleep 10
done

echo "$(tput bold)$(tput setaf 6)Update Instance Status Tag to running$(tput sgr 0)"
aws ec2 create-tags --region us-east-1 --resources $INSTANCE_ID --tags Key=Status,Value=running