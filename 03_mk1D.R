#!/usr/bin/env Rscript

library(LNCDR)
library(gdata) # read xls (not xlsx)

d<- read.file('stim/wide_score/_score.txt',ld)



# only the Neg sounds
d %>%
   filter(Procedure_note == 'antiNeg', score=='errorCorrected' ) %>% 
   save1D(colname='SoundOut1_OnsetTime', dur='SoundOut1_Duration',nblocks=4)
   #file=neg_errCor_snd.1D
