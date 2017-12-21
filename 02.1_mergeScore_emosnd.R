#!/usr/bin/env Rscript

library(LNCDR)
library(gdata) # read xls (not xlsx)
library(tidyr)
options(warn=1) # warn as it happens
source('readscores.R')



## MAIN:
# find all wide files, and get luna_date from them
all.ld <- sapply(Sys.glob('stim/wide/*_wide.txt'),function(x) gsub('_wide.txt','',basename(x) )) %>% unname

stimdir="stim"
outdir="stim/wide_score"

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
