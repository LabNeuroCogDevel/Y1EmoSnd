library(readxl)
arousal <- read_xlsx('../AllCogEmoRatings_090817.xlsx','Edited_TaskOnly_Arousal')
valence <- read_xlsx('../AllCogEmoRatings_090817.xlsx','Edited_TaskOnly_Valence')

# pick a random person to get all the sounds: filename, description
# like "820.wav	funk music"
cmd <- "egrep -i 'word:|wav' /Volumes/L/bea_res/Data/Tasks/CogEmoSoundsBasic/10954/20120317/Raw/EPrime/CogEmo4_ER_D_Run*_unix.txt|
 cut -d: -f2- |
 perl -ne 'print qq($1) if m/: *(.*)/; print $.%2==0?qq(\n):qq(\t)'|
 sort|
 uniq"
sndname <- read.table(
   text=system(cmd,intern=T), # capture output of command as dataframe
   sep="\t", # use tab, not space (desc have spaces)
   quote="", # some descriptions have apostrophe -- its not a quote
   colClasses='character') # columns are char not factors)
names(sndname) <- c('Sound','Name')
# bird wave file has different names, standarize on daz.wav
sndname$Sound[grepl('.*daz.wav',sndname$Sound)] <- 'daz.wav'

add_sil_and_rename <- function(d,s,neutval=5) {
 # actual name of df as pasted to thsi function will be
 # the column name for rating value
 ratetype <- as.character(substitute(d))
 d <- d[,c('Sound',s)] # get just the subject we care about
 # set names
 names(d)[2] <- ratetype
 # add zscore
 ratings <- d[,2][[1]]
 zcolname <- paste0(ratetype,'.z')
 d[,zcolname] <- LNCDR::zscore(ratings)
 # add silent 
 # NOTE: zscore value and neutval might not work together
 #   should maybe set neutval=mean(d[,2])
 d <- rbind(d,c('sil.wav',neutval,0)) # add sil
 return(d)
}

# file per subject rating arousal, valance
subjs <- unique(names(valence)[-c(1:2)], names(arousal)[-c(1:2)])
for(s in subjs) {
  thisval <- add_sil_and_rename(valence,s)
  thisars <- add_sil_and_rename(arousal,s)
  valmrg <- merge(sndname,thisval,by='Sound')
  allmrg <- merge(valmrg,thisars)
  write.table(allmrg,file=sprintf('stim/ars_val/%s.txt',s))
}

