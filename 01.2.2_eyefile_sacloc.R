#!/usr/bin/env Rscript
source('readscores.R')

## MAIN:
# find all wide files, and get luna_date from them
taskdir <- '/Volumes/L/bea_res/Data/Tasks/SaccadeLocalizerBasic'
stimdir <- 'stim_sacloc'
nruns <- 1
taskglob <- sprintf('%s/1*/2*/',taskdir)
all.ld <- sapply(Sys.glob(taskglob),function(x) strsplit(x,'/') %>% unlist %>% tail(2) %>% paste0(collapse='_') ) %>% unname
getallscores(all.ld,stimdir,taskdir,nruns,getautoscore) 
