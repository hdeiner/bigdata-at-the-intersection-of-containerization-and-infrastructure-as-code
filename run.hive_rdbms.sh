#!/usr/bin/env bash

echo "$(tput bold)$(tput setaf 6)Run Hive RDBMS$(tput sgr 0)"
source /home/ubuntu/.bash_profile

echo "$(tput bold)$(tput setaf 6)Update Instance Status Tag to provisioned$(tput sgr 0)"
aws ec2 create-tags --region us-east-1 --resources $INSTANCE_ID --tags Key=Status,Value=provisioned

echo "$(tput bold)$(tput setaf 6)Configure Postgres$(tput sgr 0)"
echo "listen_addresses = '*'" | sudo -- sponge -a /etc/postgresql/10/main/postgresql.conf
sudo sed --in-place --regexp-extended 's/host    all             all             127.0.0.1\/32            md5/host    all             all             0.0.0.0\/0               trust/g' /etc/postgresql/10/main/pg_hba.conf
sudo sed --in-place --regexp-extended 's/ md5/ trust/g' /etc/postgresql/10/main/pg_hba.conf
sudo systemctl restart postgresql

echo "$(tput bold)$(tput setaf 6)Wait For Postgres To Start$(tput sgr 0)"
while true ; do
  sudo -u postgres bash -c "psql --port=5432 --username=postgres --no-password --no-align -c '\conninfo'" > stdout.txt 2> stderr.txt
  result=$(grep -c 'You are connected to database "postgres" as user "postgres" via socket in "/var/run/postgresql" at port "5432".' stdout.txt)
  if [ $result = 1 ] ; then
    echo "$(tput bold)$(tput setaf 2)Postgres has started$(tput sgr 0)"
    break
  fi
  sleep 10
done
rm stdout.txt stderr.txt

echo "$(tput bold)$(tput setaf 6)Create Postgres Database metastore$(tput sgr 0)"
sudo -u postgres bash -c "psql --port=5432 --username=postgres --no-password --no-align -c 'create database metastore;'"

echo "$(tput bold)$(tput setaf 6)Update Instance Status Tag to running$(tput sgr 0)"
aws ec2 create-tags --region us-east-1 --resources $INSTANCE_ID --tags Key=Status,Value=running