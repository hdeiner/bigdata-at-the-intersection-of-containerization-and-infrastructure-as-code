#!/usr/bin/env bash

echo "$(tput bold)$(tput setaf 6)Test Hive$(tput sgr 0)"

echo "$(tput setaf 6)Create Schema$(tput sgr 0)"
docker exec -it hive-server bash -c "hdfs dfs -rm -r /user/hive/warehouse > /dev/null 2> /dev/null"
docker cp PGYR2019_P06302020.schema hive-server:/tmp/PGYR2019_P06302020.schema
docker exec -it hive-server bash -c "beeline -u jdbc:hive2://127.0.0.1:10000 --color=true --autoCommit=true -f /tmp/PGYR2019_P06302020.schema 2> /dev/null"
echo ""
echo ""

echo "$(tput setaf 6)Display Tables Created$(tput sgr 0)"
docker exec -it hive-server bash -c "beeline -u jdbc:hive2://localhost:10000 --color=true --autoCommit=true -e 'show tables;' 2> /dev/null"
echo ""

echo "$(tput setaf 6)Create Sample Data and Import It Into Hive$(tput sgr 0)"
head -n 10348 /tmp/PGYR19_P012221/bigdata.csv > /tmp/bigdata.sample.csv
docker cp /tmp/PGYR19_P012221/bigdata.sample.csv hive-server:/tmp/bigdata.sample.csv
echo "LOAD DATA LOCAL INPATH '/tmp/bigdata.sample.csv' INTO TABLE PGYR2019_P06302020" > .hive_command
docker cp .hive_command hive-server:/tmp/hive_command
docker exec hive-server beeline -u jdbc:hive2://localhost:10000 --color=true --autoCommit=true -f /tmp/hive_command 2> /dev/null
echo ""
echo ""
rm .hive_command

echo "$(tput setaf 6)Location of data in Hadoop$(tput sgr 0)"
docker exec hive-server bash -c "hdfs dfs -ls -h /user/hive/warehouse/pgyr2019_p06302020/bigdata.sample.csv"
echo ""

echo "$(tput setaf 6)Display first two rows of data$(tput sgr 0)"
docker exec hive-server bash -c "beeline -u jdbc:hive2://localhost:10000 --color=true --maxWidth=240 --maxColumnWidth=20 --truncateTable=true --silent -e 'SELECT * FROM PGYR2019_P06302020 LIMIT 2;' 2> /dev/null"
echo ""

echo "$(tput setaf 6)Count of rows of data$(tput sgr 0)"
docker exec hive-server bash -c "beeline -u jdbc:hive2://localhost:10000 --color=true --maxWidth=240 --maxColumnWidth=20 --truncateTable=true --silent -e 'SELECT COUNT(*) AS count_of_rows_of_data FROM PGYR2019_P06302020;' 2> /dev/null"
echo ""

echo "$(tput setaf 6)Average of total_amount_of_payment_usdollars$(tput sgr 0)"
docker exec hive-server bash -c "beeline -u jdbc:hive2://localhost:10000 --color=true --maxWidth=240 --maxColumnWidth=20 --truncateTable=true --numberFormat='###,###,###,##0.00' --silent -e 'SELECT AVG(total_amount_of_payment_usdollars) AS average_of_total_amount_of_payment_usdollars FROM PGYR2019_P06302020;' 2> /dev/null"
echo ""

echo "$(tput setaf 6)Top ten earning physicians$(tput sgr 0)"
echo "SELECT physician_first_name, physician_last_name, SUM(total_amount_of_payment_usdollars) AS sum_of_payments" > .command.sql
echo "FROM PGYR2019_P06302020 " >> .command.sql
echo "WHERE physician_first_name != '' "  >> .command.sql
echo "AND physician_last_name != '' " >> .command.sql
echo "GROUP BY physician_first_name, physician_last_name " >> .command.sql
echo "ORDER BY sum_of_payments DESC " >> .command.sql
echo "LIMIT 10; " >> .command.sql
docker cp .command.sql hive-server:/tmp/command.sql
docker exec hive-server bash -c "beeline -u jdbc:hive2://localhost:10000 --color=true --maxWidth=240 --maxColumnWidth=20 --truncateTable=true --numberFormat='###,###,###,##0.00' --silent -f /tmp/command.sql 2> /dev/null"
rm .command.sql