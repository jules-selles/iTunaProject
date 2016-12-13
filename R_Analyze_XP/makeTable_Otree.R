## function make session tablefrom OTree data

make.table.Otree <- function (xp.data, session, name, age, profession){
  

  xp = xp.data[which(xp.data$session_code==session),]
  xp=xp[order(xp[,which(colnames(xp)=='subsession_round')],decreasing =F),]
  
  
  
  ## complete age / name and profession field 
  
  # name
  xp$player_name=as.factor(xp$player_name)
  levels(xp$player_name)=c(levels(xp$player_name),name[1],name[2],name[3])
  xp$player_name[which(xp$participant_id=="P1")] = name[1]
  xp$player_name[which(xp$participant_id=="P2")] = name[2]
  xp$player_name[which(xp$participant_id=="P3")] = name[3]
  
  # age 
  xp$player_age=as.factor(xp$player_age)
  levels(xp$player_age)=c(levels(xp$player_age),age[1],age[2],age[3])
  xp$player_age[which(xp$participant_id=="P1")] = age[1]
  xp$player_age[which(xp$participant_id=="P2")] = age[2]
  xp$player_age[which(xp$participant_id=="P3")] = age[3]
  
  
  # profession
  xp$player_profession=as.factor(xp$player_profession)
  levels(xp$player_profession)=c(levels(xp$player_profession),profession[1],profession[2],profession[3])
  xp$player_profession[which(xp$participant_id=="P1")] = profession[1]
  xp$player_profession[which(xp$participant_id=="P2")] = profession[2]
  xp$player_profession[which(xp$participant_id=="P3")] = profession[3]
  
  
  # mean and sd : catch, catchpledge and profit 
  xp$group_meancatch=NULL
  xp$group_meancatchpledge=NULL
  xp$group_meanprofit=NULL
  xp$group_sdcatch=NULL
  xp$group_sdcatchpledge=NULL
  xp$group_sdprofit=NULL
  
  for (j in 1: length(xp$player_profit)){
    xp$group_meancatch[j] = mean(xp$player_catchchoice[which(xp$subsession_round==xp$subsession_round[j])],na.rm=TRUE)
    xp$group_meancatchpledge[j] = mean(xp$player_catchpledge[which(xp$subsession_round==xp$subsession_round[j])],na.rm=TRUE)
    xp$group_meanprofit[j] = mean(xp$player_profit[which(xp$subsession_round==xp$subsession_round[j])],na.rm=TRUE)
    
    xp$group_sdcatch[j] = sd(xp$player_catchchoice[which(xp$subsession_round==xp$subsession_round[j])],na.rm=TRUE)
    xp$group_sdcatchpledge[j] = sd(xp$player_catchpledge[which(xp$subsession_round==xp$subsession_round[j])],na.rm=TRUE)
    xp$group_sdprofit[j] = sd(xp$player_profit[which(xp$subsession_round==xp$subsession_round[j])],na.rm=TRUE)
  }
  
  
  # efficiency modulable by round in terme of profit subject t othe biomass level 
  
  eff_mod <- function(obs.catch,obs.profit,biomass,optB,nbPlayers){
    
    eq.catch=matrix(data=NA,ncol=length(obs.catch),nrow=0)
    eq.profit=matrix(data=NA,ncol=length(obs.catch),nrow=0)
    
    for (i in 1:length(obs.catch)){

      if (is.na(biomass[i])){
        eq.catch[i]   <- 0
        eq.profit[i]  <- Profitplot(catch=eq.catch[i],biomass = biomass[i])
      }else{
      
        if (biomass[i] == optB ){
          eq.catch[i]   <- growth(biomass[i])
          eq.profit[i]  <- Profitplot(catch=eq.catch[i],biomass = biomass[i])
          
        }else {
          if (round((biomass[i] - optB)/nbPlayers)* nbPlayers >= 0){
            eq.catch[i]   <- round((biomass[i] - optB)/nbPlayers)* nbPlayers
            eq.profit[i]  <- Profitplot(catch=eq.catch[i],biomass = biomass[i])
            
          }else{
            eq.catch[i]   <- 0
            eq.profit[i]  <- Profitplot(catch=eq.catch[i],biomass = biomass[i])
            
          }  
        }
      }
    }
    
    eff        <- (obs.profit/eq.profit)
    eff.tot    <- sum(obs.profit,na.rm=TRUE)/sum(eq.profit,na.rm=TRUE)
    
    data=list(eff=eff,eff.tot=eff.tot)
    
    return(data)
  }

  xp$eff_mod_round = eff_mod(obs.catch=xp$group_totalcatch,obs.profit=xp$group_totalprofit,biomass=xp$group_biomasse,optB=optB,nbPlayers=nbPlayers)$eff
  xp$eff_mod_total = eff_mod(obs.catch=xp$group_totalcatch,obs.profit=xp$group_totalprofit,biomass=xp$group_biomasse,optB=optB,nbPlayers=nbPlayers)$eff.tot
  

  # efficiency vs optimal path by round in term of profit subject to the biomass level 
  
  eff_opt <- function(obs.profit){
    
    eq.profit =  c(rep(prof[1],3),rep(prof[2],length(obs.profit)-3))
      
    eff       <- (obs.profit/eq.profit)
    eff.tot   <- sum(obs.profit,na.rm=TRUE)/sum(eq.profit,na.rm=TRUE)
    
    data=list(eff=eff,eff.tot=eff.tot)
    
    return(data)
  }
  
  xp$eff_round = eff_opt(obs.profit=xp$group_totalprofit)$eff
  xp$eff= eff_opt(obs.profit=xp$group_totalprofit)$eff.tot
  
  
  
  ##  deviation from optimum  ( profit deviation )
  
  path.prof.opt = c(rep(prof[1],3),rep(prof[2],length(xp$group_totalprofit)-3))
  
  xp$group_optProfDev = (xp$group_totalprofit - path.prof.opt)/ path.prof.opt
  
  ## efficiency ( profit efficiency )
  
  eq.profit =  c(rep(prof[1],3),rep(prof[2],length(xp$group_totalprofit)-3))
  
  xp$group_efficiency = (sum(xp$group_totalprofit,na.rm=T)/3)/ (sum(eq.profit,na.rm=T)/3)
  
  
  ## Over - under exploitation (based on MSY)
  
  xp$group_stateExploitation = xp$group_totalcatch / Ymsy
  
  
  ## prediction error & best response rate
  
  xp$player_predError = xp$player_otherchoice - (xp$group_totalcatch - xp$player_catchchoice) 
  
 # xp$player_bestRepDev   = 
  
  for (j in 1: length(xp$player_profit)){
    xp$player_meanpredError[j] = mean(xp$player_prederror[which(xp$subsession_round==xp$subsession_round[j])],na.rm=TRUE)
    
  }
  
  
  return(xp)

  
}




