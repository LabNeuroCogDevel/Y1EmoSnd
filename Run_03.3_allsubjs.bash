#!/bin/bash

for s in /Volumes/Zeus/MMY1_EmoSnd/scripts/timing/stim/stimtimes/1*; do
	subj=$(basename $s)
	f=stim/wide_score/${subj}_*.txt
	file=$(basename $f)
	Rscript 03.3_mk1D_emosnd_ratings2.R $file $subj
done
