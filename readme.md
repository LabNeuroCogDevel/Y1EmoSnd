# Multimodal Year 1 Cog Emo Sounds Timing 
## 20171023 DM OR WF
Onset of `ITI9` (event after sound) relative to onset of `ITI10` (event with duration tht is the first 8 second wait) is trial relative to run start.

Varified using
```
bea_res/Data/Tasks/CogEmoSoundsBasic/10370/20120918/Raw/EPrime/CogEmo4_ER_A_Run1-10370-1.txt
timing/stim/wide_score/10370_20120918_score.txt
```

see also
```R
d <- read.table('/Volumes/Zeus/MMY1_EmoSnd/scripts/timing/stim/wide_score/10370_20120918_score.txt',sep="\t",header=T,quote="")
d$ITI9_OnsetTime
```

# Multimodal Year 1 Saccade Localizer
## score eyetracking
```
ssh arnold
cd ~/src/autoeyescor
./runme.bash -t sacloc
```
## 20171221 
`starttrialeventpart=0fixation1OnsetTime` -- unverified start time
output in `stim_sacloc/`, reuse `parseEP.*` and `readscores.R` (updated to support different stim folders)

