#!/usr/bin/env bash

echo $(terraform output hive_server_dns | sed -n '3p' | sed -E 's/(^[ ]+")([a-z0-9\.\-]+)(".*$)/\2/') > .hiveserver
export HIVESERVER=$(echo `cat .hiveserver`)
rm .hiveserver

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

echo "$(tput bold)$(tput setaf 6)Test AWS Hive$(tput sgr 0)"

$(remote_copy "ubuntu" "$HIVESERVER" "01_create_PGYR2019_P06302020_csv_data.py" "/tmp/.")
$(remote_copy "ubuntu" "$HIVESERVER" "PGYR2019_P06302020.schema" "/tmp/.")
$(remote_copy "ubuntu" "$HIVESERVER" "HiveTest.sh" "/tmp/.")
$(remote_execute "ubuntu" "$HIVESERVER" "chmod +x /tmp/HiveTest.sh")
$(remote_execute "ubuntu" "$HIVESERVER" "/tmp/HiveTest.sh")
cat .stdout

rm -rf .stdout .stderr
