#!/usr/bin/env Rscript
library(LNCDR)

## read in data (one visit)
d<- read.table('stim/wide_score/10370_20120918_score.txt',sep="\t",quote="",header=T)

## what does data look like
unique(d$score) # correct errorCorrected drop error
levels(d$Procedure_note) # antiNeg antiNeu antiPos antiSil
# all columns
names(d)
# all onsets
grep('Onset',names(d),value=T)


### 1d examples
# only the Neg sounds and error corrected
d %>%
   filter(Procedure_note == 'antiNeg', score=='errorCorrected' ) %>% 
   save1D(colname='SoundOut1_OnsetTime', dur='SoundOut1_Duration',nblocks=4)
   #file=neg_errCor_snd.1D

# all correct, cue (no dur)
d %>%
   filter(score=='correct' ) %>% 
   save1D(colname='cue1_OnsetTime', nblocks=4)
   #file=all_cor.1D
