#
#Author: Orma Ravindranath
#Title: Combine_StimCols.R
#Purpose: To combine the column of antisaccade onsets with the column of VGS onsets in the wide_score document for 
#the saccade localizer data
#
args <- commandArgs(trailingOnly = FALSE)
#infile <- args[1]
#df <- read.delim(infile, header = TRUE, sep = "\t")
print(args[1])
print(args[2])
df <- read.delim(args[1], header = TRUE, sep = "\t")
anti <- df$antifix1_OnsetTime
vgs <- df$vgsfix_OnsetTime
anti <- as.numeric(anti)
vgs <- as.numeric(vgs)
stim <- anti + vgs
#outfile <- args[2]
write.table(stim, file = paste("/Volumes/Zeus/MMY1_EmoSnd/scripts/timing/stim_sacloc/wide_score/",
                               args[2]), row.names = FALSE)



