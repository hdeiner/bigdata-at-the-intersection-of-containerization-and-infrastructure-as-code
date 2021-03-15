#!/usr/bin/env bash

sudo apt update -y -qq > provision.log 2> /dev/null
sudo apt-get update -y -qq >> provision.log 2> /dev/null

export HIVE_VERSION=2.3.8
echo "$(tput bold)$(tput setaf 6)Install Hive $HIVE_VERSION$(tput sgr 0)"
curl -sO https://dist.apache.org/repos/dist/release/hive/KEYS > /dev/null
gpg --quiet --import KEYS >> provision.log 2> /dev/null

export HIVE_URL=https://dist.apache.org/repos/dist/release/hive/hive-$HIVE_VERSION/apache-hive-$HIVE_VERSION-bin.tar.gz
curl -sfSL "$HIVE_URL" -o /tmp/hive-$HIVE_VERSION.tar.gz > /dev/null
sudo tar -xf /tmp/hive-$HIVE_VERSION.tar.gz -C /opt/
rm /tmp/hive-$HIVE_VERSION.tar.gz
sudo mv /opt/apache-hive-$HIVE_VERSION-bin /opt/hive-$HIVE_VERSION

echo "$(tput bold)$(tput setaf 6)Configure Hive$(tput sgr 0)"
export HIVE_HOME=/opt/hive-$HIVE_VERSION
export HIVE_CONF_DIR=$HIVE_HOME/conf
export HIVE_AUX_JARS_PATH=$HIVE_HOME/lib
export PATH=$HIVE_HOME/bin/:$HIVE_HOME/sbin/:$HADOOP_HOME/bin/:$HADOOP_HOME/sbin/:$PATH

echo "$(tput bold)$(tput setaf 6)Fix bash_profile$(tput sgr 0)"
echo export HIVE_VERSION=$HIVE_VERSION | sudo sponge -a /home/ubuntu/.bash_profile
echo export HIVE_HOME=$HIVE_HOME | sudo sponge -a /home/ubuntu/.bash_profile
echo export HIVE_CONF_DIR=$HIVE_CONF_DIR | sudo sponge -a /home/ubuntu/.bash_profile
echo export HIVE_AUX_JARS_PATH=$HIVE_AUX_JARS_PATH | sudo sponge -a /home/ubuntu/.bash_profile
echo export PATH=$PATH | sudo sponge -a /home/ubuntu/.bash_profile
source /home/ubuntu/.bash_profile

echo "$(tput bold)$(tput setaf 6)Get JDBC Driver for Postgres$(tput sgr 0)"
curl -sfSL "https://jdbc.postgresql.org/download/postgresql-42.2.18.jar" -o /tmp/postgresql-42.2.18.jar > /dev/null
sudo mv /tmp/postgresql-42.2.18.jar /opt/hive-$HIVE_VERSION/lib/postgresql-42.2.18.jar
sudo cp /opt/hive-$HIVE_VERSION/lib/postgresql-42.2.18.jar /opt/hive-$HIVE_VERSION/jdbc/postgresql-42.2.18.jar

echo "$(tput bold)$(tput setaf 6)Wait for RDBMS to start running$(tput sgr 0)"
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
  rdbmsnode=$(echo $line | sed -r 's/^.*"Hive RDBMS Instance ([0-9]+)".*"([a-z0-9\.\-]+)".*"([a-z0-9\.\-]+)".*"([ip0-9\.\-]+).*".*$/\2/')
  if [[ ${rdbmsnode:0:1} != "[" ]]
  then
    rdbmsnode_status=""
    while [[ $rdbmsnode_status != "running" ]]; do
      rdbmsnode_description=$(echo $line | sed -r 's/^.*"(.*[0-9]+)".*"([a-z0-9\.\-]+)".*"([ip0-9\-]+).*".*"([0-9\.]+)".*$/\1/')
      rdbmsnode_status=$(aws ec2 describe-instances --region=us-east-1 | jq '.Reservations[].Instances[] | select(.PublicDnsName == "'$rdbmsnode'") | (.Tags[]|select(.Key=="Status")|.Value)')
      rdbmsnode_status=$(echo $rdbmsnode_status | sed 's/^"\(.*\)"$/\1/')
      if [[ $rdbmsnode_status != "running" ]]
      then
        echo "$(tput bold)$(tput setaf 3)$INSTANCE_DESCRIPTION asks status of $rdbmsnode_description to see if it is running and finds it is "$rdbmsnode_status$(tput sgr 0)
      else
        echo "$(tput bold)$(tput setaf 2)$INSTANCE_DESCRIPTION asks status of $rdbmsnode_description to see if it is running and finds it is "$rdbmsnode_status$(tput sgr 0)
      fi
      rdbmsnode_dns=$(echo $line | sed -r 's/^.*"Hive RDBMS Instance ([0-9]+)".*"([a-z0-9\.\-]+)".*"([a-z0-9\.\-]+)".*"([ip0-9\.\-]+).*".*$/\2/')
      sleep 10
    done
  fi
done < "AWS_INSTANCES"

echo "$(tput bold)$(tput setaf 6)Wait for HDFS Namenode to start running$(tput sgr 0)"
while IFS= read -r line
do
  namenode_dns=$(echo $line | sed -r 's/^.*"HDFS Namenode Instance ([0-9]+)".*"([a-z0-9\.\-]+)".*"([a-z0-9\.\-]+)".*"([ip0-9\.\-]+).*".*$/\2/')
  if [[ ${namenode_dns:0:1} != "[" ]]
  then
    namenode_status=""
    while [[ $namenode_status != "running" ]]; do
      namenode_description=$(echo $line | sed -r 's/^.*"(.*[0-9]+)".*"([a-z0-9\.\-]+)".*"([ip0-9\-]+).*".*"([0-9\.]+)".*$/\1/')
      namenode_status=$(aws ec2 describe-instances --region=us-east-1 | jq '.Reservations[].Instances[] | select(.PublicDnsName == "'$namenode_dns'") | (.Tags[]|select(.Key=="Status")|.Value)')
      namenode_status=$(echo $namenode_status | sed 's/^"\(.*\)"$/\1/')
      if [[ $namenode_status != "running" ]]
      then
        echo "$(tput bold)$(tput setaf 3)$INSTANCE_DESCRIPTION asks status of $namenode_description to see if it is running and finds it is $namenode_status"$(tput sgr 0)
      else
        echo "$(tput bold)$(tput setaf 2)$INSTANCE_DESCRIPTION asks status of $namenode_description to see if it is running and finds it is $namenode_status"$(tput sgr 0)
      fi
      sleep 10
    done
  fi
  hiveserver=$(echo $line | sed -r 's/^.*"Hive Server Instance ([0-9]+)".*$/\1/')
  if [[ ${hiveserver:0:1} != "[" ]]
  then
      hiveserver_dns=$(echo $line | sed -r 's/^.*"Hive Server Instance ([0-9]+)".*"([a-z0-9\.\-]+)".*"([a-z0-9\.\-]+)".*"([ip0-9\.\-]+).*".*$/\2/')
  fi
  metastore=$(echo $line | sed -r 's/^.*"Hive Metastore Instance ([0-9]+)".*$/\1/')
  if [[ ${metastore:0:1} != "[" ]]
  then
      metastore_dns=$(echo $line | sed -r 's/^.*"Hive Metastore Instance ([0-9]+)".*"([a-z0-9\.\-]+)".*"([a-z0-9\.\-]+)".*"([ip0-9\.\-]+).*".*$/\2/')
  fi
done < "AWS_INSTANCES"

echo "$(tput bold)$(tput setaf 6)Configure Hive$(tput sgr 0)"
sudo cp /tmp/hive-site.xml /opt/hive-$HIVE_VERSION/conf/hive-site.xml
sudo sed --in-place "s/RDBMSNODE_DNS/$rdbmsnode_dns/g" /opt/hive-$HIVE_VERSION/conf/hive-site.xml
sudo sed --in-place "s/HIVESERVER_DNS/$hiveserver_dns/g" /opt/hive-$HIVE_VERSION/conf/hive-site.xml
sudo sed --in-place "s/METASTORE_DNS/$metastore_dns/g" /opt/hive-$HIVE_VERSION/conf/hive-site.xml

echo "$(tput bold)$(tput setaf 6)Fix Hive/Hadoop lib Problem$(tput sgr 0)"
sudo rm /opt/hive-2.3.8/lib/guava-14.0.1.jar
sudo cp /opt/hadoop-3.3.0/share/hadoop/hdfs/lib/guava-27.0-jre.jar /opt/hive-2.3.8/lib/.