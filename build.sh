#!/usr/bin/env bash

cd [ERGENS] ; mvn clean install javadoc:javadoc | tee ../env/buildout.txt | grep -e '.INFO. B' -e '.WARNING. ' -e 'Tests run: '

cd ../env
sed -n '/Tests in error:/,/Tests run:/ p' buildout.txt

echo '[INFO] ------------------------------------------------------------------------'
sed -n '/Reactor Summary:/,$p' buildout.txt

cp [ERGENS]/target/[NAAMZONDERVERSIE]-*.jar .
