##### Lecture des Résultats expérimentaux OTree ####
####################################################
#### Selles Jules ##### 
#### V.1          #####
#### 12/16        #####
##--------------------------------------------------
  
  
dir.data           <- "C:/Users/jselles/Dropbox/These/These_Ifremer/Documents_Travail/Modele_XP/"
dir.script         <- "Xp_protocole/R_scripts/" 
dir.xp             <- "AERME_Test_Session/"
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

path.fig= paste(dir.data,dir.xp,"Resultats/",sep="")


##--------------------------------------------------
## Read raw data
xp1_data=extract_Otree_data(paste(dir.data,dir.xp,sep=""),"data/Xp1p1_data_AERME.csv")
xp1_data=as.data.frame(xp1_data)

xp2_data=extract_Otree_data(paste(dir.data,dir.xp,sep=""),"data/Xp1p2_data_AERME.csv")
xp2_data=as.data.frame(xp2_data)


#-----------------------------------------
## Make data frame with all sessions
#-----------------------------------------

##--------------------------------------------------
## Session: qz740agn / Group 1 / p1 t / Ceresa,Bazin,Feuilloley / -> BUG biomass  ~ total catch

xp1_qz740agn = make.table.Otree(xp.data=xp1_data, session="qz740agn", name=c("C.Ceresa","A.Bazin","G.Feuilloley"),
                          age=c(22,22,22), profession=c("student","student","student"))
xp1_qz740agn$treatment = 'T0'

##--------------------------------------------------
## Session: irv26b86 / Group 1 / p2 T0 / Ceresa,Bazin,Feuilloley / -> BUG biomass  ~ total catch

xp2_irv26b86 = make.table.Otree(xp.data=xp2_data, session="irv26b86", name=c("C.Ceresa","A.Bazin","G.Feuilloley"),
                                age=c(22,22,22), profession=c("student","student","student"))
xp2_irv26b86$treatment = 'T0'

##--------------------------------------------------
## Session: ifdimqu3  / Group 2 / p1 T1 / Girardot, Perez , Prim / -> BUG biomass  ~ total catch

xp1_ifdimqu3 = make.table.Otree(xp.data=xp1_data, session="ifdimqu3", name=c("Girardot","G.Perez","A.H.Prim"),
                                age=c(22,22,22), profession=c("student","student","student"))
xp1_ifdimqu3$treatment = 'T1'

##--------------------------------------------------
## Session: ifdimqu3  / Group 2 / p2 T1 / Girardot, Perez , Prim / -> BUG biomass  ~ total catch

xp2_ifdimqu3 = make.table.Otree(xp.data=xp2_data, session="ifdimqu3", name=c("Girardot","G.Perez","A.H.Prim"),
                                age=c(22,22,22), profession=c("student","student","student"))
xp2_ifdimqu3$treatment = 'T1'

##--------------------------------------------------
## Session: x8py2yrx  / Group 3 / p1 T2 / Astrid, M.Soscian , J.Salvetat / -> BUG biomass  ~ total catch

xp1_x8py2yrx = make.table.Otree(xp.data=xp1_data, session="x8py2yrx", name=c("Astrid","M.Soscian","J.Salvetat"),
                                age=c(22,22,22), profession=c("student","student","student"))
xp1_x8py2yrx$treatment = 'T2'

##--------------------------------------------------
## Session: d7ux4n2a  / Group 3 / p2 T0 / Astrid, M.Soscian , J.Salvetat / -> BUG biomass  ~ total catch

xp2_d7ux4n2a = make.table.Otree(xp.data=xp2_data, session="d7ux4n2a", name=c("Astrid","M.Soscian","J.Salvetat"),
                                age=c(22,22,22), profession=c("student","student","student"))
xp2_d7ux4n2a$treatment = 'T0'


## DATA AERME_XP
AERME_XP = rbind(xp1_qz740agn,xp2_irv26b86,xp1_ifdimqu3,xp2_ifdimqu3,xp1_x8py2yrx,xp2_d7ux4n2a)




#--------------------------------------------------------------------------------------------
## Plot by session 
#--------------------------------------------------------------------------------------------

##--------------------------------------------------
## Session: qz740agn / Group 1 / p1 T0 / Ceresa,Bazin,Feuilloley / 
##--------------------------------------------------

##---------------------
## rearrange to plot with ggplot 
ggplot_XP_qz740agn=melt(xp1_qz740agn,id=c('participant_roundnumber','participant_id','participant_code','participant_appname',
                                                      'session_code','player_name', 'player_age', 'player_profession'))

#-----------------
## plot 

## Plot ind catch

P_catch=ggplot(ggplot_XP_qz740agn[which(ggplot_XP_qz740agn$variable=='player_catchchoice'),], 
          aes(as.numeric(ggplot_XP_qz740agn$value[which(ggplot_XP_qz740agn$variable=='subsession_round')]),
              as.numeric(ggplot_XP_qz740agn$value[which(ggplot_XP_qz740agn$variable=='player_catchchoice')]),
              group=as.factor(ggplot_XP_qz740agn$value[which(ggplot_XP_qz740agn$variable=='player_id')]),
              colour=as.factor(ggplot_XP_qz740agn$value[which(ggplot_XP_qz740agn$variable=='player_id')])))

P_catch =P_catch + geom_line()+ylim(0,15)+ xlim(0,15)+
  scale_colour_discrete(name  ="Coalitions")+
  ylab("Harvest (UVS)") + xlab("Round (Year)") +
  theme_classic()+ theme(legend.text = element_text(colour="black", size=10, face="bold"))+ theme(legend.position="bottom")
#+ geom_vline(aes(xintercept = 0,linetype = "Nash"), show.legend=FALSE) +scale_linetype_manual(values =c( "Nash" = "dashed")) +scale_colour_manual(values = c("Nash"="black"))


## Plot ind catch pledge 

P_catchpledge=ggplot(ggplot_XP_qz740agn[which(ggplot_XP_qz740agn$variable=='player_catchpledge'),], 
               aes(as.numeric(ggplot_XP_qz740agn$value[which(ggplot_XP_qz740agn$variable=='subsession_round')]),
                   as.numeric(ggplot_XP_qz740agn$value[which(ggplot_XP_qz740agn$variable=='player_catchpledge')]),
                   group=as.factor(ggplot_XP_qz740agn$value[which(ggplot_XP_qz740agn$variable=='player_id')]),
                   colour=as.factor(ggplot_XP_qz740agn$value[which(ggplot_XP_qz740agn$variable=='player_id')])))

P_catchpledge = P_catchpledge + geom_line()+ylim(0,15)+ xlim(0,15)+
  scale_colour_discrete(name  ="Coalitions")+
  ylab("Harvest pledge (UVS)") + xlab("Round (Year)") +
  theme_classic()+ theme(legend.text = element_text(colour="black", size=10, face="bold"))+ theme(legend.position="bottom")
#+ geom_vline(aes(xintercept = 0,linetype = "Nash"), show.legend=FALSE) +scale_linetype_manual(values =c( "Nash" = "dashed")) +scale_colour_manual(values = c("Nash"="black"))



## Plot mean catch pledge

P_meancatchpledge=ggplot(ggplot_XP_qz740agn[which(ggplot_XP_qz740agn$variable=='group_meancatchpledge'),], 
                   aes(x=as.numeric(ggplot_XP_qz740agn$value[which(ggplot_XP_qz740agn$variable=='subsession_round')]),
                       y=as.numeric(ggplot_XP_qz740agn$value[which(ggplot_XP_qz740agn$variable=='group_meancatchpledge')])))

P_meancatchpledge = P_meancatchpledge + geom_line() +ylim(0,15)+ xlim(0,15)+
  ylab("Mean Harvest Pledge (UVS)") + xlab("Round (Year)") +
  theme_classic()+ theme(legend.text = element_text(colour="black", size=10, face="bold"))+ theme(legend.position="bottom")
#+ geom_vline(aes(xintercept = 0,linetype = "Nash"), show.legend=FALSE) +scale_linetype_manual(values =c( "Nash" = "dashed")) +scale_colour_manual(values = c("Nash"="black"))


## Plot total catch

P_totalcatch=ggplot(ggplot_XP_qz740agn[which(ggplot_XP_qz740agn$variable=='group_totalcatch'),], 
               aes(x=as.numeric(ggplot_XP_qz740agn$value[which(ggplot_XP_qz740agn$variable=='subsession_round')]),
                   y=as.numeric(ggplot_XP_qz740agn$value[which(ggplot_XP_qz740agn$variable=='group_totalcatch')])))

P_totalcatch =P_totalcatch + geom_line()+ylim(0,15)+ xlim(0,15)+
  ylab("Total Harvest (UVS)") + xlab("Round (Year)") +
  theme_classic()+ theme(legend.text = element_text(colour="black", size=10, face="bold"))+ theme(legend.position="bottom")
#+ geom_vline(aes(xintercept = 0,linetype = "Nash"), show.legend=FALSE) +scale_linetype_manual(values =c( "Nash" = "dashed")) +scale_colour_manual(values = c("Nash"="black"))


## Plot mean catch

P_meancatch=ggplot(ggplot_XP_qz740agn[which(ggplot_XP_qz740agn$variable=='group_meancatch'),], 
                    aes(x=as.numeric(ggplot_XP_qz740agn$value[which(ggplot_XP_qz740agn$variable=='subsession_round')]),
                        y=as.numeric(ggplot_XP_qz740agn$value[which(ggplot_XP_qz740agn$variable=='group_meancatch')])))

P_meancatch = P_meancatch + geom_line() +ylim(0,15)+ xlim(0,15)+
  ylab("Mean Harvest (UVS)") + xlab("Round (Year)") +
  theme_classic()+ theme(legend.text = element_text(colour="black", size=10, face="bold"))+ theme(legend.position="bottom")
#+ geom_vline(aes(xintercept = 0,linetype = "Nash"), show.legend=FALSE) +scale_linetype_manual(values =c( "Nash" = "dashed")) +scale_colour_manual(values = c("Nash"="black"))


## Plot ind profit

P_profit=ggplot(ggplot_XP_qz740agn[which(ggplot_XP_qz740agn$variable=='player_profit'),], 
          aes(x=as.numeric(ggplot_XP_qz740agn$value[which(ggplot_XP_qz740agn$variable=='subsession_round')]),
              as.numeric(ggplot_XP_qz740agn$value[which(ggplot_XP_qz740agn$variable=='player_profit')]),
              group=as.factor(ggplot_XP_qz740agn$value[which(ggplot_XP_qz740agn$variable=='player_id')]),
              colour=as.factor(ggplot_XP_qz740agn$value[which(ggplot_XP_qz740agn$variable=='player_id')]),
              fill=as.factor(ggplot_XP_qz740agn$value[which(ggplot_XP_qz740agn$variable=='player_id')])))

P_profit=P_profit + geom_line()+ylim(0,6)+ xlim(0,15)+
  scale_colour_discrete(name  ="Coalitions")+
  ylab("Profit (UVM)") + xlab("Round (Year)") +
  theme_classic()+ theme(legend.text = element_text(colour="black", size=10, face="bold"))+ theme(legend.position="bottom")
#+ geom_vline(aes(xintercept = 0,linetype = "Nash"), show.legend=FALSE) +scale_linetype_manual(values =c( "Nash" = "dashed")) +scale_colour_manual(values = c("Nash"="black"))


## Plot mean profit

P_meanprofit=ggplot(ggplot_XP_qz740agn[which(ggplot_XP_qz740agn$variable=='group_meanprofit'),], 
                   aes(x=as.numeric(ggplot_XP_qz740agn$value[which(ggplot_XP_qz740agn$variable=='subsession_round')]),
                       y=as.numeric(ggplot_XP_qz740agn$value[which(ggplot_XP_qz740agn$variable=='group_meanprofit')])))

P_meanprofit = P_meanprofit + geom_line() + ylim(0,6)+ xlim(0,15)+
  ylab("Mean Profit (UVM)") + xlab("Round (Year)") +
  theme_classic()+ theme(legend.text = element_text(colour="black", size=10, face="bold"))+ theme(legend.position="bottom")
#+ geom_vline(aes(xintercept = 0,linetype = "Nash"), show.legend=FALSE) +scale_linetype_manual(values =c( "Nash" = "dashed")) +scale_colour_manual(values = c("Nash"="black"))



## Plot total profit

P_totalprofit=ggplot(ggplot_XP_qz740agn[which(ggplot_XP_qz740agn$variable=='group_totalprofit'),], 
                    aes(x=as.numeric(ggplot_XP_qz740agn$value[which(ggplot_XP_qz740agn$variable=='subsession_round')]),
                        y=as.numeric(ggplot_XP_qz740agn$value[which(ggplot_XP_qz740agn$variable=='group_totalprofit')])))

P_totalprofit= P_totalprofit + geom_line()+ylim(0,6)+ xlim(0,15)+
  ylab("Total Profit (UVM)") + xlab("Round (Year)") +
  theme_classic()+ theme(legend.text = element_text(colour="black", size=10, face="bold"))+ theme(legend.position="bottom")


## Plot biomass

P_biomasse=ggplot(ggplot_XP_qz740agn[which(ggplot_XP_qz740agn$variable=='group_biomasse'),], 
                     aes(x=as.numeric(ggplot_XP_qz740agn$value[which(ggplot_XP_qz740agn$variable=='subsession_round')]),
                         y=as.numeric(ggplot_XP_qz740agn$value[which(ggplot_XP_qz740agn$variable=='group_biomasse')])))

P_biomasse= P_biomasse + geom_line() + ylim(0,30) + xlim(0,15) +
  ylab("Biomass (UVS)") + xlab("Round (Year)") +
  theme_classic()+ theme(legend.text = element_text(colour="black", size=10, face="bold"))+ theme(legend.position="bottom")


if (do.save==TRUE){jpeg(filename=paste(path.fig,"Gr1_p1_T0.jpg",sep=""),width = 2500, height = 2500,res = 300)}

grid.arrange(P_catch, P_profit , P_catchpledge, P_totalcatch, P_totalprofit , P_biomasse, P_meancatchpledge, P_meancatch,P_meanprofit, ncol=3, top = "Group 1: T0 | phase 1")

if (do.save==TRUE){dev.off()}


##--------------------------------------------------
##--------------------------------------------------
## Session: irv26b86 / Group 1 / p2 T0 / Ceresa,Bazin,Feuilloley / 

##---------------------
## rearrange to plot with ggplot 

ggplot_XP_irv26b86=melt(xp2_irv26b86,id=c('participant_roundnumber','participant_id','participant_code','participant_appname',
                                          'session_code','player_name', 'player_age', 'player_profession'))

#-----------------
## plot 

## Plot ind catch

P_catch=ggplot(ggplot_XP_irv26b86[which(ggplot_XP_irv26b86$variable=='player_catchchoice'),], 
               aes(as.numeric(ggplot_XP_irv26b86$value[which(ggplot_XP_irv26b86$variable=='subsession_round')]),
                   as.numeric(ggplot_XP_irv26b86$value[which(ggplot_XP_irv26b86$variable=='player_catchchoice')]),
                   group=as.factor(ggplot_XP_irv26b86$value[which(ggplot_XP_irv26b86$variable=='player_id')]),
                   colour=as.factor(ggplot_XP_irv26b86$value[which(ggplot_XP_irv26b86$variable=='player_id')])))

P_catch =P_catch + geom_line()+ylim(0,15)+ xlim(0,15)+
  scale_colour_discrete(name  ="Coalitions")+
  ylab("Harvest (UVS)") + xlab("Round (Year)") +
  theme_classic()+ theme(legend.text = element_text(colour="black", size=10, face="bold"))+ theme(legend.position="bottom")
#+ geom_vline(aes(xintercept = 0,linetype = "Nash"), show.legend=FALSE) +scale_linetype_manual(values =c( "Nash" = "dashed")) +scale_colour_manual(values = c("Nash"="black"))


## Plot ind catch pledge 

P_catchpledge=ggplot(ggplot_XP_irv26b86[which(ggplot_XP_irv26b86$variable=='player_catchpledge'),], 
                     aes(as.numeric(ggplot_XP_irv26b86$value[which(ggplot_XP_irv26b86$variable=='subsession_round')]),
                         as.numeric(ggplot_XP_irv26b86$value[which(ggplot_XP_irv26b86$variable=='player_catchpledge')]),
                         group=as.factor(ggplot_XP_irv26b86$value[which(ggplot_XP_irv26b86$variable=='player_id')]),
                         colour=as.factor(ggplot_XP_irv26b86$value[which(ggplot_XP_irv26b86$variable=='player_id')])))

P_catchpledge = P_catchpledge + geom_line()+ylim(0,15)+ xlim(0,15)+
  scale_colour_discrete(name  ="Coalitions")+
  ylab("Harvest pledge (UVS)") + xlab("Round (Year)") +
  theme_classic()+ theme(legend.text = element_text(colour="black", size=10, face="bold"))+ theme(legend.position="bottom")
#+ geom_vline(aes(xintercept = 0,linetype = "Nash"), show.legend=FALSE) +scale_linetype_manual(values =c( "Nash" = "dashed")) +scale_colour_manual(values = c("Nash"="black"))



## Plot mean catch pledge

P_meancatchpledge=ggplot(ggplot_XP_irv26b86[which(ggplot_XP_irv26b86$variable=='group_meancatchpledge'),], 
                         aes(x=as.numeric(ggplot_XP_irv26b86$value[which(ggplot_XP_irv26b86$variable=='subsession_round')]),
                             y=as.numeric(ggplot_XP_irv26b86$value[which(ggplot_XP_irv26b86$variable=='group_meancatchpledge')])))

P_meancatchpledge = P_meancatchpledge + geom_line() +ylim(0,15)+ xlim(0,15)+
  ylab("Mean Harvest Pledge (UVS)") + xlab("Round (Year)") +
  theme_classic()+ theme(legend.text = element_text(colour="black", size=10, face="bold"))+ theme(legend.position="bottom")
#+ geom_vline(aes(xintercept = 0,linetype = "Nash"), show.legend=FALSE) +scale_linetype_manual(values =c( "Nash" = "dashed")) +scale_colour_manual(values = c("Nash"="black"))


## Plot total catch

P_totalcatch=ggplot(ggplot_XP_irv26b86[which(ggplot_XP_irv26b86$variable=='group_totalcatch'),], 
                    aes(x=as.numeric(ggplot_XP_irv26b86$value[which(ggplot_XP_irv26b86$variable=='subsession_round')]),
                        y=as.numeric(ggplot_XP_irv26b86$value[which(ggplot_XP_irv26b86$variable=='group_totalcatch')])))

P_totalcatch =P_totalcatch + geom_line()+ylim(0,15)+ xlim(0,15)+
  ylab("Total Harvest (UVS)") + xlab("Round (Year)") +
  theme_classic()+ theme(legend.text = element_text(colour="black", size=10, face="bold"))+ theme(legend.position="bottom")
#+ geom_vline(aes(xintercept = 0,linetype = "Nash"), show.legend=FALSE) +scale_linetype_manual(values =c( "Nash" = "dashed")) +scale_colour_manual(values = c("Nash"="black"))


## Plot mean catch

P_meancatch=ggplot(ggplot_XP_irv26b86[which(ggplot_XP_irv26b86$variable=='group_meancatch'),], 
                   aes(x=as.numeric(ggplot_XP_irv26b86$value[which(ggplot_XP_irv26b86$variable=='subsession_round')]),
                       y=as.numeric(ggplot_XP_irv26b86$value[which(ggplot_XP_irv26b86$variable=='group_meancatch')])))

P_meancatch = P_meancatch + geom_line() +ylim(0,15)+ xlim(0,15)+
  ylab("Mean Harvest (UVS)") + xlab("Round (Year)") +
  theme_classic()+ theme(legend.text = element_text(colour="black", size=10, face="bold"))+ theme(legend.position="bottom")
#+ geom_vline(aes(xintercept = 0,linetype = "Nash"), show.legend=FALSE) +scale_linetype_manual(values =c( "Nash" = "dashed")) +scale_colour_manual(values = c("Nash"="black"))


## Plot ind profit

P_profit=ggplot(ggplot_XP_irv26b86[which(ggplot_XP_irv26b86$variable=='player_profit'),], 
                aes(x=as.numeric(ggplot_XP_irv26b86$value[which(ggplot_XP_irv26b86$variable=='subsession_round')]),
                    as.numeric(ggplot_XP_irv26b86$value[which(ggplot_XP_irv26b86$variable=='player_profit')]),
                    group=as.factor(ggplot_XP_irv26b86$value[which(ggplot_XP_irv26b86$variable=='player_id')]),
                    colour=as.factor(ggplot_XP_irv26b86$value[which(ggplot_XP_irv26b86$variable=='player_id')]),
                    fill=as.factor(ggplot_XP_irv26b86$value[which(ggplot_XP_irv26b86$variable=='player_id')])))

P_profit=P_profit + geom_line()+ylim(0,6)+ xlim(0,15)+
  scale_colour_discrete(name  ="Coalitions")+
  ylab("Profit (UVM)") + xlab("Round (Year)") +
  theme_classic()+ theme(legend.text = element_text(colour="black", size=10, face="bold"))+ theme(legend.position="bottom")
#+ geom_vline(aes(xintercept = 0,linetype = "Nash"), show.legend=FALSE) +scale_linetype_manual(values =c( "Nash" = "dashed")) +scale_colour_manual(values = c("Nash"="black"))


## Plot mean profit

P_meanprofit=ggplot(ggplot_XP_irv26b86[which(ggplot_XP_irv26b86$variable=='group_meanprofit'),], 
                    aes(x=as.numeric(ggplot_XP_irv26b86$value[which(ggplot_XP_irv26b86$variable=='subsession_round')]),
                        y=as.numeric(ggplot_XP_irv26b86$value[which(ggplot_XP_irv26b86$variable=='group_meanprofit')])))

P_meanprofit = P_meanprofit + geom_line() + ylim(0,6)+ xlim(0,15)+
  ylab("Mean Profit (UVM)") + xlab("Round (Year)") +
  theme_classic()+ theme(legend.text = element_text(colour="black", size=10, face="bold"))+ theme(legend.position="bottom")
#+ geom_vline(aes(xintercept = 0,linetype = "Nash"), show.legend=FALSE) +scale_linetype_manual(values =c( "Nash" = "dashed")) +scale_colour_manual(values = c("Nash"="black"))



## Plot total profit

P_totalprofit=ggplot(ggplot_XP_irv26b86[which(ggplot_XP_irv26b86$variable=='group_totalprofit'),], 
                     aes(x=as.numeric(ggplot_XP_irv26b86$value[which(ggplot_XP_irv26b86$variable=='subsession_round')]),
                         y=as.numeric(ggplot_XP_irv26b86$value[which(ggplot_XP_irv26b86$variable=='group_totalprofit')])))

P_totalprofit= P_totalprofit + geom_line()+ylim(0,6)+ xlim(0,15)+
  ylab("Total Profit (UVM)") + xlab("Round (Year)") +
  theme_classic()+ theme(legend.text = element_text(colour="black", size=10, face="bold"))+ theme(legend.position="bottom")


## Plot biomass

P_biomasse=ggplot(ggplot_XP_irv26b86[which(ggplot_XP_irv26b86$variable=='group_biomasse'),], 
                  aes(x=as.numeric(ggplot_XP_irv26b86$value[which(ggplot_XP_irv26b86$variable=='subsession_round')]),
                      y=as.numeric(ggplot_XP_irv26b86$value[which(ggplot_XP_irv26b86$variable=='group_biomasse')])))

P_biomasse= P_biomasse + geom_line() + ylim(0,30) + xlim(0,15) +
  ylab("Biomass (UVS)") + xlab("Round (Year)") +
  theme_classic()+ theme(legend.text = element_text(colour="black", size=10, face="bold"))+ theme(legend.position="bottom")


if (do.save==TRUE){jpeg(filename=paste(path.fig,"Gr1_p2_T0.jpg",sep=""),width = 2500, height = 2500,res = 300)}

grid.arrange(P_catch, P_profit , P_catchpledge, P_totalcatch, P_totalprofit , P_biomasse, P_meancatchpledge, P_meancatch,P_meanprofit, ncol=3, top = "Group 1: T0 | phase 2")

if (do.save==TRUE){dev.off()}


##--------------------------------------------------
##--------------------------------------------------

##--------------------------------------------------
## Session: ifdimqu3  / Group 2 / p1 T1 / Girardot, Perez , Prim /

##---------------------
## rearrange to plot with ggplot 
ggplot_XP_ifdimqu3=melt(xp1_ifdimqu3,id=c('participant_roundnumber','participant_id','participant_code','participant_appname',
                                                      'session_code','player_name', 'player_age', 'player_profession'))

#-----------------
## plot 

## Plot ind catch

P_catch=ggplot(ggplot_XP_ifdimqu3[which(ggplot_XP_ifdimqu3$variable=='player_catchchoice'),], 
               aes(as.numeric(ggplot_XP_ifdimqu3$value[which(ggplot_XP_ifdimqu3$variable=='subsession_round')]),
                   as.numeric(ggplot_XP_ifdimqu3$value[which(ggplot_XP_ifdimqu3$variable=='player_catchchoice')]),
                   group=as.factor(ggplot_XP_ifdimqu3$value[which(ggplot_XP_ifdimqu3$variable=='player_id')]),
                   colour=as.factor(ggplot_XP_ifdimqu3$value[which(ggplot_XP_ifdimqu3$variable=='player_id')])))

P_catch =P_catch + geom_line()+ylim(0,15)+ xlim(0,20)+
  scale_colour_discrete(name  ="Coalitions")+
  ylab("Harvest (UVS)") + xlab("Round (Year)") +
  theme_classic()+ theme(legend.text = element_text(colour="black", size=10, face="bold"))+ theme(legend.position="bottom")
#+ geom_vline(aes(xintercept = 0,linetype = "Nash"), show.legend=FALSE) +scale_linetype_manual(values =c( "Nash" = "dashed")) +scale_colour_manual(values = c("Nash"="black"))


## Plot ind catch pledge 

P_catchpledge=ggplot(ggplot_XP_ifdimqu3[which(ggplot_XP_ifdimqu3$variable=='player_catchpledge'),], 
                     aes(as.numeric(ggplot_XP_ifdimqu3$value[which(ggplot_XP_ifdimqu3$variable=='subsession_round')]),
                         as.numeric(ggplot_XP_ifdimqu3$value[which(ggplot_XP_ifdimqu3$variable=='player_catchpledge')]),
                         group=as.factor(ggplot_XP_ifdimqu3$value[which(ggplot_XP_ifdimqu3$variable=='player_id')]),
                         colour=as.factor(ggplot_XP_ifdimqu3$value[which(ggplot_XP_ifdimqu3$variable=='player_id')])))

P_catchpledge = P_catchpledge + geom_line()+ylim(0,15)+ xlim(0,20)+
  scale_colour_discrete(name  ="Coalitions")+
  ylab("Harvest pledge (UVS)") + xlab("Round (Year)") +
  theme_classic()+ theme(legend.text = element_text(colour="black", size=10, face="bold"))+ theme(legend.position="bottom")
#+ geom_vline(aes(xintercept = 0,linetype = "Nash"), show.legend=FALSE) +scale_linetype_manual(values =c( "Nash" = "dashed")) +scale_colour_manual(values = c("Nash"="black"))



## Plot mean catch pledge

P_meancatchpledge=ggplot(ggplot_XP_ifdimqu3[which(ggplot_XP_ifdimqu3$variable=='group_meancatchpledge'),], 
                         aes(x=as.numeric(ggplot_XP_ifdimqu3$value[which(ggplot_XP_ifdimqu3$variable=='subsession_round')]),
                             y=as.numeric(ggplot_XP_ifdimqu3$value[which(ggplot_XP_ifdimqu3$variable=='group_meancatchpledge')])))

P_meancatchpledge = P_meancatchpledge + geom_line() +ylim(0,15)+ xlim(0,20)+
  ylab("Mean Harvest Pledge (UVS)") + xlab("Round (Year)") +
  theme_classic()+ theme(legend.text = element_text(colour="black", size=10, face="bold"))+ theme(legend.position="bottom")
#+ geom_vline(aes(xintercept = 0,linetype = "Nash"), show.legend=FALSE) +scale_linetype_manual(values =c( "Nash" = "dashed")) +scale_colour_manual(values = c("Nash"="black"))


## Plot total catch

P_totalcatch=ggplot(ggplot_XP_ifdimqu3[which(ggplot_XP_ifdimqu3$variable=='group_totalcatch'),], 
                    aes(x=as.numeric(ggplot_XP_ifdimqu3$value[which(ggplot_XP_ifdimqu3$variable=='subsession_round')]),
                        y=as.numeric(ggplot_XP_ifdimqu3$value[which(ggplot_XP_ifdimqu3$variable=='group_totalcatch')])))

P_totalcatch =P_totalcatch + geom_line()+ylim(0,15)+ xlim(0,20)+
  ylab("Total Harvest (UVS)") + xlab("Round (Year)") +
  theme_classic()+ theme(legend.text = element_text(colour="black", size=10, face="bold"))+ theme(legend.position="bottom")
#+ geom_vline(aes(xintercept = 0,linetype = "Nash"), show.legend=FALSE) +scale_linetype_manual(values =c( "Nash" = "dashed")) +scale_colour_manual(values = c("Nash"="black"))


## Plot mean catch

P_meancatch=ggplot(ggplot_XP_ifdimqu3[which(ggplot_XP_ifdimqu3$variable=='group_meancatch'),], 
                   aes(x=as.numeric(ggplot_XP_ifdimqu3$value[which(ggplot_XP_ifdimqu3$variable=='subsession_round')]),
                       y=as.numeric(ggplot_XP_ifdimqu3$value[which(ggplot_XP_ifdimqu3$variable=='group_meancatch')])))

P_meancatch = P_meancatch + geom_line() +ylim(0,15)+ xlim(0,20)+
  ylab("Mean Harvest (UVS)") + xlab("Round (Year)") +
  theme_classic()+ theme(legend.text = element_text(colour="black", size=10, face="bold"))+ theme(legend.position="bottom")
#+ geom_vline(aes(xintercept = 0,linetype = "Nash"), show.legend=FALSE) +scale_linetype_manual(values =c( "Nash" = "dashed")) +scale_colour_manual(values = c("Nash"="black"))


## Plot ind profit

P_profit=ggplot(ggplot_XP_ifdimqu3[which(ggplot_XP_ifdimqu3$variable=='player_profit'),], 
                aes(x=as.numeric(ggplot_XP_ifdimqu3$value[which(ggplot_XP_ifdimqu3$variable=='subsession_round')]),
                    as.numeric(ggplot_XP_ifdimqu3$value[which(ggplot_XP_ifdimqu3$variable=='player_profit')]),
                    group=as.factor(ggplot_XP_ifdimqu3$value[which(ggplot_XP_ifdimqu3$variable=='player_id')]),
                    colour=as.factor(ggplot_XP_ifdimqu3$value[which(ggplot_XP_ifdimqu3$variable=='player_id')]),
                    fill=as.factor(ggplot_XP_ifdimqu3$value[which(ggplot_XP_ifdimqu3$variable=='player_id')])))

P_profit=P_profit + geom_line()+ylim(0,6)+ xlim(0,20)+
  scale_colour_discrete(name  ="Coalitions")+
  ylab("Profit (UVM)") + xlab("Round (Year)") +
  theme_classic()+ theme(legend.text = element_text(colour="black", size=10, face="bold"))+ theme(legend.position="bottom")
#+ geom_vline(aes(xintercept = 0,linetype = "Nash"), show.legend=FALSE) +scale_linetype_manual(values =c( "Nash" = "dashed")) +scale_colour_manual(values = c("Nash"="black"))


## Plot mean profit

P_meanprofit=ggplot(ggplot_XP_ifdimqu3[which(ggplot_XP_ifdimqu3$variable=='group_meanprofit'),], 
                    aes(x=as.numeric(ggplot_XP_ifdimqu3$value[which(ggplot_XP_ifdimqu3$variable=='subsession_round')]),
                        y=as.numeric(ggplot_XP_ifdimqu3$value[which(ggplot_XP_ifdimqu3$variable=='group_meanprofit')])))

P_meanprofit = P_meanprofit + geom_line() + ylim(0,6)+ xlim(0,20)+
  ylab("Mean Profit (UVM)") + xlab("Round (Year)") +
  theme_classic()+ theme(legend.text = element_text(colour="black", size=10, face="bold"))+ theme(legend.position="bottom")
#+ geom_vline(aes(xintercept = 0,linetype = "Nash"), show.legend=FALSE) +scale_linetype_manual(values =c( "Nash" = "dashed")) +scale_colour_manual(values = c("Nash"="black"))



## Plot total profit

P_totalprofit=ggplot(ggplot_XP_ifdimqu3[which(ggplot_XP_ifdimqu3$variable=='group_totalprofit'),], 
                     aes(x=as.numeric(ggplot_XP_ifdimqu3$value[which(ggplot_XP_ifdimqu3$variable=='subsession_round')]),
                         y=as.numeric(ggplot_XP_ifdimqu3$value[which(ggplot_XP_ifdimqu3$variable=='group_totalprofit')])))

P_totalprofit= P_totalprofit + geom_line()+ylim(0,6)+ xlim(0,20)+
  ylab("Total Profit (UVM)") + xlab("Round (Year)") +
  theme_classic()+ theme(legend.text = element_text(colour="black", size=10, face="bold"))+ theme(legend.position="bottom")


## Plot biomass

P_biomasse=ggplot(ggplot_XP_ifdimqu3[which(ggplot_XP_ifdimqu3$variable=='group_biomasse'),], 
                  aes(x=as.numeric(ggplot_XP_ifdimqu3$value[which(ggplot_XP_ifdimqu3$variable=='subsession_round')]),
                      y=as.numeric(ggplot_XP_ifdimqu3$value[which(ggplot_XP_ifdimqu3$variable=='group_biomasse')])))

P_biomasse= P_biomasse + geom_line() + ylim(0,30) + xlim(0,20) +
  ylab("Biomass (UVS)") + xlab("Round (Year)") +
  theme_classic()+ theme(legend.text = element_text(colour="black", size=10, face="bold"))+ theme(legend.position="bottom")


if (do.save==TRUE){jpeg(filename=paste(path.fig,"Gr2_p1_T1.jpg",sep=""),width = 2500, height = 2500,res = 300)}

grid.arrange(P_catch, P_profit , P_catchpledge, P_totalcatch, P_totalprofit , P_biomasse, P_meancatchpledge, P_meancatch,P_meanprofit, ncol=3, top = "Group 2: T1 | phase 1")

if (do.save==TRUE){dev.off()}


##--------------------------------------------------
##--------------------------------------------------

##--------------------------------------------------
## Session: ifdimqu3  / Group 2 / p2 T1 / Girardot, Perez , Prim / 


##---------------------
## rearrange to plot with ggplot 
ggplot_XP_ifdimqu3=melt(xp2_ifdimqu3,id=c('participant_roundnumber','participant_id','participant_code','participant_appname',
                                                      'session_code','player_name', 'player_age', 'player_profession'))

#-----------------
## plot 

## Plot ind catch

P_catch=ggplot(ggplot_XP_ifdimqu3[which(ggplot_XP_ifdimqu3$variable=='player_catchchoice'),], 
               aes(as.numeric(ggplot_XP_ifdimqu3$value[which(ggplot_XP_ifdimqu3$variable=='subsession_round')]),
                   as.numeric(ggplot_XP_ifdimqu3$value[which(ggplot_XP_ifdimqu3$variable=='player_catchchoice')]),
                   group=as.factor(ggplot_XP_ifdimqu3$value[which(ggplot_XP_ifdimqu3$variable=='player_id')]),
                   colour=as.factor(ggplot_XP_ifdimqu3$value[which(ggplot_XP_ifdimqu3$variable=='player_id')])))

P_catch =P_catch + geom_line()+ylim(0,15)+ xlim(0,15)+
  scale_colour_discrete(name  ="Coalitions")+
  ylab("Harvest (UVS)") + xlab("Round (Year)") +
  theme_classic()+ theme(legend.text = element_text(colour="black", size=10, face="bold"))+ theme(legend.position="bottom")
#+ geom_vline(aes(xintercept = 0,linetype = "Nash"), show.legend=FALSE) +scale_linetype_manual(values =c( "Nash" = "dashed")) +scale_colour_manual(values = c("Nash"="black"))


## Plot ind catch pledge 

P_catchpledge=ggplot(ggplot_XP_ifdimqu3[which(ggplot_XP_ifdimqu3$variable=='player_catchpledge'),], 
                     aes(as.numeric(ggplot_XP_ifdimqu3$value[which(ggplot_XP_ifdimqu3$variable=='subsession_round')]),
                         as.numeric(ggplot_XP_ifdimqu3$value[which(ggplot_XP_ifdimqu3$variable=='player_catchpledge')]),
                         group=as.factor(ggplot_XP_ifdimqu3$value[which(ggplot_XP_ifdimqu3$variable=='player_id')]),
                         colour=as.factor(ggplot_XP_ifdimqu3$value[which(ggplot_XP_ifdimqu3$variable=='player_id')])))

P_catchpledge = P_catchpledge + geom_line()+ylim(0,15)+ xlim(0,15)+
  scale_colour_discrete(name  ="Coalitions")+
  ylab("Harvest pledge (UVS)") + xlab("Round (Year)") +
  theme_classic()+ theme(legend.text = element_text(colour="black", size=10, face="bold"))+ theme(legend.position="bottom")
#+ geom_vline(aes(xintercept = 0,linetype = "Nash"), show.legend=FALSE) +scale_linetype_manual(values =c( "Nash" = "dashed")) +scale_colour_manual(values = c("Nash"="black"))



## Plot mean catch pledge

P_meancatchpledge=ggplot(ggplot_XP_ifdimqu3[which(ggplot_XP_ifdimqu3$variable=='group_meancatchpledge'),], 
                         aes(x=as.numeric(ggplot_XP_ifdimqu3$value[which(ggplot_XP_ifdimqu3$variable=='subsession_round')]),
                             y=as.numeric(ggplot_XP_ifdimqu3$value[which(ggplot_XP_ifdimqu3$variable=='group_meancatchpledge')])))

P_meancatchpledge = P_meancatchpledge + geom_line() +ylim(0,15)+ xlim(0,15)+
  ylab("Mean Harvest Pledge (UVS)") + xlab("Round (Year)") +
  theme_classic()+ theme(legend.text = element_text(colour="black", size=10, face="bold"))+ theme(legend.position="bottom")
#+ geom_vline(aes(xintercept = 0,linetype = "Nash"), show.legend=FALSE) +scale_linetype_manual(values =c( "Nash" = "dashed")) +scale_colour_manual(values = c("Nash"="black"))


## Plot total catch

P_totalcatch=ggplot(ggplot_XP_ifdimqu3[which(ggplot_XP_ifdimqu3$variable=='group_totalcatch'),], 
                    aes(x=as.numeric(ggplot_XP_ifdimqu3$value[which(ggplot_XP_ifdimqu3$variable=='subsession_round')]),
                        y=as.numeric(ggplot_XP_ifdimqu3$value[which(ggplot_XP_ifdimqu3$variable=='group_totalcatch')])))

P_totalcatch =P_totalcatch + geom_line()+ylim(0,15)+ xlim(0,15)+
  ylab("Total Harvest (UVS)") + xlab("Round (Year)") +
  theme_classic()+ theme(legend.text = element_text(colour="black", size=10, face="bold"))+ theme(legend.position="bottom")
#+ geom_vline(aes(xintercept = 0,linetype = "Nash"), show.legend=FALSE) +scale_linetype_manual(values =c( "Nash" = "dashed")) +scale_colour_manual(values = c("Nash"="black"))


## Plot mean catch

P_meancatch=ggplot(ggplot_XP_ifdimqu3[which(ggplot_XP_ifdimqu3$variable=='group_meancatch'),], 
                   aes(x=as.numeric(ggplot_XP_ifdimqu3$value[which(ggplot_XP_ifdimqu3$variable=='subsession_round')]),
                       y=as.numeric(ggplot_XP_ifdimqu3$value[which(ggplot_XP_ifdimqu3$variable=='group_meancatch')])))

P_meancatch = P_meancatch + geom_line() +ylim(0,15)+ xlim(0,15)+
  ylab("Mean Harvest (UVS)") + xlab("Round (Year)") +
  theme_classic()+ theme(legend.text = element_text(colour="black", size=10, face="bold"))+ theme(legend.position="bottom")
#+ geom_vline(aes(xintercept = 0,linetype = "Nash"), show.legend=FALSE) +scale_linetype_manual(values =c( "Nash" = "dashed")) +scale_colour_manual(values = c("Nash"="black"))


## Plot ind profit

P_profit=ggplot(ggplot_XP_ifdimqu3[which(ggplot_XP_ifdimqu3$variable=='player_profit'),], 
                aes(x=as.numeric(ggplot_XP_ifdimqu3$value[which(ggplot_XP_ifdimqu3$variable=='subsession_round')]),
                    as.numeric(ggplot_XP_ifdimqu3$value[which(ggplot_XP_ifdimqu3$variable=='player_profit')]),
                    group=as.factor(ggplot_XP_ifdimqu3$value[which(ggplot_XP_ifdimqu3$variable=='player_id')]),
                    colour=as.factor(ggplot_XP_ifdimqu3$value[which(ggplot_XP_ifdimqu3$variable=='player_id')]),
                    fill=as.factor(ggplot_XP_ifdimqu3$value[which(ggplot_XP_ifdimqu3$variable=='player_id')])))

P_profit=P_profit + geom_line()+ylim(0,6)+ xlim(0,15)+
  scale_colour_discrete(name  ="Coalitions")+
  ylab("Profit (UVM)") + xlab("Round (Year)") +
  theme_classic()+ theme(legend.text = element_text(colour="black", size=10, face="bold"))+ theme(legend.position="bottom")
#+ geom_vline(aes(xintercept = 0,linetype = "Nash"), show.legend=FALSE) +scale_linetype_manual(values =c( "Nash" = "dashed")) +scale_colour_manual(values = c("Nash"="black"))


## Plot mean profit

P_meanprofit=ggplot(ggplot_XP_ifdimqu3[which(ggplot_XP_ifdimqu3$variable=='group_meanprofit'),], 
                    aes(x=as.numeric(ggplot_XP_ifdimqu3$value[which(ggplot_XP_ifdimqu3$variable=='subsession_round')]),
                        y=as.numeric(ggplot_XP_ifdimqu3$value[which(ggplot_XP_ifdimqu3$variable=='group_meanprofit')])))

P_meanprofit = P_meanprofit + geom_line() + ylim(0,6)+ xlim(0,15)+
  ylab("Mean Profit (UVM)") + xlab("Round (Year)") +
  theme_classic()+ theme(legend.text = element_text(colour="black", size=10, face="bold"))+ theme(legend.position="bottom")
#+ geom_vline(aes(xintercept = 0,linetype = "Nash"), show.legend=FALSE) +scale_linetype_manual(values =c( "Nash" = "dashed")) +scale_colour_manual(values = c("Nash"="black"))



## Plot total profit

P_totalprofit=ggplot(ggplot_XP_ifdimqu3[which(ggplot_XP_ifdimqu3$variable=='group_totalprofit'),], 
                     aes(x=as.numeric(ggplot_XP_ifdimqu3$value[which(ggplot_XP_ifdimqu3$variable=='subsession_round')]),
                         y=as.numeric(ggplot_XP_ifdimqu3$value[which(ggplot_XP_ifdimqu3$variable=='group_totalprofit')])))

P_totalprofit= P_totalprofit + geom_line()+ylim(0,6)+ xlim(0,15)+
  ylab("Total Profit (UVM)") + xlab("Round (Year)") +
  theme_classic()+ theme(legend.text = element_text(colour="black", size=10, face="bold"))+ theme(legend.position="bottom")


## Plot biomass

P_biomasse=ggplot(ggplot_XP_ifdimqu3[which(ggplot_XP_ifdimqu3$variable=='group_biomasse'),], 
                  aes(x=as.numeric(ggplot_XP_ifdimqu3$value[which(ggplot_XP_ifdimqu3$variable=='subsession_round')]),
                      y=as.numeric(ggplot_XP_ifdimqu3$value[which(ggplot_XP_ifdimqu3$variable=='group_biomasse')])))

P_biomasse= P_biomasse + geom_line() + ylim(0,30) + xlim(0,15) +
  ylab("Biomass (UVS)") + xlab("Round (Year)") +
  theme_classic()+ theme(legend.text = element_text(colour="black", size=10, face="bold"))+ theme(legend.position="bottom")


if (do.save==TRUE){jpeg(filename=paste(path.fig,"Gr2_p2_T1.jpg",sep=""),width = 2500, height = 2500,res = 300)}

grid.arrange(P_catch, P_profit , P_catchpledge, P_totalcatch, P_totalprofit , P_biomasse, P_meancatchpledge, P_meancatch,P_meanprofit, ncol=3, top = "Group 2: T1 | phase 2")

if (do.save==TRUE){dev.off()}




##--------------------------------------------------
##--------------------------------------------------

##--------------------------------------------------
## Session: x8py2yrx  / Group 3 / p1 T2 / Astrid, M.Soscian , J.Salvetat / 


##---------------------
## rearrange to plot with ggplot 
ggplot_XP_x8py2yrx=melt(xp1_x8py2yrx,id=c('participant_roundnumber','participant_id','participant_code','participant_appname',
                                           'session_code','player_name', 'player_age', 'player_profession'))

#-----------------
## plot 

## Plot ind catch

P_catch=ggplot(ggplot_XP_x8py2yrx[which(ggplot_XP_x8py2yrx$variable=='player_catchchoice'),], 
               aes(as.numeric(ggplot_XP_x8py2yrx$value[which(ggplot_XP_x8py2yrx$variable=='subsession_round')]),
                   as.numeric(ggplot_XP_x8py2yrx$value[which(ggplot_XP_x8py2yrx$variable=='player_catchchoice')]),
                   group=as.factor(ggplot_XP_x8py2yrx$value[which(ggplot_XP_x8py2yrx$variable=='player_id')]),
                   colour=as.factor(ggplot_XP_x8py2yrx$value[which(ggplot_XP_x8py2yrx$variable=='player_id')])))

P_catch =P_catch + geom_line()+ylim(0,15)+ xlim(0,15)+
  scale_colour_discrete(name  ="Coalitions")+
  ylab("Harvest (UVS)") + xlab("Round (Year)") +
  theme_classic()+ theme(legend.text = element_text(colour="black", size=10, face="bold"))+ theme(legend.position="bottom")
#+ geom_vline(aes(xintercept = 0,linetype = "Nash"), show.legend=FALSE) +scale_linetype_manual(values =c( "Nash" = "dashed")) +scale_colour_manual(values = c("Nash"="black"))


## Plot ind catch pledge 

P_catchpledge=ggplot(ggplot_XP_x8py2yrx[which(ggplot_XP_x8py2yrx$variable=='player_catchpledge'),], 
                     aes(as.numeric(ggplot_XP_x8py2yrx$value[which(ggplot_XP_x8py2yrx$variable=='subsession_round')]),
                         as.numeric(ggplot_XP_x8py2yrx$value[which(ggplot_XP_x8py2yrx$variable=='player_catchpledge')]),
                         group=as.factor(ggplot_XP_x8py2yrx$value[which(ggplot_XP_x8py2yrx$variable=='player_id')]),
                         colour=as.factor(ggplot_XP_x8py2yrx$value[which(ggplot_XP_x8py2yrx$variable=='player_id')])))

P_catchpledge = P_catchpledge + geom_line()+ylim(0,15)+ xlim(0,15)+
  scale_colour_discrete(name  ="Coalitions")+
  ylab("Harvest pledge (UVS)") + xlab("Round (Year)") +
  theme_classic()+ theme(legend.text = element_text(colour="black", size=10, face="bold"))+ theme(legend.position="bottom")
#+ geom_vline(aes(xintercept = 0,linetype = "Nash"), show.legend=FALSE) +scale_linetype_manual(values =c( "Nash" = "dashed")) +scale_colour_manual(values = c("Nash"="black"))



## Plot mean catch pledge

P_meancatchpledge=ggplot(ggplot_XP_x8py2yrx[which(ggplot_XP_x8py2yrx$variable=='group_meancatchpledge'),], 
                         aes(x=as.numeric(ggplot_XP_x8py2yrx$value[which(ggplot_XP_x8py2yrx$variable=='subsession_round')]),
                             y=as.numeric(ggplot_XP_x8py2yrx$value[which(ggplot_XP_x8py2yrx$variable=='group_meancatchpledge')])))

P_meancatchpledge = P_meancatchpledge + geom_line() +ylim(0,15)+ xlim(0,15)+
  ylab("Mean Harvest Pledge (UVS)") + xlab("Round (Year)") +
  theme_classic()+ theme(legend.text = element_text(colour="black", size=10, face="bold"))+ theme(legend.position="bottom")
#+ geom_vline(aes(xintercept = 0,linetype = "Nash"), show.legend=FALSE) +scale_linetype_manual(values =c( "Nash" = "dashed")) +scale_colour_manual(values = c("Nash"="black"))


## Plot total catch

P_totalcatch=ggplot(ggplot_XP_x8py2yrx[which(ggplot_XP_x8py2yrx$variable=='group_totalcatch'),], 
                    aes(x=as.numeric(ggplot_XP_x8py2yrx$value[which(ggplot_XP_x8py2yrx$variable=='subsession_round')]),
                        y=as.numeric(ggplot_XP_x8py2yrx$value[which(ggplot_XP_x8py2yrx$variable=='group_totalcatch')])))

P_totalcatch =P_totalcatch + geom_line()+ylim(0,15)+ xlim(0,15)+
  ylab("Total Harvest (UVS)") + xlab("Round (Year)") +
  theme_classic()+ theme(legend.text = element_text(colour="black", size=10, face="bold"))+ theme(legend.position="bottom")
#+ geom_vline(aes(xintercept = 0,linetype = "Nash"), show.legend=FALSE) +scale_linetype_manual(values =c( "Nash" = "dashed")) +scale_colour_manual(values = c("Nash"="black"))


## Plot mean catch

P_meancatch=ggplot(ggplot_XP_x8py2yrx[which(ggplot_XP_x8py2yrx$variable=='group_meancatch'),], 
                   aes(x=as.numeric(ggplot_XP_x8py2yrx$value[which(ggplot_XP_x8py2yrx$variable=='subsession_round')]),
                       y=as.numeric(ggplot_XP_x8py2yrx$value[which(ggplot_XP_x8py2yrx$variable=='group_meancatch')])))

P_meancatch = P_meancatch + geom_line() +ylim(0,15)+ xlim(0,15)+
  ylab("Mean Harvest (UVS)") + xlab("Round (Year)") +
  theme_classic()+ theme(legend.text = element_text(colour="black", size=10, face="bold"))+ theme(legend.position="bottom")
#+ geom_vline(aes(xintercept = 0,linetype = "Nash"), show.legend=FALSE) +scale_linetype_manual(values =c( "Nash" = "dashed")) +scale_colour_manual(values = c("Nash"="black"))


## Plot ind profit

P_profit=ggplot(ggplot_XP_x8py2yrx[which(ggplot_XP_x8py2yrx$variable=='player_profit'),], 
                aes(x=as.numeric(ggplot_XP_x8py2yrx$value[which(ggplot_XP_x8py2yrx$variable=='subsession_round')]),
                    as.numeric(ggplot_XP_x8py2yrx$value[which(ggplot_XP_x8py2yrx$variable=='player_profit')]),
                    group=as.factor(ggplot_XP_x8py2yrx$value[which(ggplot_XP_x8py2yrx$variable=='player_id')]),
                    colour=as.factor(ggplot_XP_x8py2yrx$value[which(ggplot_XP_x8py2yrx$variable=='player_id')]),
                    fill=as.factor(ggplot_XP_x8py2yrx$value[which(ggplot_XP_x8py2yrx$variable=='player_id')])))

P_profit=P_profit + geom_line()+ylim(0,6)+ xlim(0,15)+
  scale_colour_discrete(name  ="Coalitions")+
  ylab("Profit (UVM)") + xlab("Round (Year)") +
  theme_classic()+ theme(legend.text = element_text(colour="black", size=10, face="bold"))+ theme(legend.position="bottom")
#+ geom_vline(aes(xintercept = 0,linetype = "Nash"), show.legend=FALSE) +scale_linetype_manual(values =c( "Nash" = "dashed")) +scale_colour_manual(values = c("Nash"="black"))


## Plot mean profit

P_meanprofit=ggplot(ggplot_XP_x8py2yrx[which(ggplot_XP_x8py2yrx$variable=='group_meanprofit'),], 
                    aes(x=as.numeric(ggplot_XP_x8py2yrx$value[which(ggplot_XP_x8py2yrx$variable=='subsession_round')]),
                        y=as.numeric(ggplot_XP_x8py2yrx$value[which(ggplot_XP_x8py2yrx$variable=='group_meanprofit')])))

P_meanprofit = P_meanprofit + geom_line() + ylim(0,6)+ xlim(0,15)+
  ylab("Mean Profit (UVM)") + xlab("Round (Year)") +
  theme_classic()+ theme(legend.text = element_text(colour="black", size=10, face="bold"))+ theme(legend.position="bottom")
#+ geom_vline(aes(xintercept = 0,linetype = "Nash"), show.legend=FALSE) +scale_linetype_manual(values =c( "Nash" = "dashed")) +scale_colour_manual(values = c("Nash"="black"))



## Plot total profit

P_totalprofit=ggplot(ggplot_XP_x8py2yrx[which(ggplot_XP_x8py2yrx$variable=='group_totalprofit'),], 
                     aes(x=as.numeric(ggplot_XP_x8py2yrx$value[which(ggplot_XP_x8py2yrx$variable=='subsession_round')]),
                         y=as.numeric(ggplot_XP_x8py2yrx$value[which(ggplot_XP_x8py2yrx$variable=='group_totalprofit')])))

P_totalprofit= P_totalprofit + geom_line()+ylim(0,6)+ xlim(0,15)+
  ylab("Total Profit (UVM)") + xlab("Round (Year)") +
  theme_classic()+ theme(legend.text = element_text(colour="black", size=10, face="bold"))+ theme(legend.position="bottom")


## Plot biomass

P_biomasse=ggplot(ggplot_XP_x8py2yrx[which(ggplot_XP_x8py2yrx$variable=='group_biomasse'),], 
                  aes(x=as.numeric(ggplot_XP_x8py2yrx$value[which(ggplot_XP_x8py2yrx$variable=='subsession_round')]),
                      y=as.numeric(ggplot_XP_x8py2yrx$value[which(ggplot_XP_x8py2yrx$variable=='group_biomasse')])))

P_biomasse= P_biomasse + geom_line() + ylim(0,30) + xlim(0,15) +
  ylab("Biomass (UVS)") + xlab("Round (Year)") +
  theme_classic()+ theme(legend.text = element_text(colour="black", size=10, face="bold"))+ theme(legend.position="bottom")


if (do.save==TRUE){jpeg(filename=paste(path.fig,"Gr3_p1_T2.jpg",sep=""),width = 2500, height = 2500,res = 300)}

grid.arrange(P_catch, P_profit , P_catchpledge, P_totalcatch, P_totalprofit , P_biomasse, P_meancatchpledge, P_meancatch,P_meanprofit,
             ncol=3, top = "Group 3: T2 | phase 1")

if (do.save==TRUE){dev.off()}



##--------------------------------------------------
##--------------------------------------------------

##--------------------------------------------------
## Session: d7ux4n2a  / Group 3 / p2 t / Astrid, M.Soscian , J.Salvetat / 

##---------------------
## rearrange to plot with ggplot 
ggplot_XP_d7ux4n2a=melt(xp2_d7ux4n2a,id=c('participant_roundnumber','participant_id','participant_code','participant_appname',
                                           'session_code','player_name', 'player_age', 'player_profession'))

#-----------------
## plot 

## Plot ind catch

P_catch=ggplot(ggplot_XP_d7ux4n2a[which(ggplot_XP_d7ux4n2a$variable=='player_catchchoice'),], 
               aes(as.numeric(ggplot_XP_d7ux4n2a$value[which(ggplot_XP_d7ux4n2a$variable=='subsession_round')]),
                   as.numeric(ggplot_XP_d7ux4n2a$value[which(ggplot_XP_d7ux4n2a$variable=='player_catchchoice')]),
                   group=as.factor(ggplot_XP_d7ux4n2a$value[which(ggplot_XP_d7ux4n2a$variable=='player_id')]),
                   colour=as.factor(ggplot_XP_d7ux4n2a$value[which(ggplot_XP_d7ux4n2a$variable=='player_id')])))

P_catch =P_catch + geom_line()+ylim(0,15)+ xlim(0,15)+
  scale_colour_discrete(name  ="Coalitions")+
  ylab("Harvest (UVS)") + xlab("Round (Year)") +
  theme_classic()+ theme(legend.text = element_text(colour="black", size=10, face="bold"))+ theme(legend.position="bottom")
#+ geom_vline(aes(xintercept = 0,linetype = "Nash"), show.legend=FALSE) +scale_linetype_manual(values =c( "Nash" = "dashed")) +scale_colour_manual(values = c("Nash"="black"))


## Plot ind catch pledge 

P_catchpledge=ggplot(ggplot_XP_d7ux4n2a[which(ggplot_XP_d7ux4n2a$variable=='player_catchpledge'),], 
                     aes(as.numeric(ggplot_XP_d7ux4n2a$value[which(ggplot_XP_d7ux4n2a$variable=='subsession_round')]),
                         as.numeric(ggplot_XP_d7ux4n2a$value[which(ggplot_XP_d7ux4n2a$variable=='player_catchpledge')]),
                         group=as.factor(ggplot_XP_d7ux4n2a$value[which(ggplot_XP_d7ux4n2a$variable=='player_id')]),
                         colour=as.factor(ggplot_XP_d7ux4n2a$value[which(ggplot_XP_d7ux4n2a$variable=='player_id')])))

P_catchpledge = P_catchpledge + geom_line()+ylim(0,15)+ xlim(0,15)+
  scale_colour_discrete(name  ="Coalitions")+
  ylab("Harvest pledge (UVS)") + xlab("Round (Year)") +
  theme_classic()+ theme(legend.text = element_text(colour="black", size=10, face="bold"))+ theme(legend.position="bottom")
#+ geom_vline(aes(xintercept = 0,linetype = "Nash"), show.legend=FALSE) +scale_linetype_manual(values =c( "Nash" = "dashed")) +scale_colour_manual(values = c("Nash"="black"))



## Plot mean catch pledge

P_meancatchpledge=ggplot(ggplot_XP_d7ux4n2a[which(ggplot_XP_d7ux4n2a$variable=='group_meancatchpledge'),], 
                         aes(x=as.numeric(ggplot_XP_d7ux4n2a$value[which(ggplot_XP_d7ux4n2a$variable=='subsession_round')]),
                             y=as.numeric(ggplot_XP_d7ux4n2a$value[which(ggplot_XP_d7ux4n2a$variable=='group_meancatchpledge')])))

P_meancatchpledge = P_meancatchpledge + geom_line() +ylim(0,15)+ xlim(0,15)+
  ylab("Mean Harvest Pledge (UVS)") + xlab("Round (Year)") +
  theme_classic()+ theme(legend.text = element_text(colour="black", size=10, face="bold"))+ theme(legend.position="bottom")
#+ geom_vline(aes(xintercept = 0,linetype = "Nash"), show.legend=FALSE) +scale_linetype_manual(values =c( "Nash" = "dashed")) +scale_colour_manual(values = c("Nash"="black"))


## Plot total catch

P_totalcatch=ggplot(ggplot_XP_d7ux4n2a[which(ggplot_XP_d7ux4n2a$variable=='group_totalcatch'),], 
                    aes(x=as.numeric(ggplot_XP_d7ux4n2a$value[which(ggplot_XP_d7ux4n2a$variable=='subsession_round')]),
                        y=as.numeric(ggplot_XP_d7ux4n2a$value[which(ggplot_XP_d7ux4n2a$variable=='group_totalcatch')])))

P_totalcatch =P_totalcatch + geom_line()+ylim(0,15)+ xlim(0,15)+
  ylab("Total Harvest (UVS)") + xlab("Round (Year)") +
  theme_classic()+ theme(legend.text = element_text(colour="black", size=10, face="bold"))+ theme(legend.position="bottom")
#+ geom_vline(aes(xintercept = 0,linetype = "Nash"), show.legend=FALSE) +scale_linetype_manual(values =c( "Nash" = "dashed")) +scale_colour_manual(values = c("Nash"="black"))


## Plot mean catch

P_meancatch=ggplot(ggplot_XP_d7ux4n2a[which(ggplot_XP_d7ux4n2a$variable=='group_meancatch'),], 
                   aes(x=as.numeric(ggplot_XP_d7ux4n2a$value[which(ggplot_XP_d7ux4n2a$variable=='subsession_round')]),
                       y=as.numeric(ggplot_XP_d7ux4n2a$value[which(ggplot_XP_d7ux4n2a$variable=='group_meancatch')])))

P_meancatch = P_meancatch + geom_line() +ylim(0,15)+ xlim(0,15)+
  ylab("Mean Harvest (UVS)") + xlab("Round (Year)") +
  theme_classic()+ theme(legend.text = element_text(colour="black", size=10, face="bold"))+ theme(legend.position="bottom")
#+ geom_vline(aes(xintercept = 0,linetype = "Nash"), show.legend=FALSE) +scale_linetype_manual(values =c( "Nash" = "dashed")) +scale_colour_manual(values = c("Nash"="black"))


## Plot ind profit

P_profit=ggplot(ggplot_XP_d7ux4n2a[which(ggplot_XP_d7ux4n2a$variable=='player_profit'),], 
                aes(x=as.numeric(ggplot_XP_d7ux4n2a$value[which(ggplot_XP_d7ux4n2a$variable=='subsession_round')]),
                    as.numeric(ggplot_XP_d7ux4n2a$value[which(ggplot_XP_d7ux4n2a$variable=='player_profit')]),
                    group=as.factor(ggplot_XP_d7ux4n2a$value[which(ggplot_XP_d7ux4n2a$variable=='player_id')]),
                    colour=as.factor(ggplot_XP_d7ux4n2a$value[which(ggplot_XP_d7ux4n2a$variable=='player_id')]),
                    fill=as.factor(ggplot_XP_d7ux4n2a$value[which(ggplot_XP_d7ux4n2a$variable=='player_id')])))

P_profit=P_profit + geom_line()+ylim(0,6)+ xlim(0,15)+
  scale_colour_discrete(name  ="Coalitions")+
  ylab("Profit (UVM)") + xlab("Round (Year)") +
  theme_classic()+ theme(legend.text = element_text(colour="black", size=10, face="bold"))+ theme(legend.position="bottom")
#+ geom_vline(aes(xintercept = 0,linetype = "Nash"), show.legend=FALSE) +scale_linetype_manual(values =c( "Nash" = "dashed")) +scale_colour_manual(values = c("Nash"="black"))


## Plot mean profit

P_meanprofit=ggplot(ggplot_XP_d7ux4n2a[which(ggplot_XP_d7ux4n2a$variable=='group_meanprofit'),], 
                    aes(x=as.numeric(ggplot_XP_d7ux4n2a$value[which(ggplot_XP_d7ux4n2a$variable=='subsession_round')]),
                        y=as.numeric(ggplot_XP_d7ux4n2a$value[which(ggplot_XP_d7ux4n2a$variable=='group_meanprofit')])))

P_meanprofit = P_meanprofit + geom_line() + ylim(0,6)+ xlim(0,15)+
  ylab("Mean Profit (UVM)") + xlab("Round (Year)") +
  theme_classic()+ theme(legend.text = element_text(colour="black", size=10, face="bold"))+ theme(legend.position="bottom")
#+ geom_vline(aes(xintercept = 0,linetype = "Nash"), show.legend=FALSE) +scale_linetype_manual(values =c( "Nash" = "dashed")) +scale_colour_manual(values = c("Nash"="black"))



## Plot total profit

P_totalprofit=ggplot(ggplot_XP_d7ux4n2a[which(ggplot_XP_d7ux4n2a$variable=='group_totalprofit'),], 
                     aes(x=as.numeric(ggplot_XP_d7ux4n2a$value[which(ggplot_XP_d7ux4n2a$variable=='subsession_round')]),
                         y=as.numeric(ggplot_XP_d7ux4n2a$value[which(ggplot_XP_d7ux4n2a$variable=='group_totalprofit')])))

P_totalprofit= P_totalprofit + geom_line()+ylim(0,6)+ xlim(0,15)+
  ylab("Total Profit (UVM)") + xlab("Round (Year)") +
  theme_classic()+ theme(legend.text = element_text(colour="black", size=10, face="bold"))+ theme(legend.position="bottom")


## Plot biomass

P_biomasse=ggplot(ggplot_XP_d7ux4n2a[which(ggplot_XP_d7ux4n2a$variable=='group_biomasse'),], 
                  aes(x=as.numeric(ggplot_XP_d7ux4n2a$value[which(ggplot_XP_d7ux4n2a$variable=='subsession_round')]),
                      y=as.numeric(ggplot_XP_d7ux4n2a$value[which(ggplot_XP_d7ux4n2a$variable=='group_biomasse')])))

P_biomasse= P_biomasse + geom_line() + ylim(0,30) + xlim(0,15) +
  ylab("Biomass (UVS)") + xlab("Round (Year)") +
  theme_classic()+ theme(legend.text = element_text(colour="black", size=10, face="bold"))+ theme(legend.position="bottom")


if (do.save==TRUE){jpeg(filename=paste(path.fig,"Gr3_p2_T0.jpg",sep=""),width = 2500, height = 2500,res = 300)}

grid.arrange(P_catch, P_profit , P_catchpledge, P_totalcatch, P_totalprofit , P_biomasse, P_meancatchpledge, P_meancatch,P_meanprofit,
             ncol=3, top = "Group 3: T0 | phase 2")

if (do.save==TRUE){dev.off()}



