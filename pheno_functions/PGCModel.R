###############################################
#Gauzere model 
###############################################
#latest version present on capsis platform 
#from the PHENOFIT/CASTANEA exophysiologycal model. Translation of the PMP model 
#need to have daylength, so we will calculate here daylength inside the function 
PGC <- function(parameters, data, latitude){
  
    library(tidyverse)
    #source("other_useful_functions.R")
    # This is an effort to reproduce PGC model from Gauzere et al published in 2017,2018 in AFM/EcoMod
  
  
  # exit the routine if parameters are missing
  if (length(parameters) != 9){
    stop("model parameter(s) out of range (too many or too few)- need 9 parameters for PGC")
  }  
  if(length(colnames(data))<3){
    stop("missing columns? you need year, DOY and meanTemp data to work ;-)")
  }
  if(missing(latitude)){
    stop("You also need to add the Latitude - in wgs84 please")
  }
  # extract the parameter values from the
  # par argument in a more human readable form
  
    ##order : $t0$ ; $F_{crit}$ ; $T50$ ; $dT$ ; $T_{base}$ ; $C50$ ; $pR$ ; $dC$ ; $dP$
    t0 <- parameters[1] # starting date of ecodorimancy
    F_crit <- parameters[2] # Critical state of forcing
    T50 <- parameters[3] # Mid-response temperature to forcing
    dT <- parameters[4] # Slope of the forcing response
    T_base <- parameters[5] # Threshold chilling temperature
    C50 <- parameters[6] # Mid-response photoperiod
    pR <- parameters[7] #boudaries mid repsonse photoperiod
    dC <- parameters[8] #slope photoperiod
    dP <- parameters[9] #slope growht competence

  
  vectoryear <- unique(data$year)
  outputBBdayyear <- list()
  minyear <- min(vectoryear)
  #k <- length(vectoryear)
  for (k in 1:length(vectoryear)){
    
    if(!vectoryear[k] == minyear){
      
      #caclulate phenology date for other year, but not the first year because we do need the previous climate
      #do for each year the BBDay
      #select the current year and the previous year
      #reverse the number of days 
      
      originClimateData <- paste0(vectoryear[k-1], "-01-01")
      
      
      sdata <- data %>% filter(year %in% c(vectoryear[k], vectoryear[k-1])) %>% 
        mutate(vec = 1:nrow(.)) %>% 
        mutate(Date = as.Date(vec-1,  origin = originClimateData)) %>% 
        mutate(DOYn =  as.numeric(as.character(format(Date, "%j")))) %>% 
        group_by(year) %>% 
        mutate(lengthdayinverse = DOYn - max(DOYn)-1,
               photoperiod = get_daylengthphenofit(latitude, DOY)) #use here the other function 
      
      #filter both previous year and current year 
      filter1Chilling <- sdata %>% filter(year %in% c(vectoryear[k-1]) & lengthdayinverse >= t0)
      filtercurrentyear <- sdata %>% filter(year %in% c(vectoryear[k]))
      
      phenoyear <- rbind(filter1Chilling, filtercurrentyear)
      
      #######################
      #here need to define photoperiod and temperature effect on budburst 
      R_c <- ifelse(phenoyear$meanTemp < T_base, 1, 0) 
      phenoyear$R_c <- R_c
      phenoyear$sumR_c <- cumsum(phenoyear$R_c)
      midP50 <- (12-pR)+(2*pR/(1+exp(-dC*(phenoyear$sumR_c-C50))))
        
      #growth competence based on length day (photoperiod)
      GrowthCompetence <- 1/(1+exp(-dP*(phenoyear$photoperiod-midP50)))
        
      #rate of forcing
      R_f <- 1/(1+exp(-dT*(phenoyear$meanTemp-T50)))
      
      #the PGC model coupled growth competence based on chilling and photoperiod 
      #and also the rate of forcing 
      phenoyear$RfGC <- R_f*GrowthCompetence
      tFrow <- which.min((cumsum(phenoyear$RfGC) >= F_crit)==FALSE) #select last FALSE, meaning that F crit is acquired 
      BBDAY <- phenoyear[tFrow,]$DOYn #select DOY when arrived at the threshold
      year <- unique(max(phenoyear$year))
      #BBDAY = tC+tF-1
      outputBBdayyear[[k]] <- cbind(year, BBDAY)
      
    }
    
    else{    
      BBDAY <- NA
      year <- unique(min(vectoryear))
      outputBBdayyear[[k]] <- cbind(year, BBDAY)
    }
  }
  
  outputBBdayyearres <- as.data.frame(do.call(rbind, outputBBdayyear))
  return(outputBBdayyearres)
  
}
