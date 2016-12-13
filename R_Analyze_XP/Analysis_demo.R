##### Analyse statistiques des Résultats expérimentaux OTree ####
####################################################
#### Selles Jules ##### 
#### V.1          #####
#### 12/16        #####
##--------------------------------------------------

## Path

dir.data           <- "C:/Users/jselles/Dropbox/These/These_Ifremer/Documents_Travail/Modele_XP/"
dir.script         <- "Xp_protocole/R_scripts/" 
dir.xp             <- "demo_data/"

do.save=TRUE

## Packages/functions 

library(gridExtra)
library(grid)
library(ggplot2)
library(lattice)
require(reshape2)


## get Profit, schaefer etc. functions 
source(paste(dir.data,dir.script,"Xp_calculus.R",sep=""))

## get AERME data frame 
source(paste(dir.data,dir.script,"Get_Raw_Data_demoAERME.R",sep=""))

## save plot 
do.save=TRUE
path.fig= paste(dir.data,dir.xp,sep="")


##---------------------
##---------------------
## GEE analysis 

## variables d'intéret deviation optimum // efficacité globale  // sous et sur exploitation


##################################"""
## data frame by treatment & phase
AERME_XP=NULL
AERME_XP=as.data.frame(nb_xp[[1]])

for (i in 2 : 6){
  AERME_XP=rbind(AERME_XP,as.data.frame(nb_xp[[i]]))
  
}

XP_T0_p1 = AERME_XP[c(which(AERME_XP$treatment=='T0'),which(AERME_XP$phase=='p1')),]
XP_T0_p2 = AERME_XP[c(which(AERME_XP$treatment=='T0'),which(AERME_XP$phase=='p2')),]
XP_T1_p1 = AERME_XP[c(which(AERME_XP$treatment=='T1'),which(AERME_XP$phase=='p1')),]
XP_T1_p2 = AERME_XP[c(which(AERME_XP$treatment=='T1'),which(AERME_XP$phase=='p2')),]
XP_T2_p1 = AERME_XP[c(which(AERME_XP$treatment=='T1'),which(AERME_XP$phase=='p1')),]
XP_T2_p2 = AERME_XP[c(which(AERME_XP$treatment=='T2'),which(AERME_XP$phase=='p2')),]

XP_T0 = AERME_XP[which(AERME_XP$treatment=='T0'),]
XP_T1 = AERME_XP[which(AERME_XP$treatment=='T1'),]
XP_T2 = AERME_XP[which(AERME_XP$treatment=='T2'),]


XP_p1 = AERME_XP[which(AERME_XP$phase=='p1'),]
XP_p2 = AERME_XP[which(AERME_XP$phase=='p2'),]



############################################
## plot by treatment 

nb_xp=list(XP_T0=XP_T0,XP_T1=XP_T1,XP_T2=XP_T2)

for (i in 1 : 3){
##---------------------
## rearrange to plot with ggplot 
gg=melt(nb_xp[[i]],id=c('participant_roundnumber','participant_id','participant_code','participant_appname',
                        'session_code','player_name', 'player_age', 'player_profession'))



}






