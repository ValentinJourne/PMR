PMR
================

## General description

functions to simulate budburst with R, translation of the PMP plateforme
(Chuine et al 2013)

## Data information

data used for the illustration are coming from Mt-Ventoux (contact:
<hendrik.davi@inrae.fr>)

### Climate data

data along elevation…

![](README_files/figure-gfm/data%20climate%20presentation-1.png)<!-- -->

### Phenology data

leaf budburst from Mt Ventoux

## Model information

### Climate data format

  - `plot`: 1 plot for each use of the function. If you have many more
    plots use a loop
  - `year`: numbers of years. Not that the function need at least two
    year to run, because it use bot climate of the previous \(n-1\) and
    current year \(n\) to simulate leaf budburst of the year \(n\).
  - `DOY`: day of the year, in the following format 1 to X, where if you
    have for example two years, X should go to 730 days. The current
    function can not work with DOY going to 365 days only. \*\*\* works
    also with basic DOY from 1 to 365\*\*\*
  - `meanTemp`: mean temperature for each days in T°C. For each function
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
submodel (here example with Abies parameters) : \(t\) ; \(t0\) ;
\(F_{crit}\) ; \(T50\) ; \(dT\) ; \(C_{crit}\) ; \(a\) ; \(b\) ; \(c\) .
The last parameters are parameters for the sigmoid function of rate of
chilling. `parametersAbies = c(-67, 9, 15.2, 0.24, 144.6, 1.61, -27.1,
-4.95)`

Parameters for threshold option, for example here for Fagus are in the
following order: \(t0\) ; \(F_{crit}\) ; \(T50\) ; \(dT\) ; \(C_{crit}\)
; \(T_{base}\) . In this submodel you need to specify a base
temperature. `parametersFagus = c(-62, 37.3, 13, 0.08, 73.7, 13)`

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
  mutate(species = "Fagus", site = "DVX5")
```

Then we could also test for  with the same previous climate (DVX5) and
same climate origin.

``` r
#need to specify submodel of unichill
submodelAbies <- "unimodal"

#species parameter here for Abies alba
#t0, Fcrit, T50, Dt, Ccrit, Tbase, a , b , c
parametersAbies = c(-67, 9, 15.2, 0.24, 144.6, 1.61, -27.1, -4.95)

#Run unichill model in plot DVX5 for Abies and add details with dplyr
phenoAbiesDvx5 <-   Unichill_Chuine(parametersAbies, dataDvx5, submodelAbies) %>% 
  mutate(species = "Abies", site = "DVX5")
```

You can see a model output in the following figure of leaf bud burst
simulate for the two species.
![](README_files/figure-gfm/sim%20unichill-1.png)<!-- -->

#### Uniforc model

The uniforc model is a simple model where temperature are accumlated the
same year of leaf budburst. It has four parameters, already define
previously: \(t0\) ; \(F_{crit}\) ; \(T50\) ; \(dT\) . Here, \(t0\) is
the starting date of ecodormancy and not endodormancy as in unichill
model. Parameters defined here came from Gauzere et al (2017)

``` r
#select data for the site of interest (here named DVX5)
dataDvx5= VtxClimate %>% filter(plot == "DVX5")

#species parameter here for Fagus sylvatica
parametersFagusUniforc = c(13, 41.3, 12.41, 0.06)
#order : t0, Fcrit, T50, dT
#Run unichill model in plot DVX5 for fagus and then add plot and species name 
phenoFagusDvx5Unif <-   Uniforc_Chuine(parametersFagusUniforc, dataDvx5) %>% 
  mutate(species = "Fagus", site = "DVX5")
```

![](README_files/figure-gfm/sim%20uniforc-1.png)<!-- -->

## References

  - Chuine, I. 2000. A unified model for budburst of trees. J. Theor.
    Biol. 207: 337– 347.
  - Chuine I., Garcia de Cortazar Atauri I., Kramer K. & Hänninen H.
    (2013) Plant Development Models. In: Phenology: An Integrative
    Environmental Science (ed. Schwarz MD). Springer, Dordrecht,
    Netherlands, pp. 275-293.
  - Gauzere J, Teuf B, Davi H, Chevin L.‐M., Caignard T, Delzon S, Ronce
    O, Chuine I. 2020. Where is the optimum? Predicting the variation of
    selection along climatic gradients and the adaptive value of
    plasticity. A case study on tree phenology. Evolution Letters 4:
    109– 123.
  - J. Gauzere, S. Delzon, H. Davi, M. Bonhomme, A. Garcia de Cortazar,
    I. Chuine. Integrating interactive effects of chilling and
    photoperiod in phenological process-based models. A case study with
    two European tree species: Fagus sylvatica and Quercus petraea
    Agric. Forest Meteorol., 244 (2017), pp. 9-20
