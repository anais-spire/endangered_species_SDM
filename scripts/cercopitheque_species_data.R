# Species data

# https://damariszurell.github.io/EEC-MGC/b1_SpeciesData.html
# https://rspatial.org/raster/sdm/2_sdm_occdata.html
# https://www.r-bloggers.com/2021/03/downloading-and-cleaning-gbif-data-with-r/

library(rgbif) # package for importing datasets from gbif
# 4 packages for maps:
library(maps)
library(maptools)
library(sp)
library(raster)


# library(scrubr) # package to clean the data
# install.packages("remotes")
# remotes::install_github("ropensci/scrubr")

# SPECIES DATA (colobus vellerosus, 146 points de données)

cercopitheque_name <- c("Cercopithecus erythrogaster")
gbif_data <- occ_data(scientificName = cercopitheque_name, hasCoordinate = TRUE)
# file <- "../data/Cercopitheque_rouge.xls" # doesn't work and more complicated because I'd have to remove rows without coordinates

gbif_data
names(gbif_data)
names(gbif_data$meta)
names(gbif_data$data)
gbif_citation(gbif_data) # sources of the datasets

# CARTE DES POINTS DE DONNEES

cercopitheque_gbif <- gbif_data$data[ , c("key", "scientificName", "decimalLongitude", "decimalLatitude", "coordinateUncertaintyInMeters", "individualCount", "occurrenceStatus", "speciesKey","species", "year", "basisOfRecord", "institutionCode", "references")]
names(cercopitheque_gbif)[3] <- "Lon"
names(cercopitheque_gbif)[4] <- "Lat"
head(cercopitheque_gbif)
nrow(cercopitheque_gbif) # nb de lignes, ie de points d'observation de l'espèce
# jeu de données CSV de 117 mais seulement 67 avec des lat/lon

cercopitehque_gbif_coords <- cercopitheque_gbif[,3:4]
head(cercopitehque_gbif_coords)

# save the data in R
save(cercopitheque_gbif, cercopitheque_gbif_coords, file='data/species_data/cercopitheque_gbif.RData')

lsdata('data/species_data/cercopitheque_gbif.RData')

smap("world", xlim = range(cercopitheque_coords$Lon), ylim = range(cercopitheque_coords$Lat)) # if the map doesn't appear right at first, run this command again
points(cercopitheque_coords[ , c("Lon", "Lat")], pch = ".")
# you may notice (especially if you zoom in, e.g. by specifying a smaller range of coordinates under 'xlim' and 'ylim' above) that many points are too regularly spaced to be exact locations of species sightings; rather, such points are likely to be centroids of (relatively large) grid cells on which particular surveys was based, so remember to adjust the spatial resolution of your analysis accordingly!

# SPECIES DATA CLEANING

# remove duplicated data
cercopitheque_gbif <- unique(cercopitheque_gbif)
nrow(cercopitheque_gbif)
# plus restrictif (dès que Lon, Lat identiques, on enlève)
dups <- duplicated(cercopitheque_gbif[, c('Lon', 'Lat')])
sum(dups)
cercopitheque_gbif  <-  cercopitheque_gbif[!dups, ]

# remove records of absence or zero-abundance (if any):
names(cercopitheque_gbif)
sort(unique(cercopitheque_gbif$individualCount))  # notice if some points correspond to zero abundance
sort(unique(cercopitheque_gbif$occurrenceStatus))  # check for different indications of "absent", which could be in different languages! and remember that R is case-sensitive
absence_rows <- which(cercopitheque_gbif$individualCount == 0 | cercopitheque_coords$occurrenceStatus %in% c("absent", "Absent", "ABSENT", "ausente", "Ausente", "AUSENTE"))
length(absence_rows)
if (length(absence_rows) > 0) {
  cercopitheque_gbif <- cercopitheque_gbif[-absence_rows, ]
}
nrow(cercopitheque_gbif) # nb de lignes, ie points d'observation de l'espèce après 1er nettoyage

# let's do some further data cleaning with functions of the 'scrubr' package (this cleaning is not exhaustive)
# cercopitheque_coords <- coord_incomplete(coord_imprecise(coord_impossible(coord_unlikely(cercopitheque_coords))))
# nrow(cercopitheque_coords)  # nb de lignes, ie points d'observation de l'espèce après 2eme nettoyage
# cercopitheque_coords <- coord_uncertain(cercopitheque_coords, coorduncertainityLimit = 5000)
# nrow(cercopitheque_coords)
# map the cleaned occurrence data:
#map("world", xlim = range(cercopitheque_coords$Lon), ylim = range(cercopitheque_coords$Lat))  # if the map doesn't appear right at first, run this command again
# points(cercopitheque_coords[ , c("decimalLongitude", "decimalLatitude")], pch = ".")
# possible erroneous points e.g. on the Equator (lat and lon = 0) should have disappeared now

# map the cleaned occurrence records with a different colour on top of the raw ones:
points(cercopitheque_gbif[ , c("Lon", "Lat")], pch = 20, cex = 0.5, col = "turquoise")

# cross-checking : points that do not match any country (in an ocean) + points with coordinates that are in a different country than listed in the ‘country’ field of the gbif record
coordinates(cercopitheque_gbif) <- ~Lon+Lat # create SpatialPointsDataFrame
crs(cercopitheque_gbif) <- crs(wrld_simpl)
ovr <- over(cercopiteque_gbif, wrld_simpl)
head(ovr)
cntr <- ovr$NAME
i <- which(is.na(cntr))
i
j <- which(cntr != cercopitheque_gbif$country)
cbind(cntr, cercopitheque_gbif$country)[j,]
plot(cercopitheque_gbif)
plot(wrld_simpl, add=T, border='blue', lwd=2)
points(cercopitheque_gbif[j, ], col='red', pch=20, cex=2) # we dont have any reds, so we don't have any outlier points

# geoferencing : give coordinates to points where only the city/locality is given
georef <- subset(cercopitehque_gbif, (is.na(lon) | is.na(lat)) & ! is.na(locality) )
dim(georef)


# Subsampling to avoid sampling bias
# /
 
# a better plot
data(wrld_simpl)
lon_range <- c(range(cercopitheque_coords$Lon)[1]-1, range(cercopitheque_coords$Lon)[2]+2)
lat_range <- c(range(cercopitheque_coords$Lat)[1]-4, range(cercopitheque_coords$Lat)[2]+4)
plot(wrld_simpl, xlim=lon_range, ylim=lat_range, axes=TRUE, col="light yellow")
box()
# add the points
points(cercopitheque_gbif$Lon, cercopitheque_gbif$Lat, col='red', pch=20, cex=1)
# plot points again to add a border, for better visibility
# points(cercopitheque_gbif$Lon, cercopitheque_gbif$Lat, col='red', cex=0.75)

# we could add administrative region using the raster package (but not necessary here)
