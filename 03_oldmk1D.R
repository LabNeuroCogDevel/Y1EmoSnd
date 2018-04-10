#!/usr/bin/env Rscript


library(LNCDR)

subjects <- list('stim/wide_score/10370_20120918_score.txt','stim/wide_score/10892_20111217_score.txt')

for (${subj} in {subjects}) {
  ## read in data (one visit)
  d<- read.table('stim/wide_score/10370_20120918_score.txt',sep="\t",quote="",header=T)
  ## what does data look like
unique(d$score) # correct errorCorrected drop error
levels(d$Procedure_note) # antiNeg antiNeu antiPos antiSil
# all columns
names(d)
# all onsets
grep('Onset',names(d),value=T)

#nblocks=number of runs!!

#First: separated just by accuracy
#
#All correct
d %>%
  filter(score=='correct' ) %>% 
  save1D(colname='SoundOut1_OnsetTime', nblocks=4, fname='all_cor.1D')
#
#All Error Corrected
d %>%
  filter(score=='errorCorrected' ) %>% 
  save1D(colname='SoundOut1_OnsetTime', nblocks=4, fname='all_errCor.1D')
#
#All error
d %>%
  filter(score=='errorCorrected' ) %>% 
  save1D(colname='SoundOut1_OnsetTime', nblocks=4, fname='all_err.1D')
#
#






# only the Neg sounds and error corrected
d %>%
   filter(Procedure_note == 'antiNeg', score=='errorCorrected' ) %>% 
   save1D(colname='SoundOut1_OnsetTime', nblocks=4, fname='neg_errCor.1D')

# all correct, cue (no dur)
d %>%
   filter(score=='correct' ) %>% 
   save1D(colname='cue1_OnsetTime', nblocks=4, fname='cue_cor.1D')
   #file=cue_cor.1D

# all correct, sound (no dur)
d %>%
  filter(score=='correct' ) %>% 
  save1D(colname='SoundOut1_OnsetTime', nblocks=4, fname='sound_cor.1D')

#all error corrected, sound
d %>%
  filter(score=='errorCorrected' ) %>% 
  save1D(colname='SoundOut1_OnsetTime', nblocks=4, fname='sound_errCor.1D')

# only the Pos sounds and error corrected
d %>%
  filter(Procedure_note == 'antiPos', score=='errorCorrected' ) %>% 
  save1D(colname='SoundOut1_OnsetTime', nblocks=4, fname='Pos_ErrCorr.1D')
#file=neg_errCor_snd.1D
# only the Pos sounds and Correct
d %>%
  filter(Procedure_note == 'antiPos', score=='correct' ) %>% 
  save1D(colname='SoundOut1_OnsetTime', nblocks=4, fname='Pos_Corr.1D')