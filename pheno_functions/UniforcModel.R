###############################################
#Unifor model 
###############################################
#latest version present on capsis platform 
#from the PHENOFIT/CASTANEA exophysiologycal model. Translation of the PMP model 
Uniforc_Chuine <- function(parameters, data, originClimateData){
  
  library(tidyverse)
  # exit the routine if parameters are missing
  if (length(parameters) != 4){
    stop("model parameter(s) out of range (too many or too few) - need 4 parameters for uniforc model")
  }  

    if(length(colnames(data))<3){
    stop("missing columns? you need year, DOY and meanTemp data to work ;-)")
  }

  #paramters of uniforc model
    t0 <- parameters[1] # starting date of ecododormancy
    F_crit <- parameters[2] # Critical state of forcing
    T50 <- parameters[3] # Mid-response temperature to forcing
    dT <- parameters[4] # Slope of the forcing response

  vectoryear <- unique(data$year)
  outputBBdayyear <- list()
  minyear <- min(vectoryear)

  for (k in 1:length(vectoryear)){
    
    if(!vectoryear[k] == minyear){#works only for year different from min year

      #######################
      #now manage the forcing 
      
      dataForcing <- data %>% filter(year %in% c(vectoryear[k])) %>% 
        mutate(vec = 1:nrow(.)) %>% 
        mutate(Date = as.Date(vec-1,  origin = originClimateData)) %>% 
        mutate(DOYn =  as.numeric(as.character(format(Date, "%j")))) %>% 
        filter(DOYn  >= t0) #select data set for forcing parameter
      #now calculate R_f, forcing units 
      R_f <- 1/(1+exp(-dT*(dataForcing$meanTemp-T50)))
      
      dataForcing$R_f <- R_f
      #now filter data up to the tC date 
      #cumsum(data$R_f[data$DOY >= tC]) 
      #data %>% filter(DOY >= tC) %>% 
      #  mutate(Fcritcont = cumsum(R_f))
      tF <- which.min((cumsum(dataForcing$R_f) >= F_crit) == FALSE)
      
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
