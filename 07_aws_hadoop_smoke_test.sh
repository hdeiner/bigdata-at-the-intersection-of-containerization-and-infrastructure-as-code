#!/usr/bin/env bash

echo $(terraform output hive_hdfs_namenode_dns | sed -n '3p' | sed -E 's/(^[ ]+")([a-z0-9\.\-]+)(".*$)/\2/') > .namenode
export NAMENODE=$(echo `cat .namenode`)
rm .namenode

function remote_copy () {
  max_retry=5
  counter=1
  scpcmd="scp -i ~/.ssh/id_rsa $3 $1@$2:$4"
  while true
  do
    sleep 1
    $scpcmd > .stdout 2> .stderr
    if [ $? -ne 0 ]
    then
      ((counter++))
      if [ $counter -le $max_retry ]
      then
        echo "$(tput bold)$(tput setaf 3)$scpcmd failed - retrying - attempt #$counter$(tput sgr 0)" > /dev/tty
      else
        echo "$(tput bold)$(tput setaf 1)$scpcmd failed$(tput sgr 0)" > /dev/tty
        return 1
      fi
    else
      echo "$(tput bold)$(tput setaf 2)$scpcmd suceeded$(tput sgr 0)" > /dev/tty
      return 0
    fi
  done
}

function remote_execute () {
  max_retry=5
  counter=1
  sshcmd="ssh -i ~/.ssh/id_rsa $1@$2 $3"
  while true
  do
    sleep 1
    $sshcmd > .stdout 2> .stderr
    if [ $? -ne 0 ]
    then
      ((counter++))
      if [ $counter -le $max_retry ]
      then
        echo "$(tput bold)$(tput setaf 3)$sshcmd failed - retrying - attempt #$counter$(tput sgr 0)" > /dev/tty
      else
        echo "$(tput bold)$(tput setaf 1)$sshcmd failed$(tput sgr 0)" > /dev/tty
        return 1
      fi
    else
        echo "$(tput bold)$(tput setaf 2)$sshcmd suceeded$(tput sgr 0)" > /dev/tty
        return 0
    fi
  done
}

echo "$(tput bold)$(tput setaf 6)Smoke Test HADOOP Map/Reduce$(tput sgr 0)"
$(remote_copy "ubuntu" "$NAMENODE" "WordCount.java" "/tmp/.")

$(remote_copy "ubuntu" "$NAMENODE" "WordCountTest.sh" "/tmp/.")

$(remote_copy "ubuntu" "$NAMENODE" "WordCountTestMrInput01.txt" "/tmp/.")
$(remote_execute "ubuntu" "$NAMENODE" "mv /tmp/WordCountTestMrInput01.txt /tmp/file01")

$(remote_copy "ubuntu" "$NAMENODE" "WordCountTestMrInput02.txt" "/tmp/.")
$(remote_execute "ubuntu" "$NAMENODE" "mv /tmp/WordCountTestMrInput02.txt /tmp/file02")

$(remote_copy "ubuntu" "$NAMENODE" "WordCountTestMrInput03.txt" "/tmp/.")
$(remote_execute "ubuntu" "$NAMENODE" "mv /tmp/WordCountTestMrInput03.txt /tmp/file03")

$(remote_copy "ubuntu" "$NAMENODE" "WordCountTestMrAnswer.txt" "/tmp/.")
$(remote_execute "ubuntu" "$NAMENODE" "mv /tmp/WordCountTestMrAnswer.txt /tmp/mr.answer")

$(remote_copy "ubuntu" "$NAMENODE" "WordCountTest.sh" "/tmp/.")
$(remote_execute "ubuntu" "$NAMENODE" "chmod +x /tmp/WordCountTest.sh")
$(remote_execute "ubuntu" "$NAMENODE" "/tmp/WordCountTest.sh")
cat .stdout

rm -rf .stdout .stderr

