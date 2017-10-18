#!/usr/bin/env bash

ldfromfile(){ grep -Po '\d{5}_\d{8}'; }
msg(){
   f=$1
   ld=$(echo $f|ldfromfile)
   thing=$(echo $f | sed 's:stim/\(.*\)/.*:\1:')
   echo -e "$ld\t$thing\t$2 ($f)"
}
# do we have a file?
isfile(){
   [ ! -r $1 ] && msg $1 "file is missing!" && return 1
   return 0
}
# check the number of lines in a files
cntlt(){ 
   cnt=$(cat $1|wc -l)
   [ "$cnt" -ne $2 ] && msg $1 "nlines $cnt!=$2" && return 1
   return 0
}
# check the number of fields in header of file
nf(){
   cnt=$(sed 1q $1 | awk 'END{print NF}'|| echo 0)
   [ "$cnt" -ne $2 ] && msg $1 "ncols $cnt!=$2" && return 1
   return 0
}
# put all together
check(){
 isfile $1 && cntlt $1 $2 && nf $1 $3
}

ls stim/*/*.txt |ldfromfile|sort|uniq | while read ld; do
 
 rawscorepath=/Volumes/L/bea_res/Data/Tasks/CogEmoSoundsBasic/${ld/_/\/}/Scored/
 nrawscore=$(find $rawscorepath -iname 'fs_*run*.xls' -and -not -iname '*OLD*' 2>/dev/null|wc -l)
 [ $nrawscore -ne 4 ] && echo -e "$ld\txls\t$nrawscore!=4 ($rawscorepath)" && continue

 sf=stim/score/${ld}_score.txt
 check $sf 113 6 || continue

 lf=stim/long/${ld}_long.txt
 check $lf 2369 7 || continue


 wf=stim/wide/${ld}_wide.txt
 check $wf 113 28 || continue

 wsf=stim/wide_score/10370_20120918_wide.txt

done
