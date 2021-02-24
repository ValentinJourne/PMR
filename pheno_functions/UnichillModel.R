###############################################
#Unichill model 
###############################################
#two options ; threshold or exp to define rate of chilling
#latest version present on capsis platform 
#from the PHENOFIT/CASTANEA exophysiologycal model. Translation of the PMP model 
Unichill_Chuine <- function(parameters, data, originClimateData, SubModel){
  
  library(tidyverse)
  
  # This is an effort to reproduce the Unified Model
  # of Chuine 2000 in full form (not simplified). Updated with last article from Gauzere et al, in Evolution Letters 2020
  # threshold model for deciduous and sig for coniferous works better

  
  # exit the routine if parameters are missing
  if (length(parameters) != 6 & SubModel == "threshold"){
    stop("model parameter(s) out of range (too many or too few)- need 6 parameters for threshold SubModel")
  }  
  
  if (length(parameters) != 8 & SubModel == "unimodal"){
    stop("model parameter(s) out of range (too many or too few) - need 8 parameters for unimodal SubModel")
  }
  
  if(length(colnames(data))<3){
    stop("missing columns? you need year, DOY and meanTemp data to work ;-)")
  }
  
  # extract the parameter values from the
  # par argument in a more human readable form
  if (SubModel == "unimodal"){
    
    t0 <- parameters[1] # starting date of ecodorimancy
    F_crit <- parameters[2] # Critical state of forcing
    T50 <- parameters[3] # Mid-response temperature to forcing
    dT <- parameters[4] # Slope of the forcing response
    C_crit <- parameters[5] # Critical state of chilling
    #T_base <- parameters[6] # Threshold chilling temperature
    a <- parameters[6] 
    b <- parameters[7] 
    c <- parameters[8] 
    
  }else{
    
    t0 <- parameters[1] # starting date of ecodorimancy
    F_crit <- parameters[2] # Critical state of forcing
    T50 <- parameters[3] # Mid-response temperature to forcing
    dT <- parameters[4] # Slope of the forcing response
    C_crit <- parameters[5] # Critical state of chilling
    T_base <- parameters[6] # Threshold chilling temperature
    
  }

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
    sdata <- data %>% filter(year %in% c(vectoryear[k], vectoryear[k-1])) %>% 
      mutate(vec = 1:nrow(.)) %>% 
      mutate(Date = as.Date(vec-1,  origin = originClimateData)) %>% 
      mutate(DOYn =  as.numeric(as.character(format(Date, "%j")))) %>% 
      group_by(year) %>% 
      mutate(lengthdayinverse = DOYn - max(DOYn)-1)
    
    #filter both previous year and current year 
    filter1Chilling <- sdata %>% filter(year %in% c(vectoryear[k-1]) & lengthdayinverse >= t0)
    filtercurrentyear <- sdata %>% filter(year %in% c(vectoryear[k]))
    
    phenoyear <- rbind(filter1Chilling, filtercurrentyear)
    
    #######################
    #calculate rate of chilling; cumulate low temperature
    #threshold model exept for coniferous use another exp model 
    
    if (SubModel == "unimodal"){
      
      R_c <- 1/(1+exp(a*(phenoyear$meanTemp-c)^2+b*(phenoyear$meanTemp-c)))
      phenoyear$R_c <- R_c
      tCrow <- which.min((cumsum(phenoyear$R_c) >= C_crit)==FALSE) #select last FALSE, meaning that C crit is acquired 
      DOYtC <- phenoyear[tCrow,]$DOYn #select DOY when arrived at the threshold
      
    }else{
      
      R_c <- ifelse(phenoyear$meanTemp < T_base, 1, 0) 
      phenoyear$R_c <- R_c
      tCrow <- which.min((cumsum(phenoyear$R_c) >= C_crit)==FALSE) #select last FALSE, meaning that C crit is acquired 
      DOYtC <- phenoyear[tCrow,]$DOYn #select DOY when arrived at the threshold
      
    }

    #######################
    #now manage the forcing 
    dataForcing <- phenoyear[tCrow:nrow(phenoyear),]
    #dataForcing <- phenoyear %>% slice((row_number(phenoyear) == tCrow):70)
    #filter(DOYn >= DOYtC & year %in% c(vectoryear[i]))
    #filter(row_number() == tCrow | row_number() == n(.))
    #now calculate R_f, forcing units 
    R_f <- 1/(1+exp(-dT*(dataForcing$meanTemp-T50)))
    
    dataForcing$R_f <- R_f
    #now filter data up to the tC date 
    #cumsum(data$R_f[data$DOY >= tC]) 
    #data %>% filter(DOY >= tC) %>% 
    #  mutate(Fcritcont = cumsum(R_f))
    tF <- which.min((cumsum(dataForcing$R_f[dataForcing$DOY >= DOYtC]) >= F_crit) == FALSE)
    
    BBDAY <- dataForcing[tF,]$DOYn
    year <- unique(max(dataForcing$year))
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
