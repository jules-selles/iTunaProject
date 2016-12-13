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


##---------------------
##---------------------
## GEE analysis 

## variables d'intéret deviation optimum // efficacité globale  // sous et sur exploitation








############################################
## plot by treatment 

nb_xp=list(XP_T0=XP_T0,XP_T1=XP_T1,XP_T2=XP_T2)


## mean decision  by round for all phase

for (i in 1 : 3){
  
  nb_xp[[i]]$meancatch_T=NA
  nb_xp[[i]]$meancatchpledge_T=NA
  nb_xp[[i]]$meanprofit_T=NA
  nb_xp[[i]]$sdcatch_T=NA
  nb_xp[[i]]$sdcatchpledge_T=NA
  nb_xp[[i]]$sdprofit_T=NA
  nb_xp[[i]]$meanTotalcatch_T=NA
  nb_xp[[i]]$meanTotalprofit_T=NA
  nb_xp[[i]]$sdTotalcatch_T=NA
  nb_xp[[i]]$sdTotalprofit_T=NA
  
  nb_xp[[i]]$meanoptProfDev_T=NA
  nb_xp[[i]]$sdoptProfDev_T=NA
  
  nb_xp[[i]]$meanstateExploitation_T=NA
  nb_xp[[i]]$sdstateExploitation_T=NA

  nb_xp[[i]]$meanbiomass_T=NA
  nb_xp[[i]]$sdbiomass_T=NA
  
  for (j in 1: length(nb_xp[[i]]$player_profit)){
    
    nb_xp[[i]]$meancatch_T[which(nb_xp[[i]]$subsession_round==nb_xp[[i]]$subsession_round[j])] = mean(nb_xp[[i]]$player_catchchoice[which(nb_xp[[i]]$subsession_round==nb_xp[[i]]$subsession_round[j])],na.rm=TRUE)
    nb_xp[[i]]$meancatchpledge_T[which(nb_xp[[i]]$subsession_round==nb_xp[[i]]$subsession_round[j])] = mean(nb_xp[[i]]$player_catchpledge[which(nb_xp[[i]]$subsession_round==nb_xp[[i]]$subsession_round[j])],na.rm=TRUE)
    nb_xp[[i]]$meanprofit_T[which(nb_xp[[i]]$subsession_round==nb_xp[[i]]$subsession_round[j])] = mean(nb_xp[[i]]$player_profit[which(nb_xp[[i]]$subsession_round==nb_xp[[i]]$subsession_round[j])],na.rm=TRUE)
    
    nb_xp[[i]]$sdcatch_T[which(nb_xp[[i]]$subsession_round==nb_xp[[i]]$subsession_round[j])] = sd(nb_xp[[i]]$player_catchchoice[which(nb_xp[[i]]$subsession_round==nb_xp[[i]]$subsession_round[j])],na.rm=TRUE)
    nb_xp[[i]]$sdcatchpledge_T[which(nb_xp[[i]]$subsession_round==nb_xp[[i]]$subsession_round[j])] = sd(nb_xp[[i]]$player_catchpledge[which(nb_xp[[i]]$subsession_round==nb_xp[[i]]$subsession_round[j])],na.rm=TRUE)
    nb_xp[[i]]$sdprofit_T[which(nb_xp[[i]]$subsession_round==nb_xp[[i]]$subsession_round[j])] = sd(nb_xp[[i]]$player_profit[which(nb_xp[[i]]$subsession_round==nb_xp[[i]]$subsession_round[j])],na.rm=TRUE)
    
    nb_xp[[i]]$meanTotalcatch_T[which(nb_xp[[i]]$subsession_round==nb_xp[[i]]$subsession_round[j])] = mean(nb_xp[[i]]$group_totalcatch[which(nb_xp[[i]]$subsession_round==nb_xp[[i]]$subsession_round[j])],na.rm=TRUE)
    nb_xp[[i]]$meanTotalprofit_T[which(nb_xp[[i]]$subsession_round==nb_xp[[i]]$subsession_round[j])] = mean(nb_xp[[i]]$group_totalprofit[which(nb_xp[[i]]$subsession_round==nb_xp[[i]]$subsession_round[j])],na.rm=TRUE)
    
    nb_xp[[i]]$sdTotalcatch_T[which(nb_xp[[i]]$subsession_round==nb_xp[[i]]$subsession_round[j])] = sd(nb_xp[[i]]$group_totalcatch[which(nb_xp[[i]]$subsession_round==nb_xp[[i]]$subsession_round[j])],na.rm=TRUE)
    nb_xp[[i]]$sdTotalprofit_T[which(nb_xp[[i]]$subsession_round==nb_xp[[i]]$subsession_round[j])] = sd(nb_xp[[i]]$group_totalprofit[which(nb_xp[[i]]$subsession_round==nb_xp[[i]]$subsession_round[j])],na.rm=TRUE)
    
    
    nb_xp[[i]]$meanoptProfDev_T[which(nb_xp[[i]]$subsession_round==nb_xp[[i]]$subsession_round[j])] = mean(nb_xp[[i]]$group_optProfDev[which(nb_xp[[i]]$subsession_round==nb_xp[[i]]$subsession_round[j])],na.rm=TRUE)
    nb_xp[[i]]$meanstateExploitation_T[which(nb_xp[[i]]$subsession_round==nb_xp[[i]]$subsession_round[j])] = mean(nb_xp[[i]]$group_stateExploitation[which(nb_xp[[i]]$subsession_round==nb_xp[[i]]$subsession_round[j])],na.rm=TRUE)
    
    nb_xp[[i]]$sdoptProfDev_T[which(nb_xp[[i]]$subsession_round==nb_xp[[i]]$subsession_round[j])] = sd(nb_xp[[i]]$group_optProfDev[which(nb_xp[[i]]$subsession_round==nb_xp[[i]]$subsession_round[j])],na.rm=TRUE)
    nb_xp[[i]]$sdstateExploitation_T[which(nb_xp[[i]]$subsession_round==nb_xp[[i]]$subsession_round[j])] = sd(nb_xp[[i]]$group_stateExploitation[which(nb_xp[[i]]$subsession_round==nb_xp[[i]]$subsession_round[j])],na.rm=TRUE)
    
    nb_xp[[i]]$meanbiomass_T[which(nb_xp[[i]]$subsession_round==nb_xp[[i]]$subsession_round[j])] = mean(nb_xp[[i]]$group_biomasse[which(nb_xp[[i]]$subsession_round==nb_xp[[i]]$subsession_round[j])],na.rm=TRUE)
    nb_xp[[i]]$sdbiomass_T[which(nb_xp[[i]]$subsession_round==nb_xp[[i]]$subsession_round[j])] = sd(nb_xp[[i]]$group_biomasse[which(nb_xp[[i]]$subsession_round==nb_xp[[i]]$subsession_round[j])],na.rm=TRUE)
    
  }

  
##---------------------
## rearrange to plot with ggplot 
gg=melt(nb_xp[[i]],id=c('participant_roundnumber','participant_id','participant_code','participant_appname',
                        'session_code','player_name', 'player_age', 'player_profession'))

## mean profit by player
  
  P_meanprofit=ggplot(gg[which(gg$variable=='meanprofit_T'),], 
                      aes(x=as.numeric(gg$value[which(gg$variable=='subsession_round')]),
                          y=as.numeric(gg$value[which(gg$variable=='meanprofit_T')])))
  
  limits <- aes(ymax = nb_xp[[i]]$meanprofit_T + nb_xp[[i]]$sdprofit_T, ymin= nb_xp[[i]]$meanprofit_T - nb_xp[[i]]$sdprofit_T)
  dodge <- position_dodge(width=0.6)
  
  
  P_meanprofit = P_meanprofit + geom_point(size=1.8) + geom_line()+  geom_errorbar(limits,position=dodge, width=0.2,size=0.8) +
    xlim(0,15)+ylim(-5,5)+
    ylab("Mean Profit (UVM)") + xlab("Round (Year)") +
    theme_classic()+ theme(legend.text = element_text(colour="black", size=10, face="bold"))+ theme(legend.position="bottom",axis.title=element_text(size=8))

## mean total profit
  
  P_meanTotalprofit=ggplot(gg[which(gg$variable=='meanTotalprofit_T'),], 
                      aes(x=as.numeric(gg$value[which(gg$variable=='subsession_round')]),
                          y=as.numeric(gg$value[which(gg$variable=='meanTotalprofit_T')])))
  
  limits <- aes(ymax = nb_xp[[i]]$meanTotalprofit_T + nb_xp[[i]]$sdTotalprofit_T, ymin= nb_xp[[i]]$meanTotalprofit_T - nb_xp[[i]]$sdTotalprofit_T)
  dodge <- position_dodge(width=0.6)
  
  
  P_meanTotalprofit = P_meanTotalprofit + geom_point(size=1.8) + geom_line()+  geom_errorbar(limits,position=dodge, width=0.2,size=0.8) +
    xlim(0,15)+ylim(-5,5)+
    ylab("Mean total Profit (UVM)") + xlab("Round (Year)") +
    theme_classic()+ theme(legend.text = element_text(colour="black", size=10, face="bold"))+ theme(legend.position="bottom",axis.title=element_text(size=8))
  
  
## mean catch by player
  
  P_meancatch=ggplot(gg[which(gg$variable=='meancatch_T'),], 
                      aes(x=as.numeric(gg$value[which(gg$variable=='subsession_round')]),
                          y=as.numeric(gg$value[which(gg$variable=='meancatch_T')])))
  
  limits <- aes(ymax = nb_xp[[i]]$meancatch_T + nb_xp[[i]]$sdcatch_T, ymin= nb_xp[[i]]$meancatch_T - nb_xp[[i]]$sdcatch_T)
  dodge <- position_dodge(width=0.6)
  
  
   P_meancatch = P_meancatch + geom_point(size=1.8) + geom_line()+  geom_errorbar(limits,position=dodge, width=0.2,size=0.8) +
    xlim(0,15)+ylim(0,15)+
    ylab("Mean Catch (UVS)") + xlab("Round (Year)") +
    theme_classic()+ theme(legend.text = element_text(colour="black", size=10, face="bold"))+ theme(legend.position="bottom",axis.title=element_text(size=8))
  
## mean total catch
   
   P_meanTotalcatch=ggplot(gg[which(gg$variable=='meanTotalcatch_T'),], 
                            aes(x=as.numeric(gg$value[which(gg$variable=='subsession_round')]),
                                y=as.numeric(gg$value[which(gg$variable=='meanTotalcatch_T')])))
   
   limits <- aes(ymax = nb_xp[[i]]$meanTotalcatch_T + nb_xp[[i]]$sdTotalcatch_T, ymin= nb_xp[[i]]$meanTotalcatch_T - nb_xp[[i]]$sdTotalcatch_T)
   dodge <- position_dodge(width=0.6)
   
   
   P_meanTotalcatch = P_meanTotalcatch + geom_point(size=1.8) + geom_line()+  geom_errorbar(limits,position=dodge, width=0.2,size=0.8) +
     xlim(0,15)+ylim(-5,15)+
     ylab("Mean total Catch (UVS)") + xlab("Round (Year)") +
     theme_classic()+ theme(legend.text = element_text(colour="black", size=10, face="bold"))+ theme(legend.position="bottom",axis.title=element_text(size=8))
   
## mean harvest/Bmsy
   
   P_meanstateExploitation = ggplot(gg[which(gg$variable=='meanstateExploitation_T'),], 
                                      aes(x=as.numeric(gg$value[which(gg$variable=='subsession_round')]),
                                          y=(as.numeric(gg$value[which(gg$variable=='meanstateExploitation_T')]))))
   
   limits <- aes(ymax = nb_xp[[i]]$meanstateExploitation_T + nb_xp[[i]]$sdstateExploitation_T, ymin= nb_xp[[i]]$meanstateExploitation_T - nb_xp[[i]]$sdstateExploitation_T)
   dodge <- position_dodge(width=0.6)
   
   P_meanstateExploitation = P_meanstateExploitation +  geom_point(size=1.8)+ geom_line() + geom_errorbar(limits,position=dodge, width=0.2,size=0.8) +
     ylab("Harvest / MSY ") + xlab("Round (Year)") +  theme_classic()+ theme(legend.text = element_text(colour="black", size=10, face="bold"))+
     theme(legend.position="bottom",axis.title=element_text(size=8))

   
## Plot mean deviation from optimal path
   
   P_meanOptprofdev = ggplot(gg[which(gg$variable=='meanoptProfDev_T'),], 
                           aes(x=factor(as.numeric(gg$value[which(gg$variable=='subsession_round')])),
                               y=(as.numeric(gg$value[which(gg$variable=='meanoptProfDev_T')]))))
   
   limits <- aes(ymax = (nb_xp[[i]]$meanoptProfDev_T + nb_xp[[i]]$sdoptProfDev_T), ymin= nb_xp[[i]]$meanoptProfDev_T - nb_xp[[i]]$sdoptProfDev_T)
   dodge <- position_dodge(width=0.6)
   
   P_meanOptprofdev = P_meanOptprofdev + geom_bar(stat = "identity", position=dodge) +geom_errorbar(limits,position=dodge, width=0.2,size=0.8) +
     ylab("Deviation from optimal profit path ") + xlab("Round (Year)") +
     theme_classic()+ theme(legend.text = element_text(colour="black", size=10, face="bold"))+ theme(legend.position="bottom",
                                                                                                     axis.title=element_text(size=8))
   
   
   ## Plot mean biomass
   
   P_meanBiomass=ggplot(gg[which(gg$variable=='meanbiomass_T'),], 
                     aes(x=as.numeric(gg$value[which(gg$variable=='subsession_round')]),
                         y=as.numeric(gg$value[which(gg$variable=='meanbiomass_T')])))
   
   limits <- aes(ymax = (nb_xp[[i]]$meanbiomass_T + nb_xp[[i]]$sdbiomass_T), ymin= nb_xp[[i]]$meanbiomass_T - nb_xp[[i]]$sdbiomass_T)
   dodge <- position_dodge(width=0.6)
   
   P_meanBiomass= P_meanBiomass + geom_point(size=1.8)+ geom_line() +geom_errorbar(limits,position=dodge, width=0.2,size=0.8) +
     ylab("Mean Biomass (UVS)") + xlab("Round (Year)") + ylim(0,30) + xlim(0,15) +
     theme_classic()+ theme(legend.text = element_text(colour="black", size=10, face="bold"))+ theme(legend.position="bottom",axis.title=element_text(size=8))
   
   ##-------------------------------------
   ##------------------------------------
   
   if (do.save==TRUE){jpeg(filename=paste(path.fig,"T",substr(names(nb_xp)[i], 5, 5),".jpg",sep=""),
                           width = 2500, height = 2500,res = 300)}
   
   grid.arrange(P_meancatch,P_meanprofit,P_meanTotalcatch, P_meanTotalprofit,
                P_meanstateExploitation, P_meanOptprofdev,P_meanBiomass,
                ncol=2, top = paste("T",substr(names(nb_xp)[i], 5, 5),sep=""))
   
   if (do.save==TRUE){dev.off()}
   
   
   ##-------------------------------------
   ##------------------------------------
   print(paste(names(nb_xp)[i],'Efficacité moyenne: ',mean(nb_xp[[i]]$group_efficiency,na.rm=T),sep=""))
   print("#--------------------------------------------------------------------------#")
   print(paste(names(nb_xp)[i],'Deviation Moyenne: ',mean(nb_xp[[i]]$meanoptProfDev_T,na.rm=T),sep=""))
   print("#--------------------------------------------------------------------------#")
   print("############################################################################")
   print("#--------------------------------------------------------------------------#")
   
   
   
}



############################################
## plot by phase

nb_xp=list(XP_p1=XP_p1,XP_p2=XP_p2)


## mean decision  by round for all phase

for (i in 1 : 2){
  
  nb_xp[[i]]$meancatch_T=NA
  nb_xp[[i]]$meancatchpledge_T=NA
  nb_xp[[i]]$meanprofit_T=NA
  nb_xp[[i]]$sdcatch_T=NA
  nb_xp[[i]]$sdcatchpledge_T=NA
  nb_xp[[i]]$sdprofit_T=NA
  nb_xp[[i]]$meanTotalcatch_T=NA
  nb_xp[[i]]$meanTotalprofit_T=NA
  nb_xp[[i]]$sdTotalcatch_T=NA
  nb_xp[[i]]$sdTotalprofit_T=NA
  
  nb_xp[[i]]$meanoptProfDev_T=NA
  nb_xp[[i]]$sdoptProfDev_T=NA
  
  nb_xp[[i]]$meanstateExploitation_T=NA
  nb_xp[[i]]$sdstateExploitation_T=NA
  
  nb_xp[[i]]$meanbiomass_T=NA
  nb_xp[[i]]$sdbiomass_T=NA
  
  for (j in 1: length(nb_xp[[i]]$player_profit)){
    
    nb_xp[[i]]$meancatch_T[which(nb_xp[[i]]$subsession_round==nb_xp[[i]]$subsession_round[j])] = mean(nb_xp[[i]]$player_catchchoice[which(nb_xp[[i]]$subsession_round==nb_xp[[i]]$subsession_round[j])],na.rm=TRUE)
    nb_xp[[i]]$meancatchpledge_T[which(nb_xp[[i]]$subsession_round==nb_xp[[i]]$subsession_round[j])] = mean(nb_xp[[i]]$player_catchpledge[which(nb_xp[[i]]$subsession_round==nb_xp[[i]]$subsession_round[j])],na.rm=TRUE)
    nb_xp[[i]]$meanprofit_T[which(nb_xp[[i]]$subsession_round==nb_xp[[i]]$subsession_round[j])] = mean(nb_xp[[i]]$player_profit[which(nb_xp[[i]]$subsession_round==nb_xp[[i]]$subsession_round[j])],na.rm=TRUE)
    
    nb_xp[[i]]$sdcatch_T[which(nb_xp[[i]]$subsession_round==nb_xp[[i]]$subsession_round[j])] = sd(nb_xp[[i]]$player_catchchoice[which(nb_xp[[i]]$subsession_round==nb_xp[[i]]$subsession_round[j])],na.rm=TRUE)
    nb_xp[[i]]$sdcatchpledge_T[which(nb_xp[[i]]$subsession_round==nb_xp[[i]]$subsession_round[j])] = sd(nb_xp[[i]]$player_catchpledge[which(nb_xp[[i]]$subsession_round==nb_xp[[i]]$subsession_round[j])],na.rm=TRUE)
    nb_xp[[i]]$sdprofit_T[which(nb_xp[[i]]$subsession_round==nb_xp[[i]]$subsession_round[j])] = sd(nb_xp[[i]]$player_profit[which(nb_xp[[i]]$subsession_round==nb_xp[[i]]$subsession_round[j])],na.rm=TRUE)
    
    nb_xp[[i]]$meanTotalcatch_T[which(nb_xp[[i]]$subsession_round==nb_xp[[i]]$subsession_round[j])] = mean(nb_xp[[i]]$group_totalcatch[which(nb_xp[[i]]$subsession_round==nb_xp[[i]]$subsession_round[j])],na.rm=TRUE)
    nb_xp[[i]]$meanTotalprofit_T[which(nb_xp[[i]]$subsession_round==nb_xp[[i]]$subsession_round[j])] = mean(nb_xp[[i]]$group_totalprofit[which(nb_xp[[i]]$subsession_round==nb_xp[[i]]$subsession_round[j])],na.rm=TRUE)
    
    nb_xp[[i]]$sdTotalcatch_T[which(nb_xp[[i]]$subsession_round==nb_xp[[i]]$subsession_round[j])] = sd(nb_xp[[i]]$group_totalcatch[which(nb_xp[[i]]$subsession_round==nb_xp[[i]]$subsession_round[j])],na.rm=TRUE)
    nb_xp[[i]]$sdTotalprofit_T[which(nb_xp[[i]]$subsession_round==nb_xp[[i]]$subsession_round[j])] = sd(nb_xp[[i]]$group_totalprofit[which(nb_xp[[i]]$subsession_round==nb_xp[[i]]$subsession_round[j])],na.rm=TRUE)
    
    
    nb_xp[[i]]$meanoptProfDev_T[which(nb_xp[[i]]$subsession_round==nb_xp[[i]]$subsession_round[j])] = mean(nb_xp[[i]]$group_optProfDev[which(nb_xp[[i]]$subsession_round==nb_xp[[i]]$subsession_round[j])],na.rm=TRUE)
    nb_xp[[i]]$meanstateExploitation_T[which(nb_xp[[i]]$subsession_round==nb_xp[[i]]$subsession_round[j])] = mean(nb_xp[[i]]$group_stateExploitation[which(nb_xp[[i]]$subsession_round==nb_xp[[i]]$subsession_round[j])],na.rm=TRUE)
    
    nb_xp[[i]]$sdoptProfDev_T[which(nb_xp[[i]]$subsession_round==nb_xp[[i]]$subsession_round[j])] = sd(nb_xp[[i]]$group_optProfDev[which(nb_xp[[i]]$subsession_round==nb_xp[[i]]$subsession_round[j])],na.rm=TRUE)
    nb_xp[[i]]$sdstateExploitation_T[which(nb_xp[[i]]$subsession_round==nb_xp[[i]]$subsession_round[j])] = sd(nb_xp[[i]]$group_stateExploitation[which(nb_xp[[i]]$subsession_round==nb_xp[[i]]$subsession_round[j])],na.rm=TRUE)
    
    nb_xp[[i]]$meanbiomass_T[which(nb_xp[[i]]$subsession_round==nb_xp[[i]]$subsession_round[j])] = mean(nb_xp[[i]]$group_biomasse[which(nb_xp[[i]]$subsession_round==nb_xp[[i]]$subsession_round[j])],na.rm=TRUE)
    nb_xp[[i]]$sdbiomass_T[which(nb_xp[[i]]$subsession_round==nb_xp[[i]]$subsession_round[j])] = sd(nb_xp[[i]]$group_biomasse[which(nb_xp[[i]]$subsession_round==nb_xp[[i]]$subsession_round[j])],na.rm=TRUE)
    
  }
  
  
  ##---------------------
  ## rearrange to plot with ggplot 
  gg=melt(nb_xp[[i]],id=c('participant_roundnumber','participant_id','participant_code','participant_appname',
                          'session_code','player_name', 'player_age', 'player_profession'))
  
  ## mean profit by player
  
  P_meanprofit=ggplot(gg[which(gg$variable=='meanprofit_T'),], 
                      aes(x=as.numeric(gg$value[which(gg$variable=='subsession_round')]),
                          y=as.numeric(gg$value[which(gg$variable=='meanprofit_T')])))
  
  limits <- aes(ymax = nb_xp[[i]]$meanprofit_T + nb_xp[[i]]$sdprofit_T, ymin= nb_xp[[i]]$meanprofit_T - nb_xp[[i]]$sdprofit_T)
  dodge <- position_dodge(width=0.6)
  
  
  P_meanprofit = P_meanprofit + geom_point(size=1.8) + geom_line()+  geom_errorbar(limits,position=dodge, width=0.2,size=0.8) +
    xlim(0,15)+ylim(-5,5)+
    ylab("Mean Profit (UVM)") + xlab("Round (Year)") +
    theme_classic()+ theme(legend.text = element_text(colour="black", size=10, face="bold"))+ theme(legend.position="bottom",axis.title=element_text(size=8))
  
  ## mean total profit
  
  P_meanTotalprofit=ggplot(gg[which(gg$variable=='meanTotalprofit_T'),], 
                           aes(x=as.numeric(gg$value[which(gg$variable=='subsession_round')]),
                               y=as.numeric(gg$value[which(gg$variable=='meanTotalprofit_T')])))
  
  limits <- aes(ymax = nb_xp[[i]]$meanTotalprofit_T + nb_xp[[i]]$sdTotalprofit_T, ymin= nb_xp[[i]]$meanTotalprofit_T - nb_xp[[i]]$sdTotalprofit_T)
  dodge <- position_dodge(width=0.6)
  
  
  P_meanTotalprofit = P_meanTotalprofit + geom_point(size=1.8) + geom_line()+  geom_errorbar(limits,position=dodge, width=0.2,size=0.8) +
    xlim(0,15)+ylim(-5,5)+
    ylab("Mean total Profit (UVM)") + xlab("Round (Year)") +
    theme_classic()+ theme(legend.text = element_text(colour="black", size=10, face="bold"))+ theme(legend.position="bottom",axis.title=element_text(size=8))
  
  
  ## mean catch by player
  
  P_meancatch=ggplot(gg[which(gg$variable=='meancatch_T'),], 
                     aes(x=as.numeric(gg$value[which(gg$variable=='subsession_round')]),
                         y=as.numeric(gg$value[which(gg$variable=='meancatch_T')])))
  
  limits <- aes(ymax = nb_xp[[i]]$meancatch_T + nb_xp[[i]]$sdcatch_T, ymin= nb_xp[[i]]$meancatch_T - nb_xp[[i]]$sdcatch_T)
  dodge <- position_dodge(width=0.6)
  
  
  P_meancatch = P_meancatch + geom_point(size=1.8) + geom_line()+  geom_errorbar(limits,position=dodge, width=0.2,size=0.8) +
    xlim(0,15)+ylim(0,15)+
    ylab("Mean Catch (UVS)") + xlab("Round (Year)") +
    theme_classic()+ theme(legend.text = element_text(colour="black", size=10, face="bold"))+ theme(legend.position="bottom",axis.title=element_text(size=8))
  
  ## mean total catch
  
  P_meanTotalcatch=ggplot(gg[which(gg$variable=='meanTotalcatch_T'),], 
                          aes(x=as.numeric(gg$value[which(gg$variable=='subsession_round')]),
                              y=as.numeric(gg$value[which(gg$variable=='meanTotalcatch_T')])))
  
  limits <- aes(ymax = nb_xp[[i]]$meanTotalcatch_T + nb_xp[[i]]$sdTotalcatch_T, ymin= nb_xp[[i]]$meanTotalcatch_T - nb_xp[[i]]$sdTotalcatch_T)
  dodge <- position_dodge(width=0.6)
  
  
  P_meanTotalcatch = P_meanTotalcatch + geom_point(size=1.8) + geom_line()+  geom_errorbar(limits,position=dodge, width=0.2,size=0.8) +
    xlim(0,15)+ylim(-5,15)+
    ylab("Mean total Catch (UVS)") + xlab("Round (Year)") +
    theme_classic()+ theme(legend.text = element_text(colour="black", size=10, face="bold"))+ theme(legend.position="bottom",axis.title=element_text(size=8))
  
  ## mean harvest/Bmsy
  
  P_meanstateExploitation = ggplot(gg[which(gg$variable=='meanstateExploitation_T'),], 
                                   aes(x=as.numeric(gg$value[which(gg$variable=='subsession_round')]),
                                       y=(as.numeric(gg$value[which(gg$variable=='meanstateExploitation_T')]))))
  
  limits <- aes(ymax = nb_xp[[i]]$meanstateExploitation_T + nb_xp[[i]]$sdstateExploitation_T, ymin= nb_xp[[i]]$meanstateExploitation_T - nb_xp[[i]]$sdstateExploitation_T)
  dodge <- position_dodge(width=0.6)
  
  P_meanstateExploitation = P_meanstateExploitation +  geom_point(size=1.8)+ geom_line() + geom_errorbar(limits,position=dodge, width=0.2,size=0.8) +
    ylab("Harvest / MSY ") + xlab("Round (Year)") +  theme_classic()+ theme(legend.text = element_text(colour="black", size=10, face="bold"))+
    theme(legend.position="bottom",axis.title=element_text(size=8))
  
  
  ## Plot mean deviation from optimal path
  
  P_meanOptprofdev = ggplot(gg[which(gg$variable=='meanoptProfDev_T'),], 
                            aes(x=factor(as.numeric(gg$value[which(gg$variable=='subsession_round')])),
                                y=(as.numeric(gg$value[which(gg$variable=='meanoptProfDev_T')]))))
  
  limits <- aes(ymax = (nb_xp[[i]]$meanoptProfDev_T + nb_xp[[i]]$sdoptProfDev_T), ymin= nb_xp[[i]]$meanoptProfDev_T - nb_xp[[i]]$sdoptProfDev_T)
  dodge <- position_dodge(width=0.6)
  
  P_meanOptprofdev = P_meanOptprofdev + geom_bar(stat = "identity", position=dodge) +geom_errorbar(limits,position=dodge, width=0.2,size=0.8) +
    ylab("Deviation from optimal profit path ") + xlab("Round (Year)") +
    theme_classic()+ theme(legend.text = element_text(colour="black", size=10, face="bold"))+ theme(legend.position="bottom",
                                                                                                    axis.title=element_text(size=8))
  
  
  ## Plot mean biomass
  
  P_meanBiomass=ggplot(gg[which(gg$variable=='meanbiomass_T'),], 
                       aes(x=as.numeric(gg$value[which(gg$variable=='subsession_round')]),
                           y=as.numeric(gg$value[which(gg$variable=='meanbiomass_T')])))
  
  limits <- aes(ymax = (nb_xp[[i]]$meanbiomass_T + nb_xp[[i]]$sdbiomass_T), ymin= nb_xp[[i]]$meanbiomass_T - nb_xp[[i]]$sdbiomass_T)
  dodge <- position_dodge(width=0.6)
  
  P_meanBiomass= P_meanBiomass + geom_point(size=1.8)+ geom_line() +geom_errorbar(limits,position=dodge, width=0.2,size=0.8) +
    ylab("Biomass (UVS)") + xlab("Round (Year)") + ylim(0,30) + xlim(0,15) +
    theme_classic()+ theme(legend.text = element_text(colour="black", size=10, face="bold"))+ theme(legend.position="bottom",axis.title=element_text(size=8))
  
  ##-------------------------------------
  ##------------------------------------
  
  if (do.save==TRUE){jpeg(filename=paste(path.fig,"Phase",substr(names(nb_xp)[i], 5, 5),".jpg",sep=""),
                          width = 2500, height = 2500,res = 300)}
  
  grid.arrange(P_meancatch,P_meanprofit,P_meanTotalcatch, P_meanTotalprofit,
               P_meanstateExploitation, P_meanOptprofdev,P_meanBiomass,
               ncol=2, top = paste("Phase",substr(names(nb_xp)[i], 5, 5),sep=""))
  
  if (do.save==TRUE){dev.off()}
  
  
  ##-------------------------------------
  ##------------------------------------
  print(paste(names(nb_xp)[i],'Efficacité moyenne: ',mean(nb_xp[[i]]$group_efficiency,na.rm=T),sep=""))
  print("#--------------------------------------------------------------------------#")
  print(paste(names(nb_xp)[i],'Deviation Moyenne: ',mean(nb_xp[[i]]$meanoptProfDev_T,na.rm=T),sep=""))
  print("#--------------------------------------------------------------------------#")
  print("############################################################################")
  print("#--------------------------------------------------------------------------#")
  
  
  
}













