#!/usr/bin/env bash

set -e

#date +"Building script %F %T"
echo "select 'SCHEMA_1';" > tmpTableCount.sql
mysql -h 127.0.0.1 -Nse 'show tables' SCHEMA_1 | tr -d '\r' | while read table; do echo "select count(1), '${table}' from SCHEMA_1.${table};" >> tmpTableCount.sql; done
echo "select 'SCHEMA_2';" >> tmpTableCount.sql
mysql -h 127.0.0.1 -Nse 'show tables' SCHEMA_2 | tr -d '\r' | while read table; do echo "select count(1), '${table}' from SCHEMA_2.${table};" >> tmpTableCount.sql; done

sed -i -e '/select count(1)[^\n]\+ SCHEMA_[0-9]*.version;/d' tmpTableCount.sql

#date +"Executing script %F %T"

# use sed & printf to colorize the output, makes it easier to find what I'm looking for (i.e. non 0 rows)
base="$(printf '\e[0m')"
strong="$(printf '\e[93m')"
header="\n$(printf '\e[4;97m')"

# mysql -h 127.0.0.1 -N < tmpTableCount.sql | sed -e "s|^\([1-9][0-9]*.*\)$|$(printf '\e[93m')* \1$(printf '\e[0m')|g" -e "s|^0|  0|g" -e "s|^\(SCHEMA_[0-9]\+\)|\n$(printf '\e[4;97m')\1$(printf '\e[0m')|g"
mysql -h 127.0.0.1 -N < tmpTableCount.sql | sed -e "s|^\([1-9][0-9]*.*\)$|${strong}* \1${base}|g" -e "s|^0|  0|g" -e "s|^\(SCHEMA_[0-9]\+\)|\n${header}\1${base}|g"

date +"Script done %F %T"
