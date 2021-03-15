#!/usr/bin/env bash

sudo apt update -y -qq > provision.log 2> /dev/null
sudo apt-get update -y -qq >> provision.log 2> /dev/null

echo "$(tput bold)$(tput setaf 6)Install Prerequisites$(tput sgr 0)"
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends postgresql postgresql-contrib awscli jq moreutils  >> provision.log 2> /dev/null

echo "$(tput bold)$(tput setaf 6)Get instance specifics$(tput sgr 0)"
export INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
export INSTANCE_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
export INSTANCE_DNS_NAME=$(curl -s http://169.254.169.254/latest/meta-data/public-hostname)
export CLUSTER_NAME=$(aws ec2 describe-instances --region=us-east-1 --instance-id=$INSTANCE_ID --query 'Reservations[].Instances[].Tags[?Key==`Environment`].Value' --output text)

echo "$(tput bold)$(tput setaf 6)Fix bash_profile$(tput sgr 0)"
echo # Hadoop ENVIRONMENT VARIABLES | sudo sponge -a /home/ubuntu/.bash_profile
echo export CLUSTER_NAME=$CLUSTER_NAME | sudo sponge -a /home/ubuntu/.bash_profile
echo export INSTANCE_DNS_NAME=$INSTANCE_DNS_NAME | sudo sponge -a /home/ubuntu/.bash_profile
echo export INSTANCE_ID=$INSTANCE_ID | sudo sponge -a /home/ubuntu/.bash_profile
source /home/ubuntu/.bash_profile