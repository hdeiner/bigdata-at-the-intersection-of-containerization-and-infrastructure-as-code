#!/usr/bin/env bash
echo "$(tput bold)$(tput setaf 6)Startup Apache Hive Locally$(tput sgr 0)"

docker-compose -f docker-compose.yml up -d

echo "$(tput bold)$(tput setaf 6)Wait for Hive to start$(tput sgr 0)"
while true ; do
  docker logs hive-server > stdout.txt 2> stderr.txt
  result=$(grep -cE " Starting HiveServer2" stdout.txt)
  if [ $result != 0 ] ; then
    sleep 10 # it says it is ready, but not really
    echo "$(tput bold)$(tput setaf 2)Hive has started$(tput sgr 0)"
    break
  fi
  sleep 5
done
rm stdout.txt stderr.txt