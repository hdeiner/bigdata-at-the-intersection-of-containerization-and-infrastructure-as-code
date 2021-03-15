#!/usr/bin/env bash

sudo apt update -y -qq > provision.log 2> /dev/null
sudo apt-get update -y -qq >> provision.log 2> /dev/null

echo "$(tput bold)$(tput setaf 6)Install Prerequisites$(tput sgr 0)"
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends openjdk-8-jdk net-tools curl netcat gnupg libsnappy-dev awscli jq moreutils unzip >> provision.log 2> /dev/null
sudo rm -rf /var/lib/apt/lists/*
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/

aws ec2 describe-instances --region=us-east-1 | jq '.Reservations[].Instances[] | select(.State.Code == 16) | [(.Tags[]|select(.Key=="Name")|.Value), .PublicDnsName, .PrivateDnsName, .PrivateIpAddress]' | paste - - - - - - > AWS_INSTANCES

echo "$(tput bold)$(tput setaf 6)Get instance specifics$(tput sgr 0)"
export INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
export INSTANCE_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
export INSTANCE_DNS_NAME=$(curl -s http://169.254.169.254/latest/meta-data/public-hostname)

export CLUSTER_NAME=$(aws ec2 describe-instances --region=us-east-1 --instance-id=$INSTANCE_ID --query 'Reservations[].Instances[].Tags[?Key==`Environment`].Value' --output text)

echo "$(tput bold)$(tput setaf 6)Configure ssh$(tput sgr 0)"
ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa >> provision.log
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
chmod 755 ~/.ssh
chmod 600 ~/.ssh/id_rsa
chmod 755 ~/.ssh/id_rsa.pub
chmod 755 ~/.ssh/authorized_keys
echo "    StrictHostKeyChecking no" | sudo sponge -a /etc/ssh/ssh_config
sudo systemctl restart ssh.service
sudo systemctl restart ssh

aws s3 cp ~/.ssh/id_rsa s3://hadoop-scratchpad/$CLUSTER_NAME-$INSTANCE_DNS_NAME.id_rsa >> provision.log
aws s3 cp ~/.ssh/id_rsa.pub s3://hadoop-scratchpad/$CLUSTER_NAME-$INSTANCE_DNS_NAME.id_rsa.pub  >> provision.log

export HADOOP_VERSION=3.3.0
echo "$(tput bold)$(tput setaf 6)Install Hadoop $HADOOP_VERSION$(tput sgr 0)"
curl -sO https://dist.apache.org/repos/dist/release/hadoop/common/KEYS > /dev/null
gpg --quiet --import KEYS >> provision.log 2> /dev/null

export HADOOP_URL=https://www.apache.org/dist/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz
curl -sfSL "$HADOOP_URL" -o /tmp/hadoop.tar.gz > /dev/null
curl -sfSL "$HADOOP_URL.asc" -o /tmp/hadoop.tar.gz.asc > /dev/null
gpg --quiet --verify /tmp/hadoop.tar.gz.asc  >> provision.log 2> /dev/null
sudo tar -xf /tmp/hadoop.tar.gz -C /opt/
rm /tmp/hadoop.tar.gz*

sudo ln -s /opt/hadoop-$HADOOP_VERSION/etc/hadoop /etc/hadoop
sudo mkdir /opt/hadoop-$HADOOP_VERSION/logs
sudo chmod 777 /opt/hadoop-$HADOOP_VERSION/logs
sudo mkdir /hadoop-data
sudo chmod 777 /hadoop-data
sudo mkdir /hadoop-tmp
sudo chmod 777 /hadoop-tmp

echo "$(tput bold)$(tput setaf 6)Configure Hadoop Core$(tput sgr 0)"

export HADOOP_HOME=/opt/hadoop-$HADOOP_VERSION
export HADOOP_CONF_DIR=/etc/hadoop
export MULTIHOMED_NETWORK=1
export USER=ubuntu
export PATH=$HADOOP_HOME/bin/:$HADOOP_HOME/sbin/:$PATH

export HDFS_NAMENODE_USER=ubuntu
export HDFS_DATANODE_USER=ubuntu
export HDFS_SECONDARYNAMENODE_USER=ubuntu
export YARN_RESOURCEMANAGER_USER=ubuntu
export YARN_NODEMANAGER_USER=ubuntu

echo "$(tput bold)$(tput setaf 6)Fix bash_profile$(tput sgr 0)"
echo # Hadoop ENVIRONMENT VARIABLES | sudo sponge -a /home/ubuntu/.bash_profile
echo export CLUSTER_NAME=$CLUSTER_NAME | sudo sponge -a /home/ubuntu/.bash_profile
echo export INSTANCE_DNS_NAME=$INSTANCE_DNS_NAME | sudo sponge -a /home/ubuntu/.bash_profile
echo export INSTANCE_ID=$INSTANCE_ID | sudo sponge -a /home/ubuntu/.bash_profile
echo export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/ | sudo sponge -a /home/ubuntu/.bash_profile
echo export HADOOP_VERSION=$HADOOP_VERSION | sudo sponge -a /home/ubuntu/.bash_profile
echo export HADOOP_HOME=$HADOOP_HOME | sudo sponge -a /home/ubuntu/.bash_profile
echo export HADOOP_CONF_DIR=$HADOOP_CONF_DIR | sudo sponge -a /home/ubuntu/.bash_profile
echo export MULTIHOMED_NETWORK=$MULTIHOMED_NETWORK | sudo sponge -a /home/ubuntu/.bash_profile
echo export USER=$USER | sudo sponge -a /home/ubuntu/.bash_profile
echo export PATH=$PATH | sudo sponge -a /home/ubuntu/.bash_profile
echo export HDFS_NAMENODE_USER=$HDFS_NAMENODE_USER | sudo sponge -a /home/ubuntu/.bash_profile
echo export HDFS_DATANODE_USER=$HDFS_DATANODE_USER | sudo sponge -a /home/ubuntu/.bash_profile
echo export HDFS_SECONDARYNAMENODE_USER=$HDFS_SECONDARYNAMENODE_USER | sudo sponge -a /home/ubuntu/.bash_profile
echo export YARN_RESOURCEMANAGER_USER=$YARN_RESOURCEMANAGER_USER | sudo sponge -a /home/ubuntu/.bash_profile
echo export YARN_NODEMANAGER_USER=$YARN_NODEMANAGER_USER | sudo sponge -a /home/ubuntu/.bash_profile
source /home/ubuntu/.bash_profile

echo "$(tput bold)$(tput setaf 6)Configure Hadoop Environment$(tput sgr 0)"
echo "export JAVA_HOME=$JAVA_HOME" | sudo -- sponge -a /etc/hadoop/hadoop-env.sh
echo "export HADOOP_HOME=$HADOOP_HOME" | sudo -- sponge -a /etc/hadoop/hadoop-env.sh
echo "export HADOOP_CONF_DIR=$HADOOP_CONF_DIR" | sudo -- sponge -a /etc/hadoop/hadoop-env.sh
echo "export HDFS_NAMENODE_USER=$HDFS_NAMENODE_USER" | sudo -- sponge -a /etc/hadoop/hadoop-env.sh
echo "export HDFS_DATANODE_USER=$HDFS_DATANODE_USER" | sudo -- sponge -a /etc/hadoop/hadoop-env.sh
echo "export HDFS_SECONDARYNAMENODE_USER=$HDFS_SECONDARYNAMENODE_USER" | sudo -- sponge -a /etc/hadoop/hadoop-env.sh
echo "export YARN_RESOURCEMANAGER_USER=$YARN_RESOURCEMANAGER_USER" | sudo -- sponge -a /etc/hadoop/hadoop-env.sh
echo "export YARN_NODEMANAGER_USER=$YARN_NODEMANAGER_USER" | sudo -- sponge -a /etc/hadoop/hadoop-env.sh

echo "$(tput bold)$(tput setaf 6)Create Cluster /etc/host$(tput sgr 0)"
echo "127.0.0.1 localhost" | sudo sponge /etc/hosts
sudo -- bash -c "cat /dev/null > /etc/hadoop/workers"
let datanode_count=0
while IFS= read -r line
do
  host_description=$(echo $line | sed -r 's/^.*"(.*[0-9]+)".*"([a-z0-9\.\-]+)".*"([ip0-9\-]+).*".*"([0-9\.]+)".*$/\1/')
  host_dns=$(echo $line | sed -r 's/^.*".*([0-9]+)".*"([a-z0-9\.\-]+)".*"([ip0-9\-]+).*".*"([0-9\.]+)".*$/\2/')
  host_name=$(echo $line | sed -r 's/^.*".*([0-9]+)".*"([a-z0-9\.\-]+)".*"([ip0-9\-]+).*".*"([0-9\.]+)".*$/\3/')
  host_ip=$(echo $line | sed -r 's/^.*".*([0-9]+)".*"([a-z0-9\.\-]+)".*"([ip0-9\-]+).*".*"([0-9\.]+)".*$/\4/')
  echo "$host_ip $host_name # $host_description - $host_dns" | sudo sponge -a /etc/hosts
  namenode=$(echo $line | sed -r 's/^.*"HDFS Namenode Instance ([0-9]+)".*$/\1/')
  if [[ ${namenode:0:1} != "[" ]]
  then
      namenode_dns=$(echo $line | sed -r 's/^.*"HDFS Namenode Instance ([0-9]+)".*"([a-z0-9\.\-]+)".*"([ip0-9\-]+).*".*"([0-9\.]+)".*$/\2/')
  fi
  datanode=$(echo $line | sed -r 's/^.*"HDFS Datanode Instance ([0-9]+)".*$/\1/')
  if [[ ${datanode:0:1} != "[" ]]
  then
      let datanode_count=datanode_count+1
      datanode_dns=$(echo $line | sed -r 's/^.*"HDFS Datanode Instance ([0-9]+)".*"([a-z0-9\.\-]+)".*"([ip0-9\-]+).*".*"([0-9\.]+)".*$/\2/')
      echo $host_name | sudo -- sponge -a /etc/hadoop/workers
  fi
done < "AWS_INSTANCES"

sudo cp /tmp/core-site.xml /etc/hadoop/core-site.xml
sudo sed --in-place "s/NAMENODE_DNS/$namenode_dns/g" /etc/hadoop/core-site.xml

sudo cp /tmp/hdfs-site.xml /etc/hadoop/hdfs-site.xml
sudo sed --in-place "s/DATANODE_COUNT/$datanode_count/g" /etc/hadoop/hdfs-site.xml


