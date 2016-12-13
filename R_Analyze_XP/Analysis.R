
get.raw.data.AERME <- function (dir, dir.script, dir.xp, nb.session, ){
  
  ## Packages/functions 
  
  library(gridExtra)
  library(grid)
  library(ggplot2)
  library(lattice)
  require(reshape2)
  
  source(paste(dir,dir.script,"read_Otree.R",sep=""))
  source(paste(dir,dir.script,"makeTable_Otree.R",sep=""))
  
  ## save plot 
  do.save=TRUE
  path.fig= paste(dir.data,dir.xp,sep="")
  

}