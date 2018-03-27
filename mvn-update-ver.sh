#! /usr/bin/bash

mvn versions:use-latest-releases versions:update-properties
mvn versions:display-plugin-updates
