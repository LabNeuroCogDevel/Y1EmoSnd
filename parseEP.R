#!/usr/bin/env Rscript

library('dplyr')
library('tidyr')
library('lubridate')
library('reshape2')

###### FUNCTIONS

# how to get date object from datetime column
astime<-function(x) mdy_hms(as.character(x))
ms2s <- function(x) as.numeric(as.character(x))/1000

##
# parseEP parses the long form output of parseEP.pl
# and creates a wide (many columns), like
#    subj,run,date, wait1_onsettime,...wati4_duration, word_note
# and numbered blocks
##
parseEP <- function(f) {
  if(! file.exists(f) ) {
     warning('bad file ',f)
     return()
  }
  # read in data, output of parseEP.pl
  d<-read.table(f,sep="\t",quote="",header=T)

  ## checks
  if( nrow(d) == 0L ) {warning('empty file',f); return() }
  if(! all( 
      sort(names(d)) == 
      c("datetime", "event", "part", "run", "subj", "trial", "value"))) {
     warning('file does not have expected header!',f)
     return()
  }
  if( length(unique(d$subj)) != 1 ){ warning('file has too many subject ids!',f); return() }
    
  # create a wider version by making "event_part" columns
  d.wide <- 
      dcast(d,
            subj+datetime+run+trial ~ event+part,
            value.var='value',
            fun.aggregate=paste0, collapse="")
  
  # number the blocks based on the session datetime
  d.block <-
   d.wide %>% 
    mutate(block=as.numeric(datetime)) %>%
    arrange(subj,astime(datetime),trial) 

 return(d.block)
}

####
# isgooddf checks the d.block dataframe created by parseEP
#  - 28 trials, 4 blocks, sequentail datetimes
#
orwarn  <- function(b,...) { if(!b){warning(...)}; return(b) }
isgooddf <- function(d.block,ntrials=28,nblocks=4) {
  if( length(d.block) <= 0L ) {
     warning('empty input')
     return(F)
  }
  # do some checks
  check <- 
     d.block %>%
     group_by(block,dt=astime(datetime)) %>% 
     summarise(n=n())
  
  sn <- getsavename(d.block)
  good <- 
   orwarn( all(check$n == ntrials ),'not all blocks have 28 trials: ',sn) &&
   orwarn( nrow(check) == nblocks  ,'not exaclty 4 blocks: ',sn) &&
   orwarn( all(diff(check$dt)  >0 ),'datetimes are not sequential: ',sn) 
  return(good)
}

getsavename <-function(d) {
   ymdstr <- d[1,'datetime'] %>% astime %>% strftime('%Y%m%d')
   ld8 <- sprintf("%s_%s",d[1,'subj'],ymdstr)
   if( ! regexpr(ld8,'^\\d{5}_\\d{8}$',ld8) ){
      warning('output does not look like lunadate8: ',ld8)
   }
   return(sprintf('%s_wide.txt',ld8))
}

###### use these functions

# what to read
args = commandArgs(trailingOnly=TRUE)
if(length(args)<0) stop("need at least one file")

for(f in args) {
  d.block <- parseEP(f)
  if( length(d.block) == 0L) next
  #if( ! isgooddf(d.block) ) next
  if(grepl('stim_sacloc',f)){
     expectNtrials <- 42
     expectNblocks <- 1
  }else{
     #grepl('stim/',f)
     expectNtrials <- 28
     expectNblocks <- 4
  }
  isgooddf(d.block,expectNtrials,expectNblocks)

  # fix some weirdness (leading space, 'AntiTaskEmo FixEnd' on last event
  d.block$Procedure_note <- gsub('^ *','',d.block$Procedure_note)
  d.block$Procedure_note <- gsub(' AntiTaskEmo.*','',d.block$Procedure_note)
  
  # take time into seconds
  d.block <- d.block %>% 
     mutate_at(vars(matches('Onset|Duration')),funs( ms2s) )

  # 'stim/wide'
  outdir <- gsub('long','wide',dirname(f))
  if(! dir.exists(outdir) ) dir.create(outdir)
  outputname <- getsavename(d.block)
  outfile=file.path(outdir,outputname)

  write.table(d.block,file=outfile,row.names=F,quote=F,sep="\t")
  print(outfile)
}

warnings()
