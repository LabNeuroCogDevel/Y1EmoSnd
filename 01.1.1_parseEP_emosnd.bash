#!/usr/bin/env bash
set -e
trap 'e=$?; [ $e -ne 0 ] && echo "$0 exited in error"' EXIT
#
# combine perl and R code for each subject 
#

cd $(dirname $0)
source parseEP.bash
outdir=stim/long
taskdir=/Volumes/L/bea_res/Data/Tasks/CogEmoSoundsBasic
EPfilename='CogEmo*.txt'
starttrialeventpart=0ITI10OnsetTime
all_parseEP
towide
