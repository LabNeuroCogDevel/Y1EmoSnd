#!/usr/bin/env bash
# WF 20171219
# uses parseEP.pl and then parseEP.R
# to generate outdir/long and outdir/wide
# this is source file for 01.1_parseEP_emosnd.bash 01.2_parseEP_sacloc.bash
#  these files define starttrialeventpart, outdir, taskdir, and EPfilename
#  and run all_parseEP and towide

# luna date from string ending in lunaid/date/ (ending slash is why -c2-15 and not -c1-14)
getld8() { echo $1|rev|cut -c 2-15|rev|tr / _; }
# also could try
#echo $d | cut -f $[ $(echo $d|tr / '\n'|wc -l) -2]- -d / 
haslines() {  [ $(cat $1 | wc -l ) -gt 1 ]; }

# give a dir like (/Volumes/L/bea_res/Data/Tasks/SaccadeLocalizerBasic/10931/20120202/), make xxxxx_yyyyyyy_long.txt for each "EPfilename" match
# globals: outdir,EPfilename, starttrialeventpart
dirToLong(){
     d=$1
     [ -z "$d" -o ! -d "$d" ] && echo "$FUNCNAME: bad input '$1'" && return 1
     if [ -z "$outdir" -o -z "$EPfilename" -o -z "$starttrialeventpart" ]; then
       echo "$FUNCNAME: globals not set: outdir=$outdir EPfilename=$EPfilename starttrialeventpart=$starttrialeventpart"
       return 1
     fi
     ld8=$(getld8 $d)
     outfile=$outdir/${ld8}_long.txt
     if [ -r $outfile ]; then
       ! haslines $outfile && echo "$d: empty file $outfile; rm $outfile # to retry" && return 1
       # or we already did this and we cn skip
       return 0
     fi
     echo $ld8

     # show what file we have if debugging
     if [ -n "$DEBUG" ]; then 
       echo "search $d for  $EPfilename" 
       find $d -iname "$EPfilename"
     fi

     # starttrialeventpart can be empyt, will default to emosnd task start
     # otherwise will use eg "0fixation1OnsetTime" (trial 0's fixation1's onsetettime) to normalzie times
     find $d -iname "$EPfilename" -and -not -iname '*unix.txt' | xargs ./parseEP.pl $starttrialeventpart > $outfile
}

all_parseEP(){
  [ ! -d $outdir ] && mkdir -p $outdir

  # global taskdir, outdir, EPfilename
  for d in $taskdir/1*/2*/; do
    dirToLong $d || echo "ep to txt failed for $d"
  done
}
towide() {
  find $outdir -maxdepth 1  -iname '*_long.txt' | xargs ./parseEP.R
}
