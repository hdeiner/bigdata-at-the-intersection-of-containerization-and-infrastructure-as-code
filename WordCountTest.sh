#!/usr/bin/env bash

curl http://169.254.169.254/latest/meta-data > /dev/null 2> /dev/null
if [ $? -eq 0 ]
then
  source ~/.bash_profile
fi

export TERM=xterm
echo "$(tput bold)$(tput setaf 6)Test Map/Reduce$(tput sgr 0)"

cd /tmp

export HADOOP_CLASSPATH=${JAVA_HOME}/lib/tools.jar
hadoop com.sun.tools.javac.Main WordCount.java
jar cf wc.jar WordCount*.class

echo "$(tput setaf 6)Inputs$(tput sgr 0)"
cat file01 ; echo ""
cat file02 ; echo ""
cat file03 ; echo ""

hdfs dfs -rm -r /usr/joe/wordcount/input > /dev/null 2> /dev/null
hdfs dfs -mkdir -p /usr/joe/wordcount/input
hdfs dfs -put file01 /usr/joe/wordcount/input/file01
hdfs dfs -put file02 /usr/joe/wordcount/input/file02
hdfs dfs -put file03 /usr/joe/wordcount/input/file03

hadoop jar wc.jar WordCount /usr/joe/wordcount/input /usr/joe/wordcount/output 2> /dev/null

echo "$(tput setaf 6)Outputs$(tput sgr 0)"
rm -rf mr.txt
hdfs dfs -cat /usr/joe/wordcount/output/part-r-00000
hdfs dfs -copyToLocal /usr/joe/wordcount/output/part-r-00000 mr.txt

sed --in-place 's/\t/ /g' mr.txt

result=$(diff mr.txt mr.answer | wc -l)
if [ $result == 0 ] ; then
  echo "$(tput bold)$(tput setaf 2)Test Hadoop Map/Reduce SUCCESS$(tput sgr 0)"
else
  echo "$(tput bold)$(tput setaf 1)Test Hadoop Map/Reduce FAILURE$(tput sgr 0)"
  diff mr.txt mr.answer
fi
