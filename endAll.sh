#!/usr/bin/env bash

function finish {
  ~/showjava.sh
}
trap finish EXIT

#######################
# Declare global vars
#######################
projects=(project1 project2)


####################################
# Print usage info for this script #
####################################
usage () {
cat <<EOF
Usage : $(basename $0) [-h] [-s | -o]

	Ends the openid connect provider, webshop or both, if we think they're started

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
function doKill {
	local proj=${1}
	local pidfile="${proj}.pid"
	local pid

	if [ -s "${pidfile}" ]; then
		pid=$(cat "$pidfile")
		printf "Killing %-8s (%6d)\n" "${proj}" "${pid}"
		kill "${pid}"
		rm "${pidfile}"
	else
		printf "No pid found for %s\n" "${proj}"
	fi
}

##########################
# Main program
##########################
for proj in ${projects[*]} ; do
	doKill "${proj}"
done;
