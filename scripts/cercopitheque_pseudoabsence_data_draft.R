# pseudo-absence data

# THIS SCRIPT DOESN'T WORK (problem of packages + map resolution + mask for the oceans)
# SEE CERCOPITHEQUE_PSEUDOABSENCE_DATA_KLUDGE INSTEAD!! This script is a workaround for the parts that do not work here. It is not perfect in terms of randomness but it does the job.

# https://stackoverflow.com/questions/52637004/mask-oceans-wrld-simpl
# For advice on how many background/pseudo-absence points you need, please read (Barbet-Massin et al. 2012)

# map packages
library(dismo)
library(maps)
library(maptools)
library(sp)

# get the files
getwd()
load(file='data/species_data/cercopitheque_gbif.RData')
file <- 'data/species_data/cercopitheque_region.grd'


# save map of cercopitheque_region in grd file
e <- extent(-3.5, 12, 3, 14)
cercopitheque_region <- crop(wrld_simpl, e, filename='data/species_data/cercopitheque_region.grd')
typeof(cercopitheque_region)
raster(cercopitheque_region)
# RasterLayer
# dimensions : nrow = 10, ncol = 10, ncell = 100
# resolution : x = 1.55, y = 1.1
# extent : xmin = -3.5, xmax = 12, ymin = 3, ymax = 14
# sources : wc2.1_10m_bio_1.tif until 19.tif

# plot the map and data
plot(cercopitheque_region, axes=TRUE, col="light yellow")
box()
points(cercopitheque_gbif_coords, col='red', pch=20, cex=1)

# transform to raster object (sometimes called mask : mask <- raster(cercopitheque_region))
raster(cercopitheque_region)
# RasterLayer
# Dimensions : 10, 10, 100
# Resolution : 1.55, 1.1

bg <- 0.1*randomPoints(raster(cercopitheque_region), 500) #warning: changed n to ncell of the mask
points(bg, cex=0.5)

# sampleRandom
sampleRandom(raster(cercopitheque_region), size = 100)
sampleRandom(raster(cercopitheque_region), size = 100, cells=TRUE, sp=TRUE)


# dismo package
bg_rand <- 6+scale(dismo::randomPoints(raster(cercopitheque_region), 100)) # p = sp in order to avoid presence points but no
bg_rand <- dismo::randomPoints(raster(cercopitheque_region), 50, p = cercopitheque_gbif_coords)
points(bg_rand,col = 'magenta',pch=19,cex=0.3)

# terra package
bg_rand_t <- terra::spatSample(raster(cercopitheque_region), 100, as.points=T, na.rm=T)
points(bg_rand_t,pch=19,cex=0.3)

bg_rand_2 <- terra::randomPoints(raster(cercopitheque_region), n=50)
points(bg_rand_2, col='blue', pch=20, cex=1)