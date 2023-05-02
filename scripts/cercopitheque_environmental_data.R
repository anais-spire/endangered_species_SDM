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

# CROP TO THE REGION OF OUR INTEREST (BENIN, NIGERIA, ...)
# changing the extent doesn't affect the number of rows and columns of the raster object. It changes the resolution instead
e <- c(-3.5, 12, 3, 14)
ext(worldclim_current_data_10) <- e
worldclim_current_data_10
# resolution : x = 0.007175926, y = 0.01018519

crop(worldclim_current_data_10, ext(-3.5, 12, 3, 14))
worldclim_current_data_10

plot(worldclim_current_data_10)
names(worldclim_current_data_10)


# B] FUTURE DATA
# Download future climate scenario from 'ACCESS-ESM1-5' climate model.
worldclim_fut_data_10 <- geodata::cmip6_world(model='ACCESS-ESM1-5', ssp='245', time='2041-2060', var='bioc', download=T, res=10, path= folder_path)
worldclim_fut_data_10
plot(worldclim_fut_data_10)
names(worldclim_fut_data_10)

# for the names, we choose to keep the names of the future data everywhere, because there are simpler
names(worldclim_current_data_10) <- names(worldclim_fut_data_10)

# C] SAVE CLIMATE DATA (SpatRaster object)
terra::writeRaster(worldclim_current_data_10,filename='data/environmental_data/bioclim_global_res10.grd')
terra::writeRaster(worldclim_fut_data_10,filename='data/environmental_data/bioclim_fut_global_res10.grd')

# D] RELOAD SAVED CLIMATE DATA


# LAND COVER DATA (ESA) : doesn't work...

# A] CURRENT DATA
trees_30sec <- geodata::landcover(var='trees', path=folder_path, download=T) # other variables : shrubs, grassland, cropland, bare, wetland, ...
plot(trees_30sec)

# Aggregate tree cover to 10-min spatial resolution (like the climate map)
trees_10 <- terra::aggregate(trees_30sec, fact=20, fun='mean')

# B] FUTURE DATA
# not available on ESA


# SOIL DATA
# not available


# JOIN ENVIRONMENTAL DATA
current_env <- c(worldclim_current_data_10, terra::extend(trees_10, worldclim_current_data_10))
future_env <- worldclim_future_data_10


# JOIN ENVIRONMENTAL DATA AND SPECIES DATA
load(file='data/species_data/cercopitheque_gbif.RData')
names(cercopitheque_gbif)
head(cercopitheque_gbif)
head(cercopitheque_gbif_coords) # on revisualise nos données

head(terra::extract(x = current_env, 
                    y = data.frame(cercopitheque_gbif_coords), cells=T ))
# Remark : We also extract the cellnumbers as this allows checking for duplicates later.
# Finally, we put species and environmental data into the same data frame:
cercopitheque_gbif_env <- cbind(cercopitheque_gbif, terra::extract(x = current_env, y = data.frame(cercopitheque_gbif_coords), cells=T ))
head(cercopitheque_gbif_env)
summary(cercopitheque_gbif_env)
duplicated(cercopitheque_gbif_env$cells) # 0 : we do not have any duplicate

# save data
save(cercopitheque_gbif_env, file='data/cercopitheque_data.RData')

# RASTER DATA
files <- list.files(folder_path, pattern='grd$', full.names=TRUE )
files

