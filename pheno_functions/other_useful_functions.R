#other useful function 

###################################
#get declinaison to calcualte after daylength 
#here in radian
get_declinaison <- function(day_DOY){
  declinaison <- (pi*23.45/180)*sin(2*pi*(284+day_DOY)/365)
  #declinaison <- -23.45*pi/180*cos(2*pi*(day_DOY+10)/365) #same function from Phenofit
  return(declinaison)
}


###################################
#get daylength in hours 
get_daylength<- function(latitude, day_DOY){
  #castanea version 
  radiation_latitude <- latitude*pi/180
  declinaison <- get_declinaison(day_DOY)
  daylength <- (acos(-tan(radiation_latitude)*tan(declinaison)))*360/(15*pi)
  return(daylength)
}

#check another daylength function from phenofit 
get_daylengthphenofit<- function(latitude, day_DOY){
  #phenofit version 
  a <- -tan(latitude*pi/180)*tan(get_declinaison(day_DOY))
  
  daylength <- ifelse(a > 1, 0,
         ifelse(a < -1,  24, 24/pi*acos(a)))
  
  return(daylength)
}
