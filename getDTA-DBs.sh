#!/usr/bin/env bash
# see http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -eu
set -o pipefail
IFS=$'\n\t'

ssh -q myusername@devhost.internal "mysqldump -uroot -pROOTPASSWORD --add-drop-database --create-options --databases SCHEMA_1 SCHEMA_2 | gzip -9" | gunzip > dev.restore.sql
ssh -q myusername@testhost.internal "mysqldump -uroot -pROOTPASSWORD --add-drop-database --create-options --databases  SCHEMA_1 SCHEMA_2 | gzip -9" | gunzip > test.restore.sql
ssh -q myusername@acceptance.internal "mysqldump -uexporter -pEXPORTERPASS --add-drop-database --create-options --databases SCHEMA_1 SCHEMA_2 | gzip -9" | gunzip > acceptance.restore.sql

# feed these to localhost as follows: 
# mysql < dev.restore.sql
