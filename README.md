# Endangered_species_SDM
Spatial Distribution Modeling (SDM) for endangered species using the Random Forest (RF) algorithm

## Case study
Cercopithecus Erythrogaster (red-bellied monkey).
It is an endemic primate of sub-Saharan regions, that has been recently classified as “endangered” by the IUCN Red List in 2016: https://www.iucnredlist.org/species/4217/17946182
Other case studies in the same region will be conducted if time allows, in order to conduct multi-species SDM.

## Species data
The data comes from GBIF and we added observation points collected in the following scientific article: "Dynamique spatiale des populations de Cercopithecus erythrogaster erythrogaster Gray dans le complexe d’aires protégées Togodo (Togo)" by AGBESSI Koffi Ganyo Eric, 2016

## Environmental data
The data comes from Worldclim (middle-case scenario) and ESA

## Random forest
We chose the random forest algorithm because it uses a very simple machine learning approach, easily reproducible, and with generally good results even on small datasets as it is the case here.

## Bugs and difficulties
Many R packages used by other scientists were not up to date or didn't work on our data (scrubr for cleaning the data, terra for environmental data, mecofun for GLM, ...). Though we often found workarounds, this is particularly challenging for maps (joining, stacking, ...). Dealing with spatial data on R, especially with maps of different resolutions, is a problem we have not yet solved.

Many SDM tutorials are written by chunks, and the input data is reprocessed between the step. Here, we wanted to do everything on our own data and had to put the chunks together. This is something we have not yet succeeded to do.

## Acknowledgements
Project done as part of the bachelor's last semester, in université Côte d'Azur, Nice, France.
Conducted by two students of L3 BIM: Tidjani CISSE and Anaïs SPIRE.
Supervised by Franck DELAUNAY, Christophe BECAVIN, Simon GIREL.
