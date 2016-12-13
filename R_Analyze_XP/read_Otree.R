## function extract raw data from OTree .csv 

extract_Otree_data <- function (path.data, table.name){
  
XP.data <- read.table(paste(path.data,table.name,sep = ""),header=TRUE,sep=",",quote = "'")

## data base
data <- NULL

## participant variables
data$participant_id          <-  XP.data$Participant._id_in_session
data$participant_code        <-  XP.data$Participant.code
data$participant_name        <-  XP.data$Participant.name
data$participant_appname     <-  XP.data$Participant._current_app_name
data$participant_roundnumber <-  XP.data$Participant._round_number
  
  ## session variables
data$session_code   <-  XP.data$Session.code
data$session_fee    <-  XP.data$Session.participation_fee
  
  ## Subsession variables
data$subsession_round   <-  XP.data$Subsession.round_number
  
  ## player variables
  
data$player_id           <-  XP.data$Player.id_in_group
data$player_payoff       <-  XP.data$Player.payoff
data$player_name         <-  XP.data$Player.name
data$player_age          <-  XP.data$Player.age
data$player_profession   <-  XP.data$Player.profession
data$player_profit       <-  XP.data$Player.profit
data$player_otherchoice  <-  XP.data$Player.other_choice
data$player_catchpledge  <-  XP.data$Player.catch_pledge
data$player_catchchoice  <-  XP.data$Player.catch_choice
  
  ## group variables
  
data$group_totalcatch    <-  XP.data$Group.total_catch
data$group_totalprofit   <-  XP.data$Group.total_profit
data$group_biomasse      <-  XP.data$Group.b_round
data$group_Blim_min      <-  XP.data$Group.Blim_min
data$group_Blim_max      <-  XP.data$Group.Blim_max

  return(data)
  
}