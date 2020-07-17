#!/bin/bash

# Arguments 
#COMMIT=$1
#FONT=$2
#SIZE=$3
#DPI=$4
#BENCH=$5
#VIEW=$6
#STRING=$7
#START_C=$8
#END_C=$9

GIT_HASH=$(git log --pretty=format:'%h' -n 1)
 
${PREVIOUS_PWD}/ft-test-font.sh ${GIT_HASH} /home/greg/Inconsolata-Regular.ttf 16 72 1 1 1 0 963
if [ ! -z "$1" ]; then
 ${PREVIOUS_PWD}/ft-report.sh /home/greg/Inconsolata-Regular.ttf 16 ${1} ${2} &> /tmp/ft-report.html
fi
