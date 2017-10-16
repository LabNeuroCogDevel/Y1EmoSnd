#!/usr/bin/env bash
set -e
trap 'e=$?; [ $e -ne 0 ] && echo "$0 exited in error"' EXIT
#
# combine perl and R code for each subject 
#

cd $(dirname $0)
outdir=stim/long
[ ! -d $outdir ] && mkdir -p $outdir

# luna date from string ending in lunaid/date/ (ending slash is why -c2-15 and not -c1-14)
getld8() { echo $1|rev|cut -c 2-15|rev|tr / _; }
# also could try
#echo $d | cut -f $[ $(echo $d|tr / '\n'|wc -l) -2]- -d / 
haslines() {  [ $(cat $1 | wc -l ) -gt 1 ]; }

for d in /Volumes/L/bea_res/Data/Tasks/CogEmoSoundsBasic/1*/2*/; do
   
   ld8=$(getld8 $d)
   outfile=$outdir/${ld8}_long.txt
   if [ -r $outfile ]; then
     ! haslines $outfile && echo "$d: empty file $outfile"
      continue
   fi
   echo $ld8
   find $d -iname 'CogEmo*.txt' | xargs ./parseEP.pl > $outfile
done

find $outdir -maxdepth 1  -iname '*_long.txt' | xargs ./parseEP.R
