#!/usr/bin/env bash
set -e
trap 'e=$?; [ $e -ne 0 ] && echo "$0 exited in error"' EXIT
#
# combine perl and R code for each subject 
# to generate stim files in long and then wide format
#

cd $(dirname $0)
source parseEP.bash

outdir=stim_sacloc/long
taskdir=/Volumes/L/bea_res/Data/Tasks/SaccadeLocalizerBasic
EPfilename='SacLoc_run1*.txt'
starttrialeventpart=0fixation1OnsetTime
all_parseEP
towide
