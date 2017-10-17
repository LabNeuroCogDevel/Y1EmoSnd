#!/usr/bin/env Rscript

library(LNCDR)
library(gdata) # read xls (not xlsx)
library(tidyr)
options(warn=1) # warn as it happens


## merge score (manual score fs_*xls)  with timing (from 01_parseEP.bash)
mergeScoreTime <- function(ld) {
   ## get and process score
   eyefile <- sprintf('stim/score/%s_score.txt',ld) 
   if(! file.exists(eyefile) ) { warning('missing ',eyefile); return() }

   eyed.m <-  read.table(eyefile,sep="\t",header=T,quote="")

   ## get time
   timefile <- sprintf('stim/wide/%s_wide.txt',ld) 
   if(! file.exists(timefile) ) { warning('missing ',timefile); return() }

   d.time <- read.table(timefile,sep="\t",header=T,quote="")

   d <- merge(d.time,eyed.m, by=c('trial','block')) %>% arrange(subj,block,trial)
   return(d)
}

## MAIN:
# find all wide files, and get luna_date from them
all.ld <- sapply(Sys.glob('stim/wide/*_wide.txt'),function(x) gsub('_wide.txt','',basename(x) )) %>% unname

# failing
# 10893_20111111
# 10894_20111117
if(!dir.exists('stim/wide_score')) dir.create('stim/wide_score')
for (ld in all.ld){
  outfile<-sprintf('stim/wide_score/%s_score.txt',ld)
  if(file.exists(outfile)) next
  m<-tryCatch(mergeScoreTime(ld),error=function(e){warning(ld,e);return()})
  if(length(m)<2L) {warning(ld,' failed');next}
  write.table(m,outfile,row.names=F,quote=F,sep="\t")
}
#warnings()
