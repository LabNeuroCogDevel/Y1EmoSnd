#!/usr/bin/env Rscript

library(LNCDR)
library(gdata) # read xls (not xlsx)
library(tidyr)
options(warn=1) # warn as it happens
source('readscores.R')

stimdir <- 'stim_sacloc'
outdir <- file.path(stimdir,'wide_score')
## MAIN:
# find all wide files, and get luna_date from them
all.ld <- sapply(Sys.glob(file.path(stimdir,'/wide/*_wide.txt')),function(x) gsub('_wide.txt','',basename(x) )) %>% unname

# failing
# 10893_20111111
# 10894_20111117
if(!dir.exists(outdir)) dir.create(outdir)
for (ld in all.ld){
  outfile<-sprintf('%s/%s_score.txt',outdir,ld)
  if(file.exists(outfile)) next
  m<-tryCatch(mergeScoreTime(ld,stimdir),error=function(e){warning(ld,e);return()})
  if(length(m)<2L) {warning(ld,' failed');next}
  # remove junk after procedure note ("vgs40 VgsTaskP ANTISTART" -> "vgs40")
  m %>% 
   mutate(Procedure_note = gsub(' .*','',Procedure_note)) %>%
   write.table(outfile,row.names=F,quote=F,sep="\t")
}
#warnings()
