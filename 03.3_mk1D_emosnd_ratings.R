#!/usr/bin/env Rscript

# 20180315 -- add subject ratings to 

library(LNCDR)


args <- commandArgs(trailingOnly = TRUE)
#args[1]=file name of source stim file
#args[2]=luna id

### READ IN TIMING AND AROSUAL/VALENCE

#setwd('Z:/MMY1_EmoSnd/scripts/timing/stim/wide_score')
setwd('/Volumes/Zeus/MMY1_EmoSnd/scripts/timing/stim/wide_score')
timingfile<-args[1]
if(!file.exists(timingfile)) stop('cannot find provided timing inptut file ', timingfile)

# luna id is first 5 chars of input arguments
# use that to load the arsousal valence file (created by 00_valance_arousal.R)
lunaid <- substr(args[1],1,5)
arsvalfile <- sprintf('../ars_val/%s.txt',lunaid)
if(!file.exists(arsvalfile)) stop('cannot find arousal valence file ', arsvalfile)
arsval<- read.table(arsvalfile,header=T,stringsAsFactor=F)
# remove duplicates
arsval <- arsval[!duplicated(arsval$Sound),]

## read in data (one visit)
timing_wide <- read.table(timingfile,sep="\t",quote="",header=T)
timing_wide$SoundStim_note <- gsub('^ ', '',as.character(timing_wide$SoundStim_note))
d<-merge(timing_wide,arsval,by.x='SoundStim_note',by.y='Sound',all.x=T,all.y=F)
# reorder
d<-d[order(d$block,d$trial),]
#nblocks=number of runs!!

#### NOW MAKE 1D files

#score: correct errorCorrected drop error
#Procedure_note: antiNeg antiNeu antiPos antiSil
#First: separated just by accuracy
#
#setwd(paste("Z:/MMY1_EmoSnd/scripts/timing/stim/stimtimes/", args[2], sep=""))
setwd(paste('/Volumes/Zeus/MMY1_EmoSnd/scripts/timing/stim/stimtimes/', args[2], sep=""))
#All correct
d %>%
  filter(score=='correct' ) %>% 
  save1D(colname='SoundOut1_OnsetTime', nblocks=4, fname=(paste(args[2], "_all_cor.1D", sep="")))
#
#All Error Corrected
d %>%
  filter(score=='errorCorrected' ) %>% 
  save1D(colname='SoundOut1_OnsetTime', nblocks=4, fname=(paste(args[2], "_all_errCor.1D", sep="")))
#
#All error (uncorrected)
d %>%
  filter(score=='error' ) %>% 
  save1D(colname='SoundOut1_OnsetTime', nblocks=4, fname=(paste(args[2], '_all_err.1D', sep="")))
#
#
#Now just by condition
#All positive
d %>%
  filter(Procedure_note=='antiPos', score != "drop" ) %>% 
  save1D(colname='SoundOut1_OnsetTime', nblocks=4, fname=(paste(args[2], "_all_pos.1D", sep="")))
#
#All negative
d %>%
  filter(Procedure_note=='antiNeg', score != "drop" ) %>% 
  save1D(colname='SoundOut1_OnsetTime', nblocks=4, fname=(paste(args[2], "_all_neg.1D", sep="")))
#
#All neutral
d %>%
  filter(Procedure_note=='antiNeu', score != "drop" ) %>% 
  save1D(colname='SoundOut1_OnsetTime', nblocks=4, fname=(paste(args[2], "_all_neu.1D", sep="")))
#
#All silence
d %>%
  filter(Procedure_note=='antiSil', score != "drop" ) %>% 
  save1D(colname='SoundOut1_OnsetTime', nblocks=4, fname=(paste(args[2], "_all_sil.1D", sep="")))
#
#Now condition AND score
#Positive, correct only
d %>%
  filter(Procedure_note=='antiPos', score=='correct' ) %>% 
  save1D(colname='SoundOut1_OnsetTime', nblocks=4, fname=(paste(args[2], "_pos_cor.1D", sep="")))
#
#Positive, error corrected only
d %>%
  filter(Procedure_note=='antiPos', score=='errorCorrected' ) %>% 
  save1D(colname='SoundOut1_OnsetTime', nblocks=4, fname=(paste(args[2], "_pos_errCor.1D", sep="")))
#
#Positive, correct + error corrected
d %>%
  filter(Procedure_note=='antiPos', score %in% c("errorCorrected", "correct")) %>% 
  save1D(colname='SoundOut1_OnsetTime', nblocks=4, fname=(paste(args[2], "_pos_cor_errCor.1D", sep="")))
#
#Positive, error only
d %>%
  filter(Procedure_note=='antiPos', score=='error' ) %>% 
  save1D(colname='SoundOut1_OnsetTime', nblocks=4, fname=(paste(args[2], "_pos_err.1D", sep="")))
#
#Positive, error corrected + error
d %>%
  filter(Procedure_note=='antiPos', score %in% c("errorCorrected", "error")) %>% 
  save1D(colname='SoundOut1_OnsetTime', nblocks=4, fname=(paste(args[2], "_pos_errCor_err.1D", sep="")))
#
#
#Negative, correct only
d %>%
  filter(Procedure_note=='antiNeg', score=='correct' ) %>% 
  save1D(colname='SoundOut1_OnsetTime', nblocks=4, fname=(paste(args[2], "_neg_cor.1D", sep="")))
#
#Negative, error corrected only
d %>%
  filter(Procedure_note=='antiNeg', score=='errorCorrected' ) %>% 
  save1D(colname='SoundOut1_OnsetTime', nblocks=4, fname=(paste(args[2], "_neg_errCor.1D", sep="")))
#
#Negative, correct + error corrected
d %>%
  filter(Procedure_note=='antiNeg', score %in% c("errorCorrected", "correct")) %>% 
  save1D(colname='SoundOut1_OnsetTime', nblocks=4, fname=(paste(args[2], "_neg_cor_errCor.1D", sep="")))
#
#Negative, error only
d %>%
  filter(Procedure_note=='antiNeg', score=='error' ) %>% 
  save1D(colname='SoundOut1_OnsetTime', nblocks=4, fname=(paste(args[2], "_neg_err.1D", sep="")))
#
#Negative, error corrected + error
d %>%
  filter(Procedure_note=='antiNeg', score %in% c("errorCorrected", "error") ) %>% 
  save1D(colname='SoundOut1_OnsetTime', nblocks=4, fname=(paste(args[2], "_neg_errCor_err.1D", sep="")))
#
#
#Neutral, correct only
d %>%
  filter(Procedure_note=='antiNeu', score=='correct' ) %>% 
  save1D(colname='SoundOut1_OnsetTime', nblocks=4, fname=(paste(args[2], "_neu_cor.1D", sep="")))
#
#Neutral, error corrected only
d %>%
  filter(Procedure_note=='antiNeu', score=='errorCorrected' ) %>% 
  save1D(colname='SoundOut1_OnsetTime', nblocks=4, fname=(paste(args[2], "_neu_errCor.1D", sep="")))
#
#Neutral, correct + error corrected
d %>%
  filter(Procedure_note=='antiNeu', score %in% c("errorCorrected", "correct")) %>% 
  save1D(colname='SoundOut1_OnsetTime', nblocks=4, fname=(paste(args[2], "_neu_cor_errCor.1D", sep="")))
#
#Neutral, error only
d %>%
  filter(Procedure_note=='antiNeu', score=='error' ) %>% 
  save1D(colname='SoundOut1_OnsetTime', nblocks=4, fname=(paste(args[2], "_neu_err.1D", sep="")))
#
#Neutral, error corrected + error
d %>%
  filter(Procedure_note=='antiNeu', score %in% c("errorCorrected", "correct")) %>% 
  save1D(colname='SoundOut1_OnsetTime', nblocks=4, fname=(paste(args[2], "_neu_errCor_err.1D", sep="")))
#
#
#Silence, correct only
d %>%
  filter(Procedure_note=='antiSil', score=='correct' ) %>% 
  save1D(colname='SoundOut1_OnsetTime', nblocks=4, fname=(paste(args[2], "_sil_cor.1D", sep="")))
#
#Silence, error corrected only
d %>%
  filter(Procedure_note=='antiSil', score=='errorCorrected' ) %>% 
  save1D(colname='SoundOut1_OnsetTime', nblocks=4, fname=(paste(args[2], "_sil_errCor.1D", sep="")))
#
#Silence, correct + error corrected
d %>%
  filter(Procedure_note=='antiSil', score %in% c("errorCorrected", "correct")) %>% 
  save1D(colname='SoundOut1_OnsetTime', nblocks=4, fname=(paste(args[2], "_sil_cor_errCor.1D", sep="")))
#
#Silence, error only
d %>%
  filter(Procedure_note=='antiSil', score=='error' ) %>% 
  save1D(colname='SoundOut1_OnsetTime', nblocks=4, fname=(paste(args[2], "_sil_err.1D", sep="")))
#
#Silence, error corrected + error
d %>%
  filter(Procedure_note=='antiSil', score %in% c("errorCorrected", "correct")) %>% 
  save1D(colname='SoundOut1_OnsetTime', nblocks=4, fname=(paste(args[2], "_sil_errCor_err.1D", sep="")))
#

