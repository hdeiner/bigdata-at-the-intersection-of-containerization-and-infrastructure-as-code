#!/usr/bin/env bash

curl http://169.254.169.254/latest/meta-data > /dev/null 2> /dev/null
if [ $? -eq 0 ]
then
  source ~/.bash_profile
fi

export TERM=xterm
echo "$(tput bold)$(tput setaf 6)Test Hive$(tput sgr 0)"

cd /tmp

echo "$(tput setaf 6)Create Test Data$(tput sgr 0)"
python3 01_create_PGYR2019_P06302020_csv_data.py

echo "$(tput setaf 6)Create Schema$(tput sgr 0)"
beeline -u jdbc:hive2://127.0.0.1:10000 --color=true --autoCommit=true -f PGYR2019_P06302020.schema
echo ""
echo ""

echo "$(tput setaf 6)Display Tables Created$(tput sgr 0)"
beeline -u jdbc:hive2://127.0.0.1:10000 --color=true --autoCommit=true -e 'show tables;'
echo ""

echo "$(tput setaf 6)Import Sample Data Into Hive$(tput sgr 0)"
beeline -u jdbc:hive2://127.0.0.1:10000 --color=true --autoCommit=true -e "LOAD DATA LOCAL INPATH '/tmp/PGYR19_P012221/bigdata.csv' INTO TABLE PGYR2019_P06302020;"
echo ""
echo ""

echo "$(tput setaf 6)Location of data in Hadoop$(tput sgr 0)"
$HADOOP_HOME/bin/hdfs dfs -ls -h /user/hive/warehouse/pgyr2019_p06302020/bigdata.csv
echo ""

echo "$(tput setaf 6)Display first two rows of data$(tput sgr 0)"
beeline -u jdbc:hive2://127.0.0.1:10000 --color=true --maxWidth=240 --maxColumnWidth=20 --truncateTable=true --silent -e "SELECT * FROM PGYR2019_P06302020 LIMIT 2;"
echo ""

echo "$(tput setaf 6)Count of rows of data$(tput sgr 0)"
beeline -u jdbc:hive2://127.0.0.1:10000 --color=true --maxWidth=240 --maxColumnWidth=20 --truncateTable=true --silent -e "SELECT COUNT(*) AS count_of_rows_of_data FROM PGYR2019_P06302020;"
echo ""

echo "$(tput setaf 6)Average of total_amount_of_payment_usdollars$(tput sgr 0)"
beeline -u jdbc:hive2://127.0.0.1:10000 --color=true --maxWidth=240 --maxColumnWidth=20 --truncateTable=true --numberFormat='###,###,###,##0.00' --silent -e "SELECT AVG(total_amount_of_payment_usdollars) AS average_of_total_amount_of_payment_usdollars FROM PGYR2019_P06302020;"
echo ""

echo "$(tput setaf 6)Top ten earning physicians$(tput sgr 0)"
echo "SELECT physician_first_name, physician_last_name, SUM(total_amount_of_payment_usdollars) AS sum_of_payments" > .command.sql
echo "FROM PGYR2019_P06302020 " >> .command.sql
echo "WHERE physician_first_name != '' "  >> .command.sql
echo "AND physician_last_name != '' " >> .command.sql
echo "GROUP BY physician_first_name, physician_last_name " >> .command.sql
echo "ORDER BY sum_of_payments DESC " >> .command.sql
echo "LIMIT 10; " >> .command.sql
beeline -u jdbc:hive2://127.0.0.1:10000 --color=true --maxWidth=240 --maxColumnWidth=20 --truncateTable=true --numberFormat='###,###,###,##0.00' --silent -f /tmp/.command.sql
rm -rf .command.sql
