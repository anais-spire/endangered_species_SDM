# little modif

# https://stackoverflow.com/questions/52637004/mask-oceans-wrld-simpl

# For advice on how many background/pseudo-absence points you need, please read (Barbet-Massin et al. 2012)

library(dismo)

getwd()
load(file='../data/species_data/cercopitheque_gbif.RData')
sp <- cercopitheque_gbif_coords

# plot the map and data
e <- extent(-3.5, 12, 3, 14)
cercopitheque_region <- crop(wrld_simpl, e, filename='data/species_data/cercopitheque_region.grd')
typeof(cercopitheque_region)
plot(cercopitheque_region, axes=TRUE, col="light yellow")
box()
points(sp, col='red', pch=20, cex=1)

plot(wrld_simpl)
mask <- raster(wrld_simpl)
bg <- randomPoints(mask, 500)
points(bg, cex=0.5)

# dismo package
bg_rand <- 6+scale(dismo::randomPoints(raster(cercopitheque_region), 100)) # p = sp in order to avoid presence points but no
# bg_rand <- dismo::randomPoints(raster(cercopitheque_region), 100, p = sp)
points(bg_rand,col = 'magenta',pch=19,cex=0.3)





# terra package
bg_rand_t <- terra::spatSample(cercopitheque_region, 100, as.points=T, na.rm=T)
points(bg_rand_t,pch=19,cex=0.3)
