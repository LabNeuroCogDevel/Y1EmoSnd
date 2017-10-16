#!/usr/bin/env Rscript

library(LNCDR)
library(gdata) # read xls (not xlsx)

readfs <- function(f) { 
    fn=basename(f)
    read.xls(f,sheet=2,header=F)%>%mutate(run=fn) 
}
readallfseye<- function(ld) {
   ld <- gsub('_','/',ld)
   files <- Sys.glob(sprintf('/Volumes/B/bea_res/Data/Tasks/CogEmoSoundsBasic/%s/Scored/*/fs_*xls',ld))
   d <- lapply(files, readfs) %>%
        bind_rows %>%
        `names<-`(c('score','lat1','lat2','lat3','valence','score.val','trial','score.ec','lat.ec','run'))
   return(d)
}

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

mergeScoreTime('10370_20120918')



# only the Neg sounds
d %>%
   filter(Procedure_note == 'antiNeg', score=='errorCorrected' ) %>% 
   save1D(colname='SoundOut1_OnsetTime', dur='SoundOut1_Duration',nblocks=4)
   #file=neg_errCor_snd.1D
