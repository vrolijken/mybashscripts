#!/usr/bin/env bash

projects=('project1' 'project2')

if [ $# -ne 0 ]
  then
    projects=( "$@" )
fi

for proj in "${projects[@]}"
do
        date +"Doing for ${proj} %F %T"
        "../${proj}/src/main/script/${proj}.sh"
        if [[ "project1" == "$proj" ]]; then
                java -jar test.jar 
        fi
done

date +'Script done           %F %T'
