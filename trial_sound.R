#!/usr/bin/env Rscript

# 20180516 -- add sound to 

library(reshape2)
library(tidyr)
library(dplyr)

## get datasets

# add lunaid as id to ars_val txt files
readsnd <- function(x) {
   id <- basename(x) %>% gsub(".txt", "", .)
   read.table(x) %>%
   mutate(id=id)
}
# rbind all ars_vals together (with id in dataframe)
snd <- Sys.glob("stim/ars_val/*.txt") %>%
      lapply(readsnd) %>%
      bind_rows

# dont die if one of these doesn't read in
readwide <- function(x, ...){
   tryCatch(read.csv(x, ...), error=function(e) NULL)
}
# read in all wide_score (has lat, type, and score for each trial)
wide <-
   Sys.glob("stim/wide_score/1*_2*_score.txt") %>%
   lapply(readwide, sep="\t", quote="") %>%
   bind_rows %>%
   select(trial, block, subj,
          datetime, val, score, lat=lat1, Sound=SoundStim_note) %>%
   mutate(Sound=gsub(" ", "", Sound))


# get age and sex for all mulitmodal
# later limit to only first age -- because we only care about MMY1
mr_age <- LNCDR::db_query("
  select
   * -- id, sex, age, vtimestamp
  from visit
  natural join visit_study
  natural join person
  natural join enroll
  where
   etype like 'LunaID'
   and study ilike 'MEGEmo'
   and vtype like '%Scan%'
")

wide_age_snd <-
   mr_age %>%
   select(id, sex, age, vtimestamp) %>%
   arrange(vtimestamp) %>%
   group_by(id) %>%
   summarize_all(first) %>%
   merge(wide, by.x="id", by.y="subj", all.y=T) %>%
   merge(snd, by=c("id", "Sound"), all=T) %>%
   arrange(id, block, trial)

write.csv(wide_age_snd, "../trial_lat_valence.csv")
# merge valence and arrousal
# need trial <-> sound lookup

quit("n") # quit and dont save

## uncessary
lat <- read.csv("/Volumes/L/bea_res/Personal/Orma/CogEmo Project/latency.csv") %>%
   group_by(LunaID) %>%
   mutate(Run=1:n()) %>%
   select(-X) %>%
   ungroup

lat.long <-
   lat %>%
   # make dataframe really long -- 4 columns
   # LunaID, Run, v (Trail1...,Lat1...), value (e.g NegAS_correct)
   melt(id.vars=c("LunaID", "Run"), variable.name="v") %>%
   # add a dot to delm thing and number: Trial14=>Trial.14, Lat1=>Lat.1
   # Trial is really 2 things: Type and accuracy so call it that
   # (NegAS, NeuAS, PosAS, SilAS  + correct, errorCorrected, error, drop)
   mutate(v=gsub("(\\d+)$", ".\\1", v),
          v=gsub("Trial", "TypeAcc", v)) %>%
   # sep e.g. Lat.1 into var=Lat, Trial=1
   separate(v, c("var", "Trial")) %>%
   # go from very long into slightly wider
   #  columns for Lat and TypeACC)
   spread(var, value) %>%
   # make numeric things numbers
   mutate_at(vars(Run, Trial, Lat), as.numeric) %>%
   # TypeAcc into two columns Type and Acc
   separate(TypeAcc, c("Type", "Acc")) %>%
   arrange(LunaID, Run, Trial)
####

