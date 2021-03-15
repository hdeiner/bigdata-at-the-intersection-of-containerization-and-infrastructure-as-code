#!/usr/bin/env bash

docker cp WordCount.java namenode:/tmp/WordCount.java
docker cp WordCountTest.sh namenode:/tmp/WordCountTest.sh
docker cp WordCountTestMrInput01.txt namenode:/tmp/file01
docker cp WordCountTestMrInput02.txt namenode:/tmp/file02
docker cp WordCountTestMrInput03.txt namenode:/tmp/file03
docker cp WordCountTestMrAnswer.txt namenode:/tmp/mr.answer
docker exec namenode /tmp/WordCountTest.sh