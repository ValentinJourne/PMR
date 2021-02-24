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
    function can not work with DOY going to 365 days only.
  - `meanTemp`: mean temperature for each days in T°C. For each function
    you need to specify date of the origin of your climate file.

### Phenological models

#### Unichill model

In the current version, unichill is based on two different options. A
threshold model to accumate temperature of rate of chilling or
exponential model as described in Chuine (2000). In a recent article
Gauzere et al (2020) found that response of chilling was simulated well
with a sigmoïd function rather than a threshold model. So if you plan to
use this function you need to specify a new argument (unimodal or
threshold). The sigmoid submodel need more parameters than the threshold
submodel. More details are provided in Chuine (2000) and in SI from
Gauzere et al (2020).

Parameters are in the following order, for example if it is a unimodal
submodel (here example with Abies parameters) : \(t\); \(t0\);
\(F_crit\); \(T50\); \(dT\); \(C_crit\); \(a\); \(b\); \(c\). The last
parameters are parameters for the sigmoid function of rate of chilling.
`parametersAbies = c(-67, 9, 15.2, 0.24, 144.6, 1.61, -27.1, -4.95)`

Parameters for threshold option, for example here for Fagus are in the
following order: \(t0\); \(F_crit\); \(T50\); \(dT\); \(C_crit\);
\(T_base\). In this submodel you need to specify a base temperature.
`parametersFagus = c(-62, 37.3, 13, 0.08, 73.7, 13)`

We first test here unichill model for 

``` r
#select data for the site of interest (here named DVX5)
dataDvx5= VtxClimate %>% filter(plot == "DVX5")
#need to specify origin data of the data in this particular format
originClimateData <- "1959-01-01"
#need to specify plant functional type. 
submodelFagus <- "threshold"

#species parameter here for Fagus sylvatica
parametersFagus = c(-62, 37.3, 13, 0.08, 73.7, 13)

#Run unichill model in plot DVX5 for fagus and then add plot and species name 
phenoFagusDvx5 <-   Unichill_Chuine(parametersFagus, dataDvx5, originClimateData, submodelFagus) %>% 
  mutate(species = "Fagus", site = "DVX5")
```

Then we could also test for  with the same previous climate (DVX5) and
same climate origin.

``` r
#need to specify plant functional type. 
submodelAbies <- "unimodal"

#species parameter here for Abies alba
parametersAbies = c(-67, 9, 15.2, 0.24, 144.6, 1.61, -27.1, -4.95)

#Run unichill model in plot DVX5 for Abies and add details with dplyr
phenoAbiesDvx5 <-   Unichill_Chuine(parametersAbies, dataDvx5, originClimateData, submodelAbies) %>% 
  mutate(species = "Abies", site = "DVX5")
```

You can see a model output in the following figure of leaf bud burst
simulate for the two species.
![](README_files/figure-gfm/sim%20unichill-1.png)<!-- -->

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
