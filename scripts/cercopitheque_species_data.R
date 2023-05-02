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

# SPECIES DATA (cercopithecus, 67 data points)

cercopitheque_name <- c("Cercopithecus erythrogaster")
gbif_data <- occ_data(scientificName = cercopitheque_name, hasCoordinate = TRUE)
# file <- "../data/Cercopitheque_rouge.xls" # doesn't work and more complicated because I'd have to remove rows without coordinates

gbif_data
names(gbif_data)
names(gbif_data$meta)
names(gbif_data$data)
gbif_citation(gbif_data) # sources of the datasets (gbif), occ_download needs a username so we use the old way

# we keep only relevant information for us (we shrink the 'data' dataframe to only relevant columns)
cercopitheque_gbif <- gbif_data$data[ , c("key", "scientificName", "decimalLongitude", "decimalLatitude", "coordinateUncertaintyInMeters", "locality", "stateProvince", "individualCount", "occurrenceStatus", "speciesKey","species", "year", "basisOfRecord", "institutionCode", "references")]
names(cercopitheque_gbif)[3] <- "Lon"
names(cercopitheque_gbif)[4] <- "Lat"
head(cercopitheque_gbif)
nrow(cercopitheque_gbif) # number of rows, ie points of observation of the species
# the CSV file from gbif had 117 points but only 67 have lat and lon coordinates

# a first map to have a first look at the data
map("world", xlim = range(cercopitheque_gbif[3]), ylim = range(cercopitheque_gbif[4])) # if the map doesn't appear right at first, run this command again
points(cercopitheque_gbif[ , c("Lon", "Lat")], pch = "o")
# you may notice (especially if you zoom in, e.g. by specifying a smaller range of coordinates under 'xlim' and 'ylim' above) that many points are too regularly spaced to be exact locations of species sightings; rather, such points are likely to be centroids of (relatively large) grid cells on which particular surveys was based, so remember to adjust the spatial resolution of your analysis accordingly!



# SPECIES DATA CLEANING

# remove duplicated data
cercopitheque_gbif <- unique(cercopitheque_gbif)
nrow(cercopitheque_gbif) 
# at this step, still 67 rows, no duplicates detected

# more restrictive (as soon as Lon and Lat coordinates are the same, we remove)
dups <- duplicated(cercopitheque_gbif[, c('Lon', 'Lat')])
sum(dups)
cercopitheque_gbif  <-  cercopitheque_gbif[!dups, ]
nrow(cercopitheque_gbif)
# at this step, we removed 8 duplicated rows, we now have 59 points

# remove records of absence or zero-abundance (if any):
names(cercopitheque_gbif)
sort(unique(cercopitheque_gbif$individualCount))  # notice if some points correspond to zero abundance
sort(unique(cercopitheque_gbif$occurrenceStatus))  # check for different indications of "absent", which could be in different languages! and remember that R is case-sensitive
absence_rows <- which(cercopitheque_gbif$individualCount == 0 | cercopitheque_gbif$occurrenceStatus %in% c("absent", "Absent", "ABSENT", "ausente", "Ausente", "AUSENTE"))
length(absence_rows)
if (length(absence_rows) > 0) {
  cercopitheque_gbif <- cercopitheque_gbif[-absence_rows, ]
}
nrow(cercopitheque_gbif) 
# at this step, still 59 rows, no duplicates detected

# SCRUBR package cleaning (doesn't work!)
# This cleaning is important and not exhaustive for SDM)
# cercopitheque_coords <- coord_incomplete(coord_imprecise(coord_impossible(coord_unlikely(cercopitheque_coords))))
# nrow(cercopitheque_coords)  # nb de lignes, ie points d'observation de l'espèce après 2eme nettoyage
# cercopitheque_coords <- coord_uncertain(cercopitheque_coords, coorduncertainityLimit = 5000)
# nrow(cercopitheque_coords)
# map the cleaned occurrence data:
#map("world", xlim = range(cercopitheque_coords$Lon), ylim = range(cercopitheque_coords$Lat))  # if the map doesn't appear right at first, run this command again
# points(cercopitheque_coords[ , c("decimalLongitude", "decimalLatitude")], pch = ".")
# possible erroneous points e.g. on the Equator (lat and lon = 0) should have disappeared now
# map the cleaned occurrence records with a different colour on top of the raw ones:
points(cercopitheque_gbif[ , c("Lon", "Lat")], pch = 50, col = "turquoise")

# cross-checking : we remove points that do not match any country (in an ocean) + points with coordinates that are in a different country than listed in the ‘country’ field of the gbif record
cercopitheque_gbif_spatial <- cercopitheque_gbif
coordinates(cercopitheque_gbif_spatial) <- ~Lon+Lat # create SpatialPointsDataFrame
typeof(cercopitheque_gbif_spatial)
data("wrld_simpl")
crs(cercopitheque_gbif_spatial) <- crs(wrld_simpl)
ovr <- over(cercopitheque_gbif_spatial, wrld_simpl)
head(ovr)
cntr <- ovr$NAME
i <- which(is.na(cntr))
i
j <- which(cntr != cercopitheque_gbif_spatial$country)
cbind(cntr, cercopitheque_gbif_spatial$country)[j,]
# on the map: check the outlier points in red
plot(cercopitheque_gbif_spatial)
plot(wrld_simpl, add=T, border='blue', lwd=2)
points(cercopitheque_gbif_spatial[j, ], col='red', pch=20, cex=2) 
# we do not have any reds, so we do not have any outlier points



# ADD POINTS MANUALLY (incomplete data from gbif, add points found in the literature)

# georeferencing : give coordinates to points where only the city/locality is given
georef <- subset(cercopitheque_gbif, (is.na(Lon) | is.na(Lat)) & ! is.na(locality) )
nrow(georef)
# no such coordinates found, no need for georeferencing

# we now keep only the coordinates, because it is easier to add lines to a table with 2 columns than 15 columns 
# (loss of information is not too important for us because we have very few points and can always go back to the big data frame if we want to)
cercopitheque_gbif_coords <- cercopitheque_gbif[,3:4]
head(cercopitheque_gbif_coords)

# add points
# we add the point from the following article: Togo study by Agbessi
new_coords <- data.frame(Lon=c(1.31139, 1.31122, 1.32418, 1.32344, 1.28008, 1.27593), 
                         Lat=c(6.43095, 6.43073, 6.50023, 6.49171, 6.48166, 6.48218))
new_coords
cercopitheque_gbif_coords <- rbind(cercopitheque_gbif_coords, new_coords)
cercopitheque_gbif_coords
nrow(cercopitheque_gbif_coords)
# at this step, 6 lines were added, we now have 65 rows

# Subsampling to avoid sampling bias
# Not done here, we do not have enough points to do that
 

# FINAL MAPPING OF OUR POINTS

# find the right extent
xmin <- range(cercopitheque_gbif_coords$Lat)[1]-4
xmax <- range(cercopitheque_gbif_coords$Lat)[2]+4
lat_range <- c(xmin, xmax)
ymin <- range(cercopitheque_gbif_coords$Lon)[1]-1
ymax <- range(cercopitheque_gbif_coords$Lon)[2]+2
lon_range <- c(ymin, ymax)

# map (wrld_simpl from maptools package)
data(wrld_simpl)
plot(wrld_simpl, xlim=lon_range, ylim=lat_range, axes=TRUE, col="light yellow")
box()
# add the observation points
points(cercopitheque_gbif_coords$Lon, cercopitheque_gbif_coords$Lat, col='red', pch=20, cex=1)
# plot points again to add a border, for better visibility
# points(cercopitheque_gbif$Lon, cercopitheque_gbif$Lat, col='red', cex=0.75)

# Remark : we could also add administrative region using the raster package (but not necessary here)

# SAVE THE DATA
save(cercopitheque_gbif, cercopitheque_gbif_coords, file='data/species_data/cercopitheque_gbif.RData')

#lsdata('data/species_data/cercopitheque_gbif.RData')