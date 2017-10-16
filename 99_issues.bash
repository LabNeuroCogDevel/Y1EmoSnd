#!/usr/bin/env bash

for f in stim/wide*/*;do 
   cnt=$(cat $f|wc -l);
   [ $cnt  -ne 113 ] && echo "$f $cnt";
done
