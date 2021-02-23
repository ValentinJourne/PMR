



#rate of chilling
#check daily temperature, threshold

#rate of forcing 

dataDvx5= VtxClimate %>% filter(plot == "DVX5")
dataDvx3= VtxClimate %>% filter(plot == "DVX3")

#species parameters 
#fit from Gauzere et al in Eco Mod
parametersFagus = c(-62, 37.3, 13, 0.08, 73.7, 13)
parametersAbies = c(-67, 9, 15.2, 0.24, 144.6, 1.61, -27.1, -4.95)

#need to specify origin data of the data in this particular format
originClimateData <- "1959-01-01"

#need to specify plant functional type. 
#for example two submodel to simulate budburst data for Unichill model
FunctionalTypeFagus <- "deciduous"
FunctionalTypeAbies <- "coniferous"

#then run the model fit !
#first fit unichill for fagus at two diferent altidude
phenoFagusDvx5 <-   Unichill_Threshold_Chuine(parametersFagus, VtxClimate, originClimateData, FunctionalTypeFagus) %>% 
  mutate(species = "Fagus", site = "Dvx5")
phenoFagusDvx3 <- Unichill_Threshold_Chuine(parametersFagus, dataDvx3, originClimateData, FunctionalTypeFagus) %>% 
  mutate(species = "Fagus", site = "Dvx3")
phenoUnichillF <- rbind(phenoFagusDvx5, phenoFagusDvx3)

ggplot(phenoUnichillF, aes(x = year, y = BBDAY, col = site))+geom_point()+geom_line()

########################################
#test for abies alba 
phenoAbiesDvx5 <- Unichill_Threshold_Chuine(parametersAbies, dataDvx5, originClimateData, FunctionalTypeAbies) %>% 
  mutate(species = "Abies", site = "Dvx5")
phenoAbiesDvx3 <- Unichill_Threshold_Chuine(parametersAbies, dataDvx3, originClimateData, FunctionalTypeAbies) %>% 
  mutate(species = "Abies", site = "Dvx3")

phenoUnichill <- rbind(phenoAbiesDvx5, phenoAbiesDvx3)
#ggplot(phenoUnichill, aes(x = year, y = BBDAY, col = site))+geom_point()+geom_line()

pathData= "/media/journe/DDlabo/Thesis/CASTANEA/Simulations_Paper_Modelo_reprov2/parameterization/parameterization/Ventoux/" #bdd for data 
phenoMeas= read.table(paste0(pathData,"budburstMean.csv"),sep=";",head=T)

phenofir <-  phenoMeas %>% 
  filter(species == 12) %>% 
  group_by(year,altitudeClass) %>% 
  summarize_at(vars(dateBBCH7), list(mean = mean, sd = sd), na.rm = T) %>% 
  mutate(site = ifelse(altitudeClass=="1", "Dvx3", "Dvx5"), data = "observation")
phenofagus <-  phenoMeas %>% 
  filter(species == 16) %>% 
  group_by(year,altitudeClass) %>% 
  summarize_at(vars(dateBBCH7), list(mean = mean, sd = sd), na.rm = T) %>% 
  mutate(site = ifelse(altitudeClass=="1", "Dvx3", "Dvx5"), data = "observation")

test <- phenoUnichill %>% right_join(phenofir, by=c("year","site")) %>% select(-altitudeClass, -data)
test2 <- phenoUnichillF %>% right_join(phenofagus, by=c("year","site")) %>% select(-altitudeClass, -data)

AbiesGauzere <- ggplot(test)+
  geom_point(aes(x = year, y = mean), size = 3)+
  geom_line(aes(x = year, y = mean), linetype = "dashed")+
  geom_errorbar(aes(ymin = mean-sd, ymax = mean+sd, x = year), width=.0)+
  #geom_ribbon(aes(ymin = mean-sd, ymax = mean+sd, x = year),
  #						col = NA,alpha = 0.15, fill = "#293352")+
  geom_point(aes(x = year, y = BBDAY), col = "red", size = 3)+
  geom_line(aes(x = year, y = BBDAY), col = "red")+
  facet_wrap(.~site, nrow = 2)+
  scale_x_continuous(breaks = seq(2006,2020, by = 2), limits=c(2006,2019))+
  #ylim(110,160)+
  theme(legend.position = "none", 
        strip.background = element_rect(color="black", fill="grey90", size=0, linetype="solid"),
        strip.text.x = element_text(
          size = 12, color = "black", face = "bold", family="Helvetica"
        ))+
  ylab(paste0("Budburst date (in days)"))+
  xlab("Year")

FagusGauzere <- ggplot(test2)+
  geom_point(aes(x = year, y = mean), size = 3)+
  geom_line(aes(x = year, y = mean), linetype = "dashed")+
  geom_errorbar(aes(ymin = mean-sd, ymax = mean+sd, x = year), width=.0)+
  #geom_ribbon(aes(ymin = mean-sd, ymax = mean+sd, x = year),
  #						col = NA,alpha = 0.15, fill = "#293352")+
  geom_point(aes(x = year, y = BBDAY), col = "red", size = 3)+
  geom_line(aes(x = year, y = BBDAY), col = "red")+
  facet_wrap(.~site, nrow = 2)+
  scale_x_continuous(breaks = seq(2006,2020, by = 2), limits=c(2006,2019))+
  #ylim(110,160)+
  theme(legend.position = "none", 
        strip.background = element_rect(color="black", fill="grey90", size=0, linetype="solid"),
        strip.text.x = element_text(
          size = 12, color = "black", face = "bold", family="Helvetica"
        ))+
  ylab(paste0("Budburst date (in days)"))+
  xlab("Year")



FigUnichillVtx <- plot_grid(AbiesGauzere, FagusGauzere, labels = c("Abies", "Fagus"))
save_plot("testPhenoChuineR.png",FigUnichillVtx, ncol = 2, nrow = 2)