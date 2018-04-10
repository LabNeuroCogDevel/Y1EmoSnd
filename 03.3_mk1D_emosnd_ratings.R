#!/usr/bin/env Rscript

# 20180315 -- add subject ratings to 

library(LNCDR)


args <- commandArgs(trailingOnly = TRUE)
timingfile<-args[1] # e.g. 11046_20120816_score.txt # file in stim/wide_score
lunaid <- substr(args[2],1,5) # e.g. 11046



### READ IN TIMING AND AROSUAL/VALENCE

#setwd('Z:/MMY1_EmoSnd/scripts/timing/stim/wide_score')
setwd('/Volumes/Zeus/MMY1_EmoSnd/scripts/timing/stim/wide_score')
if(!file.exists(timingfile)) stop('cannot find provided timing inptut file ', timingfile)

# luna id is first 5 chars of input arguments
# use that to load the arsousal valence file (created by 00_valance_arousal.R)
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

#### MAKE 1D files

#score: correct errorCorrected drop error
#Procedure_note: antiNeg antiNeu antiPos antiSil
#First: separated just by accuracy
#
# go to where we will save this
#setwd(paste("Z:/MMY1_EmoSnd/scripts/timing/stim/stimtimes/", args[2], sep=""))
setwd(paste('/Volumes/Zeus/MMY1_EmoSnd/scripts/timing/stim/stimtimes/', lunaid, sep=""))

mkname <- function(n) paste0(lunaid,'_',n,'.1D')

#All correct - valence amp
# TODO: consider using dur (':' sep) instead of amp ('*' sep)?
d %>%
  filter(score=='correct' ) %>% 
  save1D(colname='SoundOut1_OnsetTime',amp='valence', nblocks=4,
         fname=mkname('all_corr_valamp'))

# TODO: add more 1D files
