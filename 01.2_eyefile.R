#!/usr/bin/env Rscript

library(LNCDR)
library(gdata) # read xls (not xlsx)
library(tidyr)
options(warn=1) # warn as it happens


## read in manually scored eye tracking

subjfiles <- function(ld) {
   ld <- gsub('_','/',ld)
   files <- Sys.glob(sprintf('/Volumes/L/bea_res/Data/Tasks/CogEmoSoundsBasic/%s/Scored/*/fs_*xls',ld))
   files <- files[!grepl('OLD',files,ignore.case = T)]
   return(files)
}
readfs <- function(f) { 
    fn=basename(f)
    d<-read.xls(f,sheet=2,header=F)%>%mutate(run=fn) 

    if(nrow(d) < 0 || ncol(d) < 10) warning(f, ' has too few rows or columns!')

    return(d)
}
readallfseye<- function(ld) {
   files<-subjfiles(ld)
   d <- lapply(files, readfs) %>%
        bind_rows %>%
        `names<-`(c('score','lat1','lat2','lat3','valence','score.val','trial','score.ec','lat.ec','run'))
   return(d)
}

## cleanup eye data files
# errors for 10892_20120111 10893_20111111 10894_20111117 10901_20111206 10911_20120109
cleaneye <- function(ld) {
   ## get and process score
   eyed <-  readallfseye(ld)
   eyed.m <-
      eyed %>% 
      select(trial,score.ec,lat1,run) %>%
      separate(score.ec,c('val','score'),'_') %>%
      # look for run (but r might be lower or upper)
      mutate(block=as.numeric(gsub('.*un(\\d).*','\\1',run)))
}

## MAIN:
# find all wide files, and get luna_date from them
all.ld <- sapply(Sys.glob('/Volumes/L/bea_res/Data/Tasks/CogEmoSoundsBasic/1*/2*/'),function(x) strsplit(x,'/') %>% unlist %>% tail(2) %>% paste0(collapse='_') ) %>% unname

if(!dir.exists('stim/score')) dir.create('stim/score')
for (ld in all.ld){
  outfile<-sprintf('stim/score/%s_score.txt',ld)
  if(file.exists(outfile)) next
  m<-tryCatch(cleaneye(ld),error=function(e){warning(ld,e);return()})
  if(length(m)<2L) {warning(ld,' failed');next}
  write.table(m,outfile,row.names=F,quote=F,sep="\t")
}
#warnings()
