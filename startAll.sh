#!/usr/bin/env bash
# see http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -eu
set -o pipefail
#IFS=$'\n\t'

function finish {
  ~/showjava.sh
  # this file might be called with . ./startAll.sh, in which case we want to reset
  # some options to avoid being kicked out of our console on the first error after
  # this script
  set +eu
}
trap finish EXIT


#######################
# Declare global vars
#######################
java_options="-Xmx256m"
mvn_version=""
projects=(project1 project2)

####################################
# Print usage info for this script #
####################################
usage () {
cat <<EOF
Usage : $(basename $0) [-h] [-s | -o]

	Starts the openid connect provider, webshop or both

    -h: show this help
    -s: only project1
    -o: only project2
EOF
}

####################################################
# Check arguments and set parameters
####################################################
while getopts "hso" opt; do
        case $opt in
        h)
                usage && exit 0
        ;;
        s)
            projects=(project1)
        ;;
        o)
            projects=(project2)
        ;;
        \?)
                echo "Invalid option: -${OPTARG}" >&2 && usage && exit 1
        ;;
        esac
done
shift $((OPTIND-1))

####################################################
# Utility functions
####################################################
function monitorStart {
  local nohups=()
  local nr_started
  local proj
  local nh
  local starttime
  local phrase="AbstractConnector - Started"

  starttime="$(date +%T.%3N)"

  echo ""
  set +e

  for proj in "${projects[@]}"; do
      nohups+=("nohup.${proj}.out")
  done

  sleep 5
  for _ in {0..15}; do
      nr_started=0
      for nh in ${nohups[*]}; do
        [ -s "$nh" ] && ((nr_started=nr_started+$(grep "${phrase}" $nh| wc -l)))
      done
      if [ $nr_started -eq "${#nohups[*]}" ]; then
          break
      fi
      sleep 1
  done

  echo "at ${starttime} log checking started"
  # [ $nr_started -eq "${#nohups[*]}" ] && date +"at %T.%3N all apps were started"
  grep "${phrase}" nohup*out | sed -n 's|.*out:\([0-9:\.]\+\) dw-\([a-z]\+\).*\({[0-9\.:]\+}\)$|at \1 \2 started on \3|p'

  set -e
}

function doExit {
    echo -e "Exitting because:\n\t$1"
    ./endAll.sh
    exit 2
}

function startJar {
  local project=$1
  local logfile="nohup.${project}.out"
  local jarfile="${project}${mvn_version}.jar"
  local configfile="${project}.config.yml"
  local pid
  local pidfile="${project}.pid"
  local cmdlinefile

  [ -e "nohup.${project}.out" ] && rm "${logfile}"
  [ -s $jarfile ] || doExit "no jarfile: $jarfile"
  [ -s $configfile ] || doExit "no configfile: $configfile"

  nohup java ${java_options} -jar "${jarfile}" server "${configfile}" > ${logfile} 2>/dev/null &
  pid=$!
  echo $pid > "${pidfile}"

  sleep .5
  cmdlinefile="/proc/${pid}/cmdline"
  printf "Invoked (%6d): %s\n" "${pid}" "$(cat ${cmdlinefile} | tr '\0' ' ')"
}

##########################
# Main program
##########################
for proj in "${projects[@]}"
do
  startJar "$proj"
done

monitorStart
