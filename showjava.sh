#!/usr/bin/env bash
[ 0 -eq $(ps -as | grep java | wc -l) ] && echo "No java processes running" && exit

echo -e "\nRunning Java processes:"
echo "PID   | command line"
echo "------+-------------"
ps -as | grep java | grep -v grep | \
  sed -n 's| \+\([0-9]\+\).*|printf "%5d \| " "\1" ; cat /proc/\1/cmdline ; echo ""|p' | \
  bash | tr '\0' ' '
