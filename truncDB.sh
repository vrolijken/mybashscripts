#!/usr/bin/env bash

set -e

date +"Building script         %F %T"
echo "SET FOREIGN_KEY_CHECKS = 0;" > tmpTruncTable.sql
mysql -h 127.0.0.1 -Nse 'show tables' SCHEMA_1 | tr -d '\r' | while read table; do echo "truncate table SCHEMA_1.${table};" >> tmpTruncTable.sql; done
echo "select 'truncating schema1', CURRENT_TIMESTAMP;" >> tmpTruncTable.sql
mysql -h 127.0.0.1 -Nse 'show tables' SCHEMA_2 | tr -d '\r' | while read table; do echo "truncate table SCHEMA_2.${table};" >> tmpTruncTable.sql; done
echo "select 'truncating schema2', CURRENT_TIMESTAMP;" >> tmpTruncTable.sql
echo "SET FOREIGN_KEY_CHECKS = 1;" >> tmpTruncTable.sql

# Do not truncate the version table in any schema
sed -i -e '/truncate table SCHEMA_[0-9]*.version;/d' tmpTruncTable.sql

date +"Executing script        %F %T"

mysql -h 127.0.0.1 -N < tmpTruncTable.sql

# Do post-processing
java -jar test.jar

date +"Script done             %F %T"

# . ./countDB.sh
