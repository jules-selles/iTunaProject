
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

source(paste(dir.data,dir.script,"read_Otree.R",sep=""))
source(paste(dir.data,dir.script,"makeTable_Otree.R",sep=""))

## save plot 

path.fig= paste(dir.data,dir.xp,sep="")


#-----------------------------------------
## Make data frame with all sessions
#-----------------------------------------

##--------------------------------------------------
## Session: mcd29yv0 / Group demo / p1 T0 / Ceresa,Bazin,Feuilloley / -> BUG biomass  ~ total catch

xpdemo_data=extract_Otree_data(paste(dir.data,dir.xp,sep=""),"Xp1p1_T0_demo.csv")
xpdemo_data=as.data.frame(xpdemo_data)
xp_mcd29yv0 = make.table.Otree(xp.data=xpdemo_data, session="mcd29yv0", name=c("ceresa","bazin","feuilloley"),
                               age=c(22,23,22), profession=c("student","student","student"))
xp_mcd29yv0$treatment = 'T0'
xp_mcd29yv0$phase = 'p1'

##--------------------------------------------------
## Session: mcd29yv0 / Group demo / p2 T0 / Ceresa,Bazin,Feuilloley / -> BUG biomass  ~ total catch

xpdemo_data=extract_Otree_data(paste(dir.data,dir.xp,sep=""),"Xp1p2_T0_demo.csv")
xpdemo_data=as.data.frame(xpdemo_data)
xp2_mcd29yv0 = make.table.Otree(xp.data=xpdemo_data, session="mcd29yv0", name=c("ceresa","bazin","feuilloley"),
                               age=c(22,23,22), profession=c("student","student","student"))
xp2_mcd29yv0$treatment = 'T0'
xp2_mcd29yv0$phase = 'p2'

##--------------------------------------------------
## Session: qkzbtj24 / Group demo / p2 T1 / Ceresa,Bazin,Feuilloley / -> BUG biomass  ~ total catch

xpdemo_data=extract_Otree_data(paste(dir.data,dir.xp,sep=""),"Xp1p1_T1_demo.csv")
xpdemo_data=as.data.frame(xpdemo_data)
xp_qkzbtj24 = make.table.Otree(xp.data=xpdemo_data, session="qkzbtj24", name=c("girardot","perez","prim"),
                                age=c(22,23,22), profession=c("student","student","student"))
xp_qkzbtj24$treatment = 'T1'
xp_qkzbtj24$phase = 'p1'

##--------------------------------------------------
## Session: qkzbtj24 / Group demo / p2 T1 / Ceresa,Bazin,Feuilloley / -> BUG biomass  ~ total catch

xpdemo_data=extract_Otree_data(paste(dir.data,dir.xp,sep=""),"Xp1p2_T1_demo.csv")
xpdemo_data=as.data.frame(xpdemo_data)
xp2_qkzbtj24 = make.table.Otree(xp.data=xpdemo_data, session="qkzbtj24", name=c("girardot","perez","prim"),
                               age=c(22,23,22), profession=c("student","student","student"))
xp2_qkzbtj24$treatment = 'T1'
xp2_qkzbtj24$phase = 'p2'


##--------------------------------------------------
## Session: qkzbtj24 / Group demo / p1 T2 / Ceresa,Bazin,Feuilloley / -> BUG biomass  ~ total catch

xpdemo_data=extract_Otree_data(paste(dir.data,dir.xp,sep=""),"Xp1p1_T2_demo.csv")
xpdemo_data=as.data.frame(xpdemo_data)
xp_d6svy5q9 = make.table.Otree(xp.data=xpdemo_data, session="d6svy5q9", name=c("astrid","soscian","salvetat"),
                                age=c(22,23,22), profession=c("student","student","student"))
xp_d6svy5q9$treatment = 'T2'
xp_d6svy5q9$phase = 'p1'

##--------------------------------------------------
## Session: qkzbtj24 / Group demo / p2 T2 / Ceresa,Bazin,Feuilloley / -> BUG biomass  ~ total catch

xpdemo_data=extract_Otree_data(paste(dir.data,dir.xp,sep=""),"Xp1p2_T2_demo.csv")
xpdemo_data=as.data.frame(xpdemo_data)
xp2_d6svy5q9 = make.table.Otree(xp.data=xpdemo_data, session="d6svy5q9", name=c("astrid","soscian","salvetat"),
                               age=c(22,23,22), profession=c("student","student","student"))
xp2_d6svy5q9$treatment = 'T2'
xp2_d6svy5q9$phase = 'p2'


#--------------------------------------------------------------------------------------------
## Plot by session 
#--------------------------------------------------------------------------------------------
nb_xp=list(p1T0=xp_mcd29yv0,p2T0=xp2_mcd29yv0,p1T1=xp_qkzbtj24,p2T1=xp2_qkzbtj24,p1T2=xp_d6svy5q9,p2T2=xp2_d6svy5q9)


for (i in 1 : 6){
##---------------------
## rearrange to plot with ggplot 
gg=melt(nb_xp[[i]],id=c('participant_roundnumber','participant_id','participant_code','participant_appname',
                                         'session_code','player_name', 'player_age', 'player_profession'))

#-----------------
## plot 

## Plot ind catch

P_catch=ggplot(gg[which(gg$variable=='player_catchchoice'),], 
               aes(as.numeric(gg$value[which(gg$variable=='subsession_round')]),
                   as.numeric(gg$value[which(gg$variable=='player_catchchoice')]),
                   group=as.factor(gg$value[which(gg$variable=='player_id')]),
                   colour=as.factor(gg$value[which(gg$variable=='player_id')])))

P_catch =P_catch + geom_line()+ylim(0,15)+ xlim(0,15)+
  scale_colour_discrete(name  ="Coalitions")+
  ylab("Harvest (UVS)") + xlab("Round (Year)") +
  theme_classic()+ theme(legend.text = element_text(colour="black", size=10, face="bold"))+ theme(legend.position="bottom",
                                                                                                  axis.title=element_text(size=8))
#+ geom_vline(aes(xintercept = 0,linetype = "Nash"), show.legend=FALSE) +scale_linetype_manual(values =c( "Nash" = "dashed")) +scale_colour_manual(values = c("Nash"="black"))


## Plot ind catch pledge 

P_catchpledge=ggplot(gg[which(gg$variable=='player_catchpledge'),], 
                     aes(as.numeric(gg$value[which(gg$variable=='subsession_round')]),
                         as.numeric(gg$value[which(gg$variable=='player_catchpledge')]),
                         group=as.factor(gg$value[which(gg$variable=='player_id')]),
                         colour=as.factor(gg$value[which(gg$variable=='player_id')])))

P_catchpledge = P_catchpledge + geom_line()+ylim(0,15)+ xlim(0,15)+
  scale_colour_discrete(name  ="Coalitions")+
  ylab("Harvest pledge (UVS)") + xlab("Round (Year)") +
  theme_classic()+ theme(legend.text = element_text(colour="black", size=10, face="bold"))+ theme(legend.position="bottom",
                                                                                                  axis.title=element_text(size=8))
#+ geom_vline(aes(xintercept = 0,linetype = "Nash"), show.legend=FALSE) +scale_linetype_manual(values =c( "Nash" = "dashed")) +scale_colour_manual(values = c("Nash"="black"))



## Plot mean catch pledge

P_meancatchpledge=ggplot(gg[which(gg$variable=='group_meancatchpledge'),], 
                         aes(x=as.numeric(gg$value[which(gg$variable=='subsession_round')]),
                             y=as.numeric(gg$value[which(gg$variable=='group_meancatchpledge')])))

limits <- aes(ymax = nb_xp[[i]]$group_meancatchpledge + nb_xp[[i]]$group_sdcatchpledge, ymin= nb_xp[[i]]$group_meancatchpledge - nb_xp[[i]]$group_sdcatchpledge)
dodge <- position_dodge(width=1)

P_meancatchpledge = P_meancatchpledge + geom_line() +  geom_point(size=1.8) + geom_errorbar(limits,position=dodge, width=0.2,size=0.8)+ ylim(0,15)+ xlim(0,15)+
  ylab("Mean Harvest Pledge (UVS)") + xlab("Round (Year)") +
  theme_classic()+ theme(legend.text = element_text(colour="black", size=10, face="bold"))+ theme(legend.position="bottom",
                                                                                                  axis.title=element_text(size=8))
#+ geom_vline(aes(xintercept = 0,linetype = "Nash"), show.legend=FALSE) +scale_linetype_manual(values =c( "Nash" = "dashed")) +scale_colour_manual(values = c("Nash"="black"))


## Plot total catch

P_totalcatch=ggplot(gg[which(gg$variable=='group_totalcatch'),], 
                    aes(x=as.numeric(gg$value[which(gg$variable=='subsession_round')]),
                        y=as.numeric(gg$value[which(gg$variable=='group_totalcatch')])))

P_totalcatch =P_totalcatch + geom_line()+ylim(0,15)+ xlim(0,15)+
  ylab("Total Harvest (UVS)") + xlab("Round (Year)") +
  theme_classic()+ theme(legend.text = element_text(colour="black", size=10, face="bold"))+ theme(legend.position="bottom",axis.title=element_text(size=8))
#+ geom_vline(aes(xintercept = 0,linetype = "Nash"), show.legend=FALSE) +scale_linetype_manual(values =c( "Nash" = "dashed")) +scale_colour_manual(values = c("Nash"="black"))


## Plot mean catch

P_meancatch=ggplot(gg[which(gg$variable=='group_meancatch'),], 
                   aes(x=as.numeric(gg$value[which(gg$variable=='subsession_round')]),
                       y=as.numeric(gg$value[which(gg$variable=='group_meancatch')])))

limits <- aes(ymax = nb_xp[[i]]$group_meancatch + nb_xp[[i]]$group_sdcatch, ymin= nb_xp[[i]]$group_meancatch - nb_xp[[i]]$group_sdcatch)
dodge <- position_dodge(width=1)


P_meancatch = P_meancatch + geom_point(size=1.8) + geom_line()+  geom_errorbar(limits,position=dodge, width=0.2,size=0.8) + ylim(0,15)+ xlim(0,15)+
  ylab("Mean Harvest (UVS)") + xlab("Round (Year)") +
  theme_classic()+ theme(legend.text = element_text(colour="black", size=10, face="bold"))+ theme(legend.position="bottom",
                                                                                                  axis.title=element_text(size=8))
#+ geom_vline(aes(xintercept = 0,linetype = "Nash"), show.legend=FALSE) +scale_linetype_manual(values =c( "Nash" = "dashed")) +scale_colour_manual(values = c("Nash"="black"))


## Plot ind profit

P_profit=ggplot(gg[which(gg$variable=='player_profit'),], 
                aes(x=as.numeric(gg$value[which(gg$variable=='subsession_round')]),
                    as.numeric(gg$value[which(gg$variable=='player_profit')]),
                    group=as.factor(gg$value[which(gg$variable=='player_id')]),
                    colour=as.factor(gg$value[which(gg$variable=='player_id')]),
                    fill=as.factor(gg$value[which(gg$variable=='player_id')])))

P_profit=P_profit + geom_line()+ylim(min(nb_xp[[i]]$player_profit,na.rm=TRUE),5)+ xlim(0,15)+
  scale_colour_discrete(name  ="Coalitions")+
  ylab("Profit (UVM)") + xlab("Round (Year)") +
  theme_classic()+ theme(legend.text = element_text(colour="black", size=10, face="bold"))+ theme(legend.position="bottom",
                                                                                                  axis.title=element_text(size=8))
#+ geom_vline(aes(xintercept = 0,linetype = "Nash"), show.legend=FALSE) +scale_linetype_manual(values =c( "Nash" = "dashed")) +scale_colour_manual(values = c("Nash"="black"))


## Plot mean profit

P_meanprofit=ggplot(gg[which(gg$variable=='group_meanprofit'),], 
                    aes(x=as.numeric(gg$value[which(gg$variable=='subsession_round')]),
                        y=as.numeric(gg$value[which(gg$variable=='group_meanprofit')])))


limits <- aes(ymax = nb_xp[[i]]$group_meanprofit + nb_xp[[i]]$group_sdprofit, ymin= nb_xp[[i]]$group_meanprofit - nb_xp[[i]]$group_sdprofit)
dodge <- position_dodge(width=0.6)


P_meanprofit = P_meanprofit + geom_point(size=1.8) + geom_line()+  geom_errorbar(limits,position=dodge, width=0.2,size=0.8) +
  xlim(0,15)+ylim(-5,5)+
  ylab("Mean Profit (UVM)") + xlab("Round (Year)") +
  theme_classic()+ theme(legend.text = element_text(colour="black", size=10, face="bold"))+ theme(legend.position="bottom",
                                                                                                  axis.title=element_text(size=8))
#+ geom_vline(aes(xintercept = 0,linetype = "Nash"), show.legend=FALSE) +scale_linetype_manual(values =c( "Nash" = "dashed")) +scale_colour_manual(values = c("Nash"="black"))


## Plot total profit

P_totalprofit=ggplot(gg[which(gg$variable=='group_totalprofit'),], 
                     aes(x=as.numeric(gg$value[which(gg$variable=='subsession_round')]),
                         y=as.numeric(gg$value[which(gg$variable=='group_totalprofit')])))

P_totalprofit= P_totalprofit + geom_line()+ylim(min(nb_xp[[i]]$group_totalprofit,na.rm=TRUE),6)+ xlim(0,15)+
  ylab("Total Profit (UVM)") + xlab("Round (Year)") +
  theme_classic()+ theme(legend.text = element_text(colour="black", size=10, face="bold"))+ theme(legend.position="bottom",
                                                                                                  axis.title=element_text(size=8))


## Plot biomass

P_biomasse=ggplot(gg[which(gg$variable=='group_biomasse'),], 
                  aes(x=as.numeric(gg$value[which(gg$variable=='subsession_round')]),
                      y=as.numeric(gg$value[which(gg$variable=='group_biomasse')])))

P_biomasse= P_biomasse + geom_line() + ylim(0,30) + xlim(0,15) +
  ylab("Biomass (UVS)") + xlab("Round (Year)") +
  theme_classic()+ theme(legend.text = element_text(colour="black", size=10, face="bold"))+ theme(legend.position="bottom",
                                                                                                  axis.title=element_text(size=8))


## Plot stateExploitation
P_group_stateExploitation = ggplot(gg[which(gg$variable=='group_stateExploitation'),], 
                                   aes(x=as.numeric(gg$value[which(gg$variable=='subsession_round')]),
                                       y=(as.numeric(gg$value[which(gg$variable=='group_stateExploitation')]))))

P_group_stateExploitation = P_group_stateExploitation +  geom_point(size=1.8)+ geom_line() + 
  ylab("Harvest / MSY ") + xlab("Round (Year)") +
  theme_classic()+ theme(legend.text = element_text(colour="black", size=10, face="bold"))+ theme(legend.position="bottom",
                                                                                                  axis.title=element_text(size=8))

## Plot deviation from optimal path

P_opt_prof_dev = ggplot(gg[which(gg$variable=='group_optProfDev'),], 
                        aes(x=factor(as.numeric(gg$value[which(gg$variable=='subsession_round')])),
                            y=(as.numeric(gg$value[which(gg$variable=='group_optProfDev')])/3)))

P_opt_prof_dev = P_opt_prof_dev + geom_bar(stat = "identity") +
  ylab("Deviation from optimal profit path ") + xlab("Round (Year)") +
  theme_classic()+ theme(legend.text = element_text(colour="black", size=10, face="bold"))+ theme(legend.position="bottom",
                                                                                                  axis.title=element_text(size=8))


##-------------------------------------
##------------------------------------

if (do.save==TRUE){jpeg(filename=paste(path.fig,"T",substr(names(nb_xp)[i], 4, 4),"_phase",substr(names(nb_xp)[i], 2, 2),".jpg",sep=""),
                        width = 2500, height = 2500,res = 300)}

grid.arrange(P_catch, P_profit , P_catchpledge, P_totalcatch, P_totalprofit , P_biomasse, P_meancatchpledge, P_meancatch,P_meanprofit,
             P_group_stateExploitation,P_opt_prof_dev,
             ncol=3, top = paste("T",substr(names(nb_xp)[i], 4, 4)," | phase:",substr(names(nb_xp)[i], 2, 2),sep=""))

if (do.save==TRUE){dev.off()}

##-------------------------------------
##------------------------------------
print(paste(names(nb_xp)[i],'Efficacité: ',nb_xp[[i]]$group_efficiency[1],sep=""))
print("#--------------------------------------------------------------------------#")
print(paste(names(nb_xp)[i],'Deviation Moyenne: ',mean(nb_xp[[i]]$group_optProfDev,na.rm=T),sep=""))
print("#--------------------------------------------------------------------------#")
print(paste(names(nb_xp)[i],'Capture Moyenne: ',mean(nb_xp[[i]]$group_meancatch,na.rm=T),sep=""))
print(paste(names(nb_xp)[i],'Profit Moyen: ',mean(nb_xp[[i]]$group_meanprofit,na.rm=T),sep=""))
print("#--------------------------------------------------------------------------#")
print(paste(names(nb_xp)[i],'Capture totale: ',sum(nb_xp[[i]]$player_catchchoice,na.rm=T),sep=""))
print(paste(names(nb_xp)[i],'Profit total: ',sum(nb_xp[[i]]$player_profit,na.rm=T),sep=""))

print("############################################################################")
print("#--------------------------------------------------------------------------#")

}

