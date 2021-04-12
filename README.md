PMR
================

## General description

functions to simulate budburst with R, translation of the PMP plateforme
(Chuine et al 2013)

## Data information

data used for the illustration are coming from Mt-Ventoux (contact:
<a href="mailto:hendrik.davi@inrae.fr" class="email">hendrik.davi@inrae.fr</a>)

### Climate data

data along elevation…

![](README_files/figure-gfm/data%20climate%20presentation-1.png)<!-- -->

### Phenology data

leaf budburst from Mt Ventoux

## Model information

### Climate data format

-   `plot`: 1 plot for each use of the function. If you have many more
    plots use a loop
-   `year`: numbers of years. Not that the function need at least two
    year to run, because it use bot climate of the previous *n* − 1 and
    current year *n* to simulate leaf budburst of the year *n*.
-   `DOY`: day of the year, in the following format 1 to X, where if you
    have for example two years, X should go to 730 days. The current
    function can not work with DOY going to 365 days only. \*\*\* works
    also with basic DOY from 1 to 365\*\*\*
-   `meanTemp`: mean temperature for each days in T°C. For each function
    you need to specify date of the origin of your climate file.

### Phenological models

#### Unichill model

In the current version, unichill is based on two different options. A
threshold model to accumulate temperature of rate of chilling or
exponential model as described in Chuine (2000). In a recent article
Gauzere et al (2020) found that response of chilling was simulated well
with a sigmoïd function rather than a threshold model. So if you plan to
use this function you need to specify a new argument (unimodal or
threshold). The sigmoid submodel need more parameters than the threshold
submodel. More details are provided in Chuine (2000) and in SI from
Gauzere et al (2020).

Parameters are in the following order, for example if it is a unimodal
submodel (here example with Abies parameters) : *t* ; *t*0 ;
*F*<sub>*c**r**i**t*</sub> ; *T*50 ; *d**T* ; *C*<sub>*c**r**i**t*</sub>
; *a* ; *b* ; *c* . The last parameters are parameters for the sigmoid
function of rate of chilling.
`parametersAbies = c(-67, 9, 15.2, 0.24, 144.6, 1.61, -27.1, -4.95)`

Parameters for threshold option, for example here for Fagus are in the
following order: *t*0 ; *F*<sub>*c**r**i**t*</sub> ; *T*50 ; *d**T* ;
*C*<sub>*c**r**i**t*</sub> ; *T*<sub>*b**a**s**e*</sub> . In this
submodel you need to specify a base temperature.
`parametersFagus = c(-62, 37.3, 13, 0.08, 73.7, 13)`

We first test here unichill model for

``` r
#select data for the site of interest (here named DVX5)
dataDvx5= VtxClimate %>% filter(plot == "DVX5")

#need to specify submodel of unichill 
submodelFagus <- "threshold"

#species parameter here for Fagus sylvatica with the folowing order
#t0, Fcrit, T50, Dt, Ccrit, Tbase
parametersFagus = c(-62, 37.3, 13, 0.08, 73.7, 13)

#Run unichill model in plot DVX5 for fagus and then add plot and species name 
phenoFagusDvx5 <-   Unichill_Chuine(parametersFagus, dataDvx5, submodelFagus) %>% 
  mutate(species = "Fagus", site = "DVX5", model = "Unichillth")
```

Then we could also test for with the same previous climate (DVX5) and
same climate origin.

``` r
#need to specify submodel of unichill
submodelAbies <- "unimodal"

#species parameter here for Abies alba
#t0, Fcrit, T50, Dt, Ccrit, Tbase, a , b , c
parametersAbies = c(-67, 9, 15.2, 0.24, 144.6, 1.61, -27.1, -4.95)

#Run unichill model in plot DVX5 for Abies and add details with dplyr
phenoAbiesDvx5 <-   Unichill_Chuine(parametersAbies, dataDvx5, submodelAbies) %>% 
  mutate(species = "Abies", site = "DVX5", model = "Unichill")
```

You can see a model output in the following figure of leaf bud burst
simulate for the two species.
![](README_files/figure-gfm/sim%20unichill-1.png)<!-- -->

#### Uniforc model

The uniforc model is a simple model where temperature are accumlated the
same year of leaf budburst. It has four parameters, already define
previously: *t*0 ; *F*<sub>*c**r**i**t*</sub> ; *T*50 ; *d**T* . Here,
*t*0 is the starting date of ecodormancy and not endodormancy as in
unichill model. Parameters defined here came from Gauzere et al (2017)

``` r
#select data for the site of interest (here named DVX5)
dataDvx5= VtxClimate %>% filter(plot == "DVX5")

#species parameter here for Fagus sylvatica
parametersFagusUniforc = c(13, 41.3, 12.41, 0.06)
#order : t0, Fcrit, T50, dT
#Run unichill model in plot DVX5 for fagus and then add plot and species name 
phenoFagusDvx5Unif <-   Uniforc_Chuine(parametersFagusUniforc, dataDvx5) %>% 
  mutate(species = "Fagus", site = "DVX5", model = "Unifor")
```

![](README_files/figure-gfm/sim%20uniforc-1.png)<!-- -->

#### PGC model - Gauzere model

The PGC model is a model with temperature and photoperiod effect to
simulate budburst. This model showed robust prediction of leaf budburst
of Fagus sylvatica. However here we need to add a new column with the
latitude to calculated daylength (i.e. photoperiod). The model has 9
parameters : *t*0 ; *F*<sub>*c**r**i**t*</sub> ; *T*50 ; *d**T* ;
*T*<sub>*b**a**s**e*</sub> ; *C*50 ; *p**R* ; *d**C* ; *d**P*

``` r
#select data for the site of interest (here named DVX5)
dataDvx5= VtxClimate %>% filter(plot == "DVX5")

#species parameter here for Fagus sylvatica
parametersFagusPGC = c(-65, 13.9, 10.5, 0.25, 11.9, 153.5, 1.76, -40, 0.44)
latitudeDvx5 = 44.18 #in degree
#order : $t0$ ; $F_{crit}$ ; $T50$ ; $dT$ ; $T_{base}$ ; $C50$ ; $pR$ ; $dC$ ; $dP$
    # t0 <- parameters[1] # starting date of ecodorimancy
    # F_crit <- parameters[2] # Critical state of forcing
    # T50 <- parameters[3] # Mid-response temperature to forcing
    # dT <- parameters[4] # Slope of the forcing response
    # T_base <- parameters[5] # Threshold chilling temperature
    # C50 <- parameters[6] # Mid-response photoperiod
    # pR <- parameters[7] #boudaries mid repsonse photoperiod
    # dC <- parameters[8] #slope photoperiod
    # dP <- parameters[9] #slope growht competence
#Run unichill model in plot DVX5 for fagus and then add plot and species name 
phenoFagusDvx5PGC <-   PGC(parametersFagusPGC, dataDvx5, latitudeDvx5) %>% 
  mutate(species = "Fagus", site = "DVX5", model = "PGC")
```

![](README_files/figure-gfm/sim%20PGC-1.png)<!-- -->

#### Comparison between the different models

![](README_files/figure-gfm/sim%20comparison-1.png)<!-- -->![](README_files/figure-gfm/sim%20comparison-2.png)<!-- -->

## References

-   Chuine, I. 2000. A unified model for budburst of trees. J. Theor.
    Biol. 207: 337– 347.
-   Chuine I., Garcia de Cortazar Atauri I., Kramer K. & Hänninen H.
    (2013) Plant Development Models. In: Phenology: An Integrative
    Environmental Science (ed. Schwarz MD). Springer, Dordrecht,
    Netherlands, pp. 275-293.
-   Gauzere J, Teuf B, Davi H, Chevin L.‐M., Caignard T, Delzon S, Ronce
    O, Chuine I. 2020. Where is the optimum? Predicting the variation of
    selection along climatic gradients and the adaptive value of
    plasticity. A case study on tree phenology. Evolution Letters 4:
    109– 123.
-   J. Gauzere, S. Delzon, H. Davi, M. Bonhomme, A. Garcia de
    Cortazar, I. Chuine. Integrating interactive effects of chilling and
    photoperiod in phenological process-based models. A case study with
    two European tree species: Fagus sylvatica and Quercus petraea
    Agric. Forest Meteorol., 244 (2017), pp. 9-20
