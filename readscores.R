#!/usr/bin/env Rscript

# source by 01.2.2_eyefile_sacloc.R 01.2_eyefile.R

library(LNCDR)
library(gdata) # read xls (not xlsx)
library(tidyr)
options(warn=1) # warn as it happens

## 20171220 - WF - reorg for sacloc as well as emosnd task
## 20171106 - WF - OR
# 10894_20111117 # input issue: too many match files
# 10912_20120104 # column issue
# 10934_20120207 
# 10972_20120417

## read in manually scored eye tracking

# find all scored files for a subject
subjfiles <- function(ld,taskdir='/Volumes/L/bea_res/Data/Tasks/CogEmoSoundsBasic',nruns=4) {
   ld <- gsub('_','/',ld)
   files <- Sys.glob(sprintf('%s/%s/Scored/*/fs_*xls',taskdir,ld))
   files <- files[!grepl('OLD',files,ignore.case = T)]
   if(length(files)>nruns) files <- files[!grepl('fs_[^0-9]',files,ignore.case = T)]
   return(files)
}
# read in the final score ('fs') spread sheet
# expect 9 rows:
#  score lat1 lat2 lat3 valence     score.val trial      score.ec lat.ec
# but if no errors were made or none correctd, the last column (8, lat.ec) will not exist
readfs <- function(f) { 
    fn=basename(f)
    d<-read.xls(f,sheet=2,header=F)

    # if we never had an error correct, the last column will never be populated
    if(ncol(d) == 8) d[,9] <- NA

    if(nrow(d) < 0 || ncol(d) != 9) warning(f, ' has too few rows or columns! ',nrow(d), ' and ', ncol(d))

    return(d%>%mutate(run=fn) )
}

# merge all the final manually scored sheets together (long)
readallfseye<- function(ld,taskdir,nruns) {
   files<-subjfiles(ld,taskdir,nruns)
   d <- lapply(files, readfs) %>%
        bind_rows %>%
        `names<-`(c('score','lat1','lat2','lat3','valence','score.val','trial','score.ec','lat.ec','run'))
   return(d)
}

## cleanup eye data files
# errors for 10892_20120111 10893_20111111 10894_20111117 10901_20111206 10911_20120109
cleaneye <- function(ld,taskdir,nruns) {
   ## get and process score
   eyed <-  readallfseye(ld,taskdir,nruns)
   eyed.m <-
      eyed %>% 
      select(trial,score.ec,lat1,run) %>%
      separate(score.ec,c('val','score'),'_') %>%
      # look for run (but r might be lower or upper)
      mutate(block=as.numeric(gsub('.*un(\\d).*','\\1',run)))
}

getautoscore <- function(ld,taskdir,nruns){
# read in from autoscorer and match cleaneye function output
 # FROM:
 #  trial  xdat lat fstCorrect ErrCorr AS Count
 #  1     1 60133 513       TRUE   FALSE AS     1
 # TO:
 #  trial   val     score   lat1    run     block
 #  1       PosAS   drop    NA      fs_10903_cogemosounds_run1.xls  1

 files <- Sys.glob(file.path(taskdir,gsub("_","/",ld),'Scored','txt','*.trial.txt'))
 if(length(files) != nruns) stop('wrong number of run files for ', ld, ' (',length(files),')')

 # get df
 l <- lapply(files,function(x){read.table(x,sep="\t",header=T) %>% mutate(run=basename(x))})
 d<-Reduce(rbind,l)
 # rename
 d %>%
  select(trial,val=AS,score=Count,lat1=lat,run) %>% 
  mutate(score=factor(score,levels=c(-1:2),labels=c('drop','error','correct','errorCorrected')),
         block=cumsum(!duplicated(run))
        )

}

getallscores <- function(all.ld,stimdir,taskdir,nruns,scorefunc=cleaneye) {
  # go through each lunadate
  # run scorefunc and save output
  outdir=sprintf("%s/score",stimdir)
  if(!dir.exists(outdir)) dir.create(outdir)
  for (ld in all.ld){
    outfile<-sprintf('%s/%s_score.txt',outdir,ld)
    if(file.exists(outfile)) next
    m<-tryCatch(scorefunc(ld,taskdir,nruns),error=function(e){warning(ld,e,'args: ',paste(sep=", ",taskdir,nruns,stimdir));return()})
    if(length(m)<2L) {warning(ld,' failed');next}
    write.table(m,outfile,row.names=F,quote=F,sep="\t")
  }
}



## merge score (manual score fs_*xls (cleaneye) OR manual score (getautoscore); files made by getallscores)  with timing (from 01_parseEP.bash)
mergeScoreTime <- function(ld,stimdir='stim') {
   ## get and process score
   eyefile <- sprintf('%s/score/%s_score.txt',stimdir,ld) 
   if(! file.exists(eyefile) ) { warning('missing ',eyefile); return() }

   eyed.m <-  read.table(eyefile,sep="\t",header=T,quote="")

   ## get time
   timefile <- sprintf('%s/wide/%s_wide.txt',stimdir,ld) 
   if(! file.exists(timefile) ) { warning('missing ',timefile); return() }

   d.time <- read.table(timefile,sep="\t",header=T,quote="")

   d <- merge(d.time,eyed.m, by=c('trial','block')) %>% arrange(subj,block,trial)
   return(d)
}
