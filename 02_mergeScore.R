#!/usr/bin/env Rscript

library(LNCDR)
library(gdata) # read xls (not xlsx)
library(tidyr)
options(warn=1) # warn as it happens


## read in manually scored eye tracking
readfs <- function(f) { 
    fn=basename(f)
    read.xls(f,sheet=2,header=F)%>%mutate(run=fn) 
}
readallfseye<- function(ld) {
   ld <- gsub('_','/',ld)
   files <- Sys.glob(sprintf('/Volumes/B/bea_res/Data/Tasks/CogEmoSoundsBasic/%s/Scored/*/fs_*xls',ld))
   files <- files[!grepl('OLD',files,ignore.case = T)]
   d <- lapply(files, readfs) %>%
        bind_rows %>%
        `names<-`(c('score','lat1','lat2','lat3','valence','score.val','trial','score.ec','lat.ec','run'))
   return(d)
}

## merge score (manual score fs_*xls)  with timing (from 01_parseEP.bash)
mergeScoreTime <- function(ld) {
   ## get and process score
   eyed <-  readallfseye(ld)
   eyed.m <-
      eyed %>% 
      select(trial,score.ec,lat1,run) %>%
      separate(score.ec,c('val','score'),'_') %>%
      mutate(block=as.numeric(gsub('.*un(\\d).*','\\1',run)))

   ## get time
   timefile <- sprintf('stim/wide/%s_wide.txt',ld) 
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
