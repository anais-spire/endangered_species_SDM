# Environmental data

# https://damariszurell.github.io/EEC-MGC/b2_EnvData.html#1_Climate_data
# https://rspatial.org/raster/sdm/4_sdm_envdata.html

library(terra)
library(geodata)

folder_path <- "data/environmental_data"
getwd()

#  CLIMATE DATA (worldclim)

# A] CURRENT DATA

# download the 19 bioclimatic variables at a 10’ resolution
worldclim_current_data_10 <- geodata::worldclim_global(var = 'bio', res = 10, download = F, path = folder_path)
worldclim_current_data_10
# SpatRaster
# dimensions : nrow = 1080, ncol = 2160, nlyr = 19
# resolution : x = 0.1666667, y = 0.1666667
# extent : xmin = -180, xmax = 180, ymin = -90, ymax = 90
# sources : wc2.1_10m_bio_1.tif until 19.tif

plot(worldclim_current_data_10)
names(worldclim_current_data_10)

# DOESN'T WORK

# CROP TO THE REGION OF OUR INTEREST (BENIN, NIGERIA, ...)
# changing the extent doesn't affect the number of rows and columns of the raster object. It changes the resolution instead
worldclim_current_data_10_crop <- worldclim_current_data_10
e <- c(-3.5, 12, 3, 14)
ext(worldclim_current_data_10_crop) <- e
worldclim_current_data_10_crop
# resolution : x = 0.007175926, y = 0.01018519

crop(worldclim_current_data_10_crop, ext(-3.5, 12, 3, 14))
worldclim_current_data_10_crop
# WARNING! Resolution changes when changing the extent
# resolution : x = 0.007175926, y = 0.01018519

plot(worldclim_current_data_10_crop)
names(worldclim_current_data_10_crop)
# crop didn't work, why???

# DEALING WITH RESOLUTION
# res(worldclim_current_data_10) <- 1
# changing the resolution to 1 produces this warning: "SpatRaster has no cell values"


# B] FUTURE DATA
# Download future climate scenario from 'ACCESS-ESM1-5' climate model.
worldclim_fut_data_10 <- geodata::cmip6_world(model='ACCESS-ESM1-5', ssp='245', time='2041-2060', var='bioc', download=T, res=10, path= folder_path)
worldclim_fut_data_10
plot(worldclim_fut_data_10)
names(worldclim_fut_data_10)

# for the names, we choose to keep the names of the future data everywhere, because there are simpler
names(worldclim_current_data_10) <- names(worldclim_fut_data_10)

# CROP TO THE REGION OF OUR INTEREST (BENIN, NIGERIA, ...)
# changing the extent doesn't affect the number of rows and columns of the raster object. It changes the resolution instead
worldclim_fut_data_10_crop <- worldclim_fut_data_10
e <- c(-3.5, 12, 3, 14)
ext(worldclim_fut_data_10_crop) <- e
worldclim_fut_data_10_crop
# resolution : x = 0.007175926, y = 0.01018519

crop(worldclim_fut_data_10_crop, ext(-3.5, 12, 3, 14))
worldclim_fut_data_10_crop

plot(worldclim_fut_data_10_crop)
names(worldclim_fut_data_10_crop)

# C] SAVE CLIMATE DATA
current_env <- worldclim_current_data_10
future_env <- worldclim_fut_data_10
# in SpatRaster object
terra::writeRaster(worldclim_current_data_10, filename='data/environmental_data/bioclim_global_res10.grd')
terra::writeRaster(worldclim_fut_data_10, filename='data/environmental_data/bioclim_fut_global_res10.grd')
terra::writeRaster(worldclim_current_data_10_crop, filename='data/environmental_data/bioclim_global_res10_crop.grd')
terra::writeRaster(worldclim_fut_data_10_crop, filename='data/environmental_data/bioclim_fut_global_res10_crop.grd')

# in Rdata
save(worldclim_current_data_10, worldclim_fut_data_10, worldclim_current_data_10_crop, worldclim_fut_data_10_crop, file='data/environmental_data/cercopitheque_env.RData')




# LAND COVER DATA (ESA) : doesn't work...

# A] CURRENT DATA
trees_30sec <- geodata::landcover(var='trees', path=folder_path, download=F) # other variables : shrubs, grassland, cropland, bare, wetland, ...
plot(trees_30sec)

# Aggregate tree cover to 10-min spatial resolution (like the climate map)
trees_10 <- terra::aggregate(trees_30sec, fact=20, fun='mean') # min and max value of 0 -> doesn't work
trees_10
plot(trees_10)

# B] FUTURE DATA
# not available on ESA


# SOIL DATA
# not available




# !!!JOINING ENVIRONMENTAL DATA DOESN'T WORK!!!


# JOIN CURRENT ENVIRONMENTAL DATA (join bioclim + ESA)
# current_env <- c(worldclim_current_data_10, terra::extend(trees_10, worldclim_current_data_10))


# save joined environmental data
# save(joined_env, file='data/environmental_data/cercopitheque_joined_env.RData')