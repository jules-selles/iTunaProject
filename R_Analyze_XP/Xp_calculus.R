#####################################
### Model XP Gordon-Schaefer all calculation
### Selles Jules
### 08/2016
####################################

##---------------------------------
## Packages

# FLR package 
#source("C:/Users/jselles/Dropbox/These/These_Ifremer/BFT_DYNPop/OM_BFT/R.Script/Install.FLR.R")# 
#Install.FLR()
library(fields)
library(RColorBrewer)

# supplementary packages

##--------------------------------
## Parameters
##--------------------------------

path.plot <- "C:/Users/jselles/Dropbox/These/These_Ifremer/Documents_Travail/Modele_XP/XP_protocole/Protocole/"
do.save.plot=T
  
## Global parameters
simYear     <- 10
gameTime    <- 25

#---------------------------
initYear    <- 1990
uncertainty <- 0.5
nbPlayers   <- 3

## Schaefer parameters
K    <- 30
r    <- 0.8
Blim <- 8
Bmsy <- K/2
Ymsy <- (r*K)/4

## Economic parameters // métier purse seine only 
P               <- 1
beta            <- 13
treshold        <- F
A               <- 8
ta              <- 0
delta           <- 1/(1+ta)

maxHarvest      <- 5
minHarvest      <- 0 
nbChoices       <- 5

stepChoices     <- (maxHarvest - minHarvest)/(nbChoices - 1)
harvestChoice   <- seq(from=minHarvest,to=maxHarvest, by=stepChoices)
totalHarvest    <- seq(from=minHarvest,to=maxHarvest*nbPlayers,by=stepChoices)
otherHarvest    <- seq(from=minHarvest,to=maxHarvest*(nbPlayers),by= stepChoices)

##--------------------------------
## Model functions
##--------------------------------

## Schafer stantard model [10^3 t] 
##--------------------------------------------
##Biologic part
##
## growth function [t] 
growth  <- function (b,b1=r,b2=K){
  #b : biomass [t] // b1 : r -> growth rate [] // b2 : K -> carrying capacity [t]
  growth=b1*b*(1-(b/b2))
  growth <- round(growth,0)
  return(growth)
}

## Schaefer biomass dynamic [t] 
Schaefer <- function (b,C=0){
  #c : total catch [t]// b : biomasss [t]
  biomass <- b + growth(b=b)- C
  biomass <- round(biomass,0)
  return(biomass)
}

##Economic part
##
## Cost function [$] 
Cost <- function(stock,e1=beta,e2=A,b3=Blim ,capture=0,t= treshold){
#e1 : Beta cost parameter [] // e2 : fixed cost linked to Blim [$] // b3 : Blim biomass threshold [t]// b : biomass [t] //
#c : individual catch in tones [t]
     
  cost = matrix (NA, ncol=length(stock))
  
  for (i in 1: length(stock)){
    if (i==1){
      cost[i]<-e1*(log(Schaefer(K))-log(stock[i]))
     }else {
      cost[i]<-e1*(log(growth(b=stock[i-1]))-log(stock[i]))
    }
    
  }
  
  return(cost)
}

## Cost function [$] 
CostplotInd <- function(stock,e1=beta,e2=A,b3=Blim ,capture=0,
                        captureInd=0,t= treshold){
  #e1 : Beta cost parameter [] // e2 : fixed cost linked to Blim [$] // b3 : Blim biomass threshold [t]// b : biomass [t] //
  #c : individual catch in tones [t]
  
  cost = matrix (NA,nrow=length(capture), ncol=length(captureInd))
  
  for (i in 1:length(capture)){
    for (j in 1:length(captureInd)){
      cost[i,j]<-e1*(log(Schaefer(b=stock))-log(Schaefer(b=stock)-(capture[i]+captureInd[j])))*
              (captureInd[j]/(capture[i]+captureInd[j]))
       } 
    }
  
  #cost[which(cost=='Inf')]=0
  #cost[which(cost=='Nan')]=0
  #cost <- round(cost,0)
  
  return(cost)
}

## Cost function [$] 
Costplot <- function(stock,e1=beta,e2=A,b3=Blim ,capture=0,t= treshold){
  #e1 : Beta cost parameter [] // e2 : fixed cost linked to Blim [$] // b3 : Blim biomass threshold [t]// b : biomass [t] //
  #c : individual catch in tones [t]
  
  cost = matrix (NA,nrow=length(capture), ncol=length(stock))
  
  for (i in 1:length(capture)){
    cost[i,]<-e1*(log(Schaefer(b=stock))-log(Schaefer(b=stock)-capture[i]))
  } 
  
  #cost[which(cost=='Inf')]=0
  #cost[which(cost=='Nan')]=0
  #cost <- round(cost,0)
  
  return(cost)
}


## Gain function [$] 
Gain <- function(e3=P,c=0){
#e3 : cte fish price per Kg [$/t]// c : individual catch in tones [t]
  gain<- e3*c
  gain <- round(gain,0)
  return(gain)
}

## Profit function [10^3 $] 
Profit <- function (catch,biomass){
  profit <- Gain(c=catch) - CostPlotind(stock=biomass,capture=catch)
  profit <- round(profit,0)
  return(profit)
}

## Profit function [10^3 $] 
ProfitInd <- function (catch,catchInd,biomass){
  
  cc     = CostplotInd(stock=biomass,
                       capture=catch,captureInd=catchInd)
  profit = matrix(data=NA,nrow=dim(cc)[1],ncol=dim(cc)[2])
  
  for (i in 1:dim(cc)[1]){
    profit[i,] <- Gain(c=catchInd) - cc[i,]
    #profit <- round(profit,0)
  }
  profit = round(profit,1)
  
  return(profit)
}



## Profit function [10^3 $] 
Profitplot <- function (catch,biomass){
  profit <- Gain(c=catch) - Costplot(stock=biomass,capture=catch)
  profit <- round(profit,1)
  return(profit)
}


## Net Present Value function [10^3 $] 
NPV <- function(cashFlow, time, discountRate){
# cashFlow : profit for each period t until T (time) [10¨3 $] // time : [y] // discountRate : []
   netPresentValue <- cumsum(net/(1+discountRate)^time)
   return(netPresentValue)
}


#######################################
## Optimisation under constraint process
## Optimal value B0

f.PV <- function(x) {
  f.x <-  ( (delta* ( P - (beta/ (round(x,0) + round(r*x*(1-(x/K)),0) ) ) ) * (1+r*(1-(2*round(x,0)/K))) ) - (P-(beta/round(x,0))) )^2
  # return function value
  return(f.x)
}

out.B0 <- optimize(f.PV,lower = 1, upper = 30, tol = 0.0001)


B0   <- out.B0$minimum
Y0   <- growth(b=B0)


#######################################
## Optimisation under constraint process

## here markov chain analysis

optB=19 #round(B0) ( multiple de 3 obligatoirement)

prof = matrix(data = NA, nrow = 1, ncol = gameTime)

b0   = K
c0   = round((b0 - optB)/ nbPlayers)* nbPlayers  

b    = matrix(data = NA, nrow = 1, ncol = gameTime)
b[1] = b0
ca    = matrix(data = NA, nrow = 1, ncol = gameTime)
ca[1] = c0

for (i in 1:(gameTime - 1)){

    prof[i]   = Profitplot(catch= ca[i] ,biomass= b[i])
    
    b[i+1] = Schaefer(b=b[i],C=ca[i])
    ca[i+1] = growth(b=b[i+1])
    
    if( i==(gameTime - 1)){
      prof[i+1]   = Profitplot(catch= ca[i+1] ,biomass= b[i+1])
    }

}

payoff.opt=sum(prof)



if (do.save.plot==T){
  png(filename=paste(path.plot,"OPtimal_path.png",sep=""), width = 8, height = 8, units = 'in', res = 300)}

layout(matrix(c(1,1,2,3), 2, 2, byrow = TRUE))

plot(seq(1,gameTime,1),b,xlab="Years",ylab="Biomass",type='o',lwd=2,ylim=c(0,30))
abline(h=K/2, col='red',lty=6,lwd=1)
text(x=20,y=K/2.3,labels="Bmsy",col='red')
#abline(v=round(0.5*((beta/(P*r))+K),0), col='green',lty=6,lwd=1)
grid()

title("Optimal stock")

plot(seq(1,gameTime,1),prof,xlab="Years",ylab="Profit",type='o',lwd=2,ylim=c(0,6))
#abline(v=round(0.5*((beta/(P*r))+K),0), col='green',lty=6,lwd=1)
grid()

title("Optimal profit")

plot(seq(1,gameTime,1),ca,xlab="Years",ylab="Harvest",type='o',lwd=2,ylim=c(0,15))
#abline(v=round(0.5*((beta/(P*r))+K),0), col='green',lty=6,lwd=1)
grid()

title("Optimal harvest")


if (do.save.plot==T){
  dev.off()
}


#######################################
## Open access dynamique 

## 




##############
## Plot functions
#########################
yield.vec=seq(0,maxHarvest*nbPlayers,by = 1)
y = matrix( 
  yield.vec, 
  nrow=length(yield.vec), 
  ncol=length(yield.vec),byrow = TRUE)

stock.vec=seq(0,K,by = 1)
s = matrix( 
  stock.vec, 
  nrow=length(stock.vec), 
  ncol=length(stock.vec))

################################""
## individual profit Table for a stock level 
Indyield.vec=seq(0,maxHarvest*(nbPlayers-1),by = 1)
MYyield=seq(0,maxHarvest,by = 1)

pp= ProfitInd(biomass = 25 ,catch = Indyield.vec , catchInd = MYyield)
rownames(pp)=Indyield.vec
colnames(pp)=MYyield

print(pp)

########################""
## total cost

c =Costplot(stock=(stock.vec),capture=(yield.vec))


if (do.save.plot==T){
  png(filename=paste(path.plot,"Cost.png",sep=""), width = 4, height = 4, units = 'in', res = 300)
}
  image.plot(z=t(c),y=yield.vec,x=stock.vec,xlab='Stock',ylab='Harvest',
           zlim=c(0,max(c[which(c!="Inf")],na.rm=TRUE)),col=brewer.pal(9,"PuBu"))
  contour(z=t(c),y=yield.vec,x=stock.vec,zlim=c(0,max(c[which(c!="Inf")],na.rm=TRUE)),  nlevels = 9,add=T,labcex=1,lwd=1)


title("Cost")

if (do.save.plot==T){
  dev.off()
}

###########################""
## individual gain


if (do.save.plot==T){
  png(filename=paste(path.plot,"Gain.png",sep=""), width = 4, height = 4, units = 'in', res = 300)
}

gain = round(Gain(c=(yield.vec)),0)
gg = matrix(data=gain,nrow=length(gain), ncol=length(stock.vec))

  image.plot(z=t(gg),y=yield.vec,x=stock.vec,xlab='Stock',ylab='Harvest',
             zlim=c(0,max(gg)),col=brewer.pal(9,"PuBu"))
  contour(z=t(gg),y=yield.vec,x=stock.vec,zlim=c(0,max(gg)),  nlevels = 9,add=T,labcex=1,lwd=1)

title("Gain")


if (do.save.plot==T){
  dev.off()
}

#############################
## individual profit

p = Profitplot(biomass=(stock.vec),catch=yield.vec)

if (do.save.plot==T){
  png(filename=paste(path.plot,"Profit.png",sep=""), width = 4, height = 4, units = 'in', res = 300)
}

image.plot(z=t(p),y=yield.vec,x=stock.vec,xlab='Stock',ylab='Harvest',zlim=c(-6,6),
           col=brewer.pal(9,"RdBu"))
contour(z=t(p),y=yield.vec,x=stock.vec,zlim=c(c(-6,6)),  nlevels = 9,add=T,labcex=1,lwd=1)
#zlim=c(min(as.vector(p[p!='-Inf']),na.rm=TRUE),max(as.vector(p[p!='-Inf'])
title("Profit")

if (do.save.plot==T){
  dev.off()
}

###############################"
## Growth

g =  growth(b=stock.vec,b1=r,b2=K)

if (do.save.plot==T){
  png(filename=paste(path.plot,"Growth.png",sep=""), width = 4, height = 4, units = 'in', res = 300)
 
  
}

plot(stock.vec,g,xlab="stock",ylab="growth",type='l',lwd=2)
abline(v=K/2, col='red',lty=6,lwd=1)
#abline(v=round(0.5*((beta/(P*r))+K),0), col='green',lty=6,lwd=1)
grid()

title("Growth Function")

if (do.save.plot==T){
  dev.off()
  
}


#######################################
## Projection stock









        