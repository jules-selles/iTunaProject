
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

source(paste(dir.data,dir.script,"read_Otree.R",sep=""))
source(paste(dir.data,dir.script,"makeTable_Otree.R",sep=""))

## save plot 

path.fig= paste(dir.data,dir.xp,sep="")


##--------------------------------------------------
## Read raw data
xpdemo_data=extract_Otree_data(paste(dir.data,dir.xp,sep=""),"Xp1p1_demo.csv")
xpdemo_data=as.data.frame(xpdemo_data)


#-----------------------------------------
## Make data frame with all sessions
#-----------------------------------------

##--------------------------------------------------
## Session: j6i65ra1 / Group demo / p1 T0 / Ceresa,Bazin,Feuilloley / -> BUG biomass  ~ total catch

xp_j6i65ra1 = make.table.Otree(xp.data=xpdemo_data, session="j6i65ra1", name=c("demo","demo","demo"),
                                age=c(22,22,22), profession=c("student","student","student"))
xp_j6i65ra1$treatment = 'T0'
xp_j6i65ra1$phase = 'p1'




#--------------------------------------------------------------------------------------------
## Plot by session 
#--------------------------------------------------------------------------------------------

##--------------------------------------------------
## Session: qz740agn / Group 1 / p1 T0 / Ceresa,Bazin,Feuilloley / 
##--------------------------------------------------

##---------------------
## rearrange to plot with ggplot 
ggplot_XP_j6i65ra1=melt(xp_j6i65ra1,id=c('participant_roundnumber','participant_id','participant_code','participant_appname',
                                          'session_code','player_name', 'player_age', 'player_profession'))

#-----------------
## plot 

## Plot ind catch

P_catch=ggplot(ggplot_XP_j6i65ra1[which(ggplot_XP_j6i65ra1$variable=='player_catchchoice'),], 
               aes(as.numeric(ggplot_XP_j6i65ra1$value[which(ggplot_XP_j6i65ra1$variable=='subsession_round')]),
                   as.numeric(ggplot_XP_j6i65ra1$value[which(ggplot_XP_j6i65ra1$variable=='player_catchchoice')]),
                   group=as.factor(ggplot_XP_j6i65ra1$value[which(ggplot_XP_j6i65ra1$variable=='player_id')]),
                   colour=as.factor(ggplot_XP_j6i65ra1$value[which(ggplot_XP_j6i65ra1$variable=='player_id')])))

P_catch =P_catch + geom_line()+ylim(0,15)+ xlim(0,15)+
  scale_colour_discrete(name  ="Coalitions")+
  ylab("Harvest (UVS)") + xlab("Round (Year)") +
  theme_classic()+ theme(legend.text = element_text(colour="black", size=10, face="bold"))+ theme(legend.position="bottom",
                                                                                                  axis.title=element_text(size=8))
#+ geom_vline(aes(xintercept = 0,linetype = "Nash"), show.legend=FALSE) +scale_linetype_manual(values =c( "Nash" = "dashed")) +scale_colour_manual(values = c("Nash"="black"))


## Plot ind catch pledge 

P_catchpledge=ggplot(ggplot_XP_j6i65ra1[which(ggplot_XP_j6i65ra1$variable=='player_catchpledge'),], 
                     aes(as.numeric(ggplot_XP_j6i65ra1$value[which(ggplot_XP_j6i65ra1$variable=='subsession_round')]),
                         as.numeric(ggplot_XP_j6i65ra1$value[which(ggplot_XP_j6i65ra1$variable=='player_catchpledge')]),
                         group=as.factor(ggplot_XP_j6i65ra1$value[which(ggplot_XP_j6i65ra1$variable=='player_id')]),
                         colour=as.factor(ggplot_XP_j6i65ra1$value[which(ggplot_XP_j6i65ra1$variable=='player_id')])))

P_catchpledge = P_catchpledge + geom_line()+ylim(0,15)+ xlim(0,15)+
  scale_colour_discrete(name  ="Coalitions")+
  ylab("Harvest pledge (UVS)") + xlab("Round (Year)") +
  theme_classic()+ theme(legend.text = element_text(colour="black", size=10, face="bold"))+ theme(legend.position="bottom",
                                                                                                  axis.title=element_text(size=8))
#+ geom_vline(aes(xintercept = 0,linetype = "Nash"), show.legend=FALSE) +scale_linetype_manual(values =c( "Nash" = "dashed")) +scale_colour_manual(values = c("Nash"="black"))



## Plot mean catch pledge

P_meancatchpledge=ggplot(ggplot_XP_j6i65ra1[which(ggplot_XP_j6i65ra1$variable=='group_meancatchpledge'),], 
                         aes(x=as.numeric(ggplot_XP_j6i65ra1$value[which(ggplot_XP_j6i65ra1$variable=='subsession_round')]),
                             y=as.numeric(ggplot_XP_j6i65ra1$value[which(ggplot_XP_j6i65ra1$variable=='group_meancatchpledge')])))

limits <- aes(ymax = xp_j6i65ra1$group_meancatchpledge + xp_j6i65ra1$group_sdcatchpledge, ymin= xp_j6i65ra1$group_meancatchpledge - xp_j6i65ra1$group_sdcatchpledge)
dodge <- position_dodge(width=1)

P_meancatchpledge = P_meancatchpledge + geom_line() +  geom_point(size=1.8) + geom_errorbar(limits,position=dodge, width=0.2,size=0.8)+ ylim(0,15)+ xlim(0,15)+
  ylab("Mean Harvest Pledge (UVS)") + xlab("Round (Year)") +
  theme_classic()+ theme(legend.text = element_text(colour="black", size=10, face="bold"))+ theme(legend.position="bottom",
                                                                                                  axis.title=element_text(size=8))
#+ geom_vline(aes(xintercept = 0,linetype = "Nash"), show.legend=FALSE) +scale_linetype_manual(values =c( "Nash" = "dashed")) +scale_colour_manual(values = c("Nash"="black"))


## Plot total catch

P_totalcatch=ggplot(ggplot_XP_j6i65ra1[which(ggplot_XP_j6i65ra1$variable=='group_totalcatch'),], 
                    aes(x=as.numeric(ggplot_XP_j6i65ra1$value[which(ggplot_XP_j6i65ra1$variable=='subsession_round')]),
                        y=as.numeric(ggplot_XP_j6i65ra1$value[which(ggplot_XP_j6i65ra1$variable=='group_totalcatch')])))

P_totalcatch =P_totalcatch + geom_line()+ylim(0,15)+ xlim(0,15)+
  ylab("Total Harvest (UVS)") + xlab("Round (Year)") +
  theme_classic()+ theme(legend.text = element_text(colour="black", size=10, face="bold"))+ theme(legend.position="bottom",axis.title=element_text(size=8))
#+ geom_vline(aes(xintercept = 0,linetype = "Nash"), show.legend=FALSE) +scale_linetype_manual(values =c( "Nash" = "dashed")) +scale_colour_manual(values = c("Nash"="black"))


## Plot mean catch

P_meancatch=ggplot(ggplot_XP_j6i65ra1[which(ggplot_XP_j6i65ra1$variable=='group_meancatch'),], 
                   aes(x=as.numeric(ggplot_XP_j6i65ra1$value[which(ggplot_XP_j6i65ra1$variable=='subsession_round')]),
                       y=as.numeric(ggplot_XP_j6i65ra1$value[which(ggplot_XP_j6i65ra1$variable=='group_meancatch')])))

limits <- aes(ymax = xp_j6i65ra1$group_meancatch + xp_j6i65ra1$group_sdcatch, ymin= xp_j6i65ra1$group_meancatch - xp_j6i65ra1$group_sdcatch)
dodge <- position_dodge(width=1)


P_meancatch = P_meancatch + geom_point(size=1.8) + geom_line()+  geom_errorbar(limits,position=dodge, width=0.2,size=0.8) + ylim(0,15)+ xlim(0,15)+
  ylab("Mean Harvest (UVS)") + xlab("Round (Year)") +
  theme_classic()+ theme(legend.text = element_text(colour="black", size=10, face="bold"))+ theme(legend.position="bottom",
                                                                                                  axis.title=element_text(size=8))
#+ geom_vline(aes(xintercept = 0,linetype = "Nash"), show.legend=FALSE) +scale_linetype_manual(values =c( "Nash" = "dashed")) +scale_colour_manual(values = c("Nash"="black"))


## Plot ind profit

P_profit=ggplot(ggplot_XP_j6i65ra1[which(ggplot_XP_j6i65ra1$variable=='player_profit'),], 
                aes(x=as.numeric(ggplot_XP_j6i65ra1$value[which(ggplot_XP_j6i65ra1$variable=='subsession_round')]),
                    as.numeric(ggplot_XP_j6i65ra1$value[which(ggplot_XP_j6i65ra1$variable=='player_profit')]),
                    group=as.factor(ggplot_XP_j6i65ra1$value[which(ggplot_XP_j6i65ra1$variable=='player_id')]),
                    colour=as.factor(ggplot_XP_j6i65ra1$value[which(ggplot_XP_j6i65ra1$variable=='player_id')]),
                    fill=as.factor(ggplot_XP_j6i65ra1$value[which(ggplot_XP_j6i65ra1$variable=='player_id')])))

P_profit=P_profit + geom_line()+ylim(min(xp_j6i65ra1$player_profit,na.rm=TRUE),5)+ xlim(0,15)+
  scale_colour_discrete(name  ="Coalitions")+
  ylab("Profit (UVM)") + xlab("Round (Year)") +
  theme_classic()+ theme(legend.text = element_text(colour="black", size=10, face="bold"))+ theme(legend.position="bottom",
                                                                                                  axis.title=element_text(size=8))
#+ geom_vline(aes(xintercept = 0,linetype = "Nash"), show.legend=FALSE) +scale_linetype_manual(values =c( "Nash" = "dashed")) +scale_colour_manual(values = c("Nash"="black"))


## Plot mean profit

P_meanprofit=ggplot(ggplot_XP_j6i65ra1[which(ggplot_XP_j6i65ra1$variable=='group_meanprofit'),], 
                    aes(x=as.numeric(ggplot_XP_j6i65ra1$value[which(ggplot_XP_j6i65ra1$variable=='subsession_round')]),
                        y=as.numeric(ggplot_XP_j6i65ra1$value[which(ggplot_XP_j6i65ra1$variable=='group_meanprofit')])))


limits <- aes(ymax = xp_j6i65ra1$group_meanprofit + xp_j6i65ra1$group_sdprofit, ymin= xp_j6i65ra1$group_meanprofit - xp_j6i65ra1$group_sdprofit)
dodge <- position_dodge(width=0.6)


P_meanprofit = P_meanprofit + geom_point(size=1.8) + geom_line()+  geom_errorbar(limits,position=dodge, width=0.2,size=0.8) +
  xlim(0,15)+ylim(-5,5)+
  ylab("Mean Profit (UVM)") + xlab("Round (Year)") +
  theme_classic()+ theme(legend.text = element_text(colour="black", size=10, face="bold"))+ theme(legend.position="bottom",
                                                                                                  axis.title=element_text(size=8))
#+ geom_vline(aes(xintercept = 0,linetype = "Nash"), show.legend=FALSE) +scale_linetype_manual(values =c( "Nash" = "dashed")) +scale_colour_manual(values = c("Nash"="black"))


## Plot total profit

P_totalprofit=ggplot(ggplot_XP_j6i65ra1[which(ggplot_XP_j6i65ra1$variable=='group_totalprofit'),], 
                     aes(x=as.numeric(ggplot_XP_j6i65ra1$value[which(ggplot_XP_j6i65ra1$variable=='subsession_round')]),
                         y=as.numeric(ggplot_XP_j6i65ra1$value[which(ggplot_XP_j6i65ra1$variable=='group_totalprofit')])))

P_totalprofit= P_totalprofit + geom_line()+ylim(min(xp_j6i65ra1$group_totalprofit,na.rm=TRUE),6)+ xlim(0,15)+
  ylab("Total Profit (UVM)") + xlab("Round (Year)") +
  theme_classic()+ theme(legend.text = element_text(colour="black", size=10, face="bold"))+ theme(legend.position="bottom",
                                                                                                  axis.title=element_text(size=8))


## Plot biomass

P_biomasse=ggplot(ggplot_XP_j6i65ra1[which(ggplot_XP_j6i65ra1$variable=='group_biomasse'),], 
                  aes(x=as.numeric(ggplot_XP_j6i65ra1$value[which(ggplot_XP_j6i65ra1$variable=='subsession_round')]),
                      y=as.numeric(ggplot_XP_j6i65ra1$value[which(ggplot_XP_j6i65ra1$variable=='group_biomasse')])))

P_biomasse= P_biomasse + geom_line() + ylim(0,30) + xlim(0,15) +
  ylab("Biomass (UVS)") + xlab("Round (Year)") +
  theme_classic()+ theme(legend.text = element_text(colour="black", size=10, face="bold"))+ theme(legend.position="bottom",
                                                                                                  axis.title=element_text(size=8))


## Plot stateExploitation
P_group_stateExploitation = ggplot(ggplot_XP_j6i65ra1[which(ggplot_XP_j6i65ra1$variable=='group_stateExploitation'),], 
                                   aes(x=factor(as.numeric(ggplot_XP_j6i65ra1$value[which(ggplot_XP_j6i65ra1$variable=='subsession_round')])),
                                       y=(as.numeric(ggplot_XP_j6i65ra1$value[which(ggplot_XP_j6i65ra1$variable=='group_stateExploitation')]))/3))

P_group_stateExploitation = P_group_stateExploitation + geom_bar(stat = "identity") +
  ylab("Over/Under Exploitation based on Bmsy (%)") + xlab("Round (Year)") +
  theme_classic()+ theme(legend.text = element_text(colour="black", size=10, face="bold"))+ theme(legend.position="bottom",
                                                                                                  axis.title=element_text(size=8))

## Plot deviation from optimal path

P_opt_prof_dev = ggplot(ggplot_XP_j6i65ra1[which(ggplot_XP_j6i65ra1$variable=='group_optProfDev'),], 
                        aes(x=factor(as.numeric(ggplot_XP_j6i65ra1$value[which(ggplot_XP_j6i65ra1$variable=='subsession_round')])),
                            y=(as.numeric(ggplot_XP_j6i65ra1$value[which(ggplot_XP_j6i65ra1$variable=='group_optProfDev')]))/3))

P_opt_prof_dev = P_opt_prof_dev + geom_bar(stat = "identity") +
  ylab("Deviation from optimal profit path (%)") + xlab("Round (Year)") +
  theme_classic()+ theme(legend.text = element_text(colour="black", size=10, face="bold"))+ theme(legend.position="bottom",
                                                                                                  axis.title=element_text(size=8))




if (do.save==TRUE){jpeg(filename=paste(path.fig,"Grdemo_p1_T0.jpg",sep=""),width = 2500, height = 2500,res = 300)}

grid.arrange(P_catch, P_profit , P_catchpledge, P_totalcatch, P_totalprofit , P_biomasse, P_meancatchpledge, P_meancatch,P_meanprofit,
             P_group_stateExploitation,P_opt_prof_dev,
             ncol=3, top = "Group demo: T0 | phase 1")

if (do.save==TRUE){dev.off()}



