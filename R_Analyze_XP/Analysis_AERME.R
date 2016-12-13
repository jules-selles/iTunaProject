##### Analyse statistiques des Résultats expérimentaux OTree ####
####################################################
#### Selles Jules ##### 
#### V.1          #####
#### 12/16        #####
##--------------------------------------------------

## Path

dir.data           <- "C:/Users/jselles/Dropbox/These/These_Ifremer/Documents_Travail/Modele_XP/"
dir.script         <- "Xp_protocole/R_scripts/"
dir.xp             <- "AERME_Test_Session/"

## Packages/functions 

library(gridExtra)
library(grid)
library(ggplot2)
library(lattice)
require(reshape2)


## get Profit, schaefer etc. functions 
source(paste(dir.data,dir.script,"Xp_calculus.R",sep=""))

## get AERME data frame 
source(paste(dir.data,dir.script,"Get_Raw_Data_AERME.R",sep=""))



## save plot 
do.save=TRUE
path.fig= paste(dir.data,dir.xp,"Resultats/",sep="")


##################################"""
## data frame by treatment & phase

XP_T0_p1 = AERME_XP[c(which(AERME_XP$treatment=='T0'),which(AERME_XP$participant_appname=='XP1p1')),]
XP_T0_p2 = AERME_XP[c(which(AERME_XP$treatment=='T0'),which(AERME_XP$participant_appname=='XP1p2')),]
XP_T1_p1 = AERME_XP[c(which(AERME_XP$treatment=='T1'),which(AERME_XP$participant_appname=='XP1p1')),]
XP_T1_p2 = AERME_XP[c(which(AERME_XP$treatment=='T1'),which(AERME_XP$participant_appname=='XP1p2')),]
XP_T2_p1 = AERME_XP[c(which(AERME_XP$treatment=='T1'),which(AERME_XP$participant_appname=='XP1p1')),]
XP_T2_p2 = AERME_XP[c(which(AERME_XP$treatment=='T2'),which(AERME_XP$participant_appname=='XP1p2')),]




