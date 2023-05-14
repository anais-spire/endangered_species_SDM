# Joined data (species + environmental data)
# Création d'un nouveau data frame avec les variables explicatives et la variable binaire de présence/absence
# chaque ligne est un point d'observation de l'espèce avec les variables climatiques associé au point géographique de présence


# JOIN SPECIES DATA AND ENVIRONMENTAL DATA
load(file='data/species_data/cercopitheque_coords.RData')
load(file='data/environmental_data/cercopitheque_env.RData')

current_env <- worldclim_current_data_10
future_env <- worldclim_fut_data_10

# quick look through our data again
head(cercopitheque_coords)
nrow(cercopitheque_coords)
current_env
plot(current_env)
future_env
plot(future_env)

# CURRENT DATA
head(terra::extract(x = current_env, 
                    y = data.frame(cercopitheque_coords[,c('Lon','Lat')]), cells=T ))
nrow(terra::extract(x = current_env, 
                    y = data.frame(cercopitheque_coords[,c('Lon','Lat')]), cells=T ))
# other syntax:
head(terra::extract(x = current_env, 
                    y = data.frame(cercopitheque_coords$Lon,cercopitheque_coords$Lat), cells=T ))
# visualization:
print(terra::extract(x = current_env, 
                     y = data.frame(cercopitheque_coords$Lon,cercopitheque_coords$Lat), cells=T ))
names((terra::extract(x = current_env, 
                      y = data.frame(cercopitheque_coords$Lon,cercopitheque_coords$Lat), cells=T )))

# Remark : We also extract the cellnumbers as this allows checking for duplicates later.

# We put species and environmental data into the same data frame:
cercopitheque_joined_current_data <- cbind(cercopitheque_coords, terra::extract(x = current_env, y = data.frame(cercopitheque_coords[,c('Lon','Lat')]), cells=T ))
head(cercopitheque_joined_current_data)
summary(cercopitheque_joined_current_data)
duplicated(cercopitheque_joined_current_data$cells) # 0 : we do not have any duplicate

# drop ID and cell column
cercopitheque_joined_current_data <- cercopitheque_joined_current_data[, -which(names(cercopitheque_joined_current_data) == "ID")]
cercopitheque_joined_current_data <- cercopitheque_joined_current_data[, -which(names(cercopitheque_joined_current_data) == "cell")]

# visualization again
head(cercopitheque_joined_current_data)
dim(cercopitheque_joined_current_data)


# FUTURE DATA

head(terra::extract(x = future_env, 
                    y = data.frame(cercopitheque_coords[,c('Lon','Lat')]), cells=T ))
# visualization:
print(terra::extract(x = current_env, 
                     y = data.frame(cercopitheque_coords$Lon,cercopitheque_coords$Lat), cells=T ))
names((terra::extract(x = current_env, 
                      y = data.frame(cercopitheque_coords$Lon,cercopitheque_coords$Lat), cells=T )))

# We put species and environmental data into the same data frame:
cercopitheque_joined_future_data <- cbind(cercopitheque_coords, terra::extract(x = future_env, y = data.frame(cercopitheque_coords[,c('Lon','Lat')]), cells=T ))
head(cercopitheque_joined_future_data)
summary(cercopitheque_joined_future_data)
duplicated(cercopitheque_joined_future_data$cells) # 0 : we do not have any duplicate

# drop the ID column
cercopitheque_joined_future_data <- cercopitheque_joined_future_data[, -which(names(cercopitheque_joined_future_data) == "ID")]
cercopitheque_joined_future_data <- cercopitheque_joined_future_data[, -which(names(cercopitheque_joined_future_data) == "cell")]

# visualization again
head(cercopitheque_joined_future_data)
dim(cercopitheque_joined_future_data)

# SAVE DATA
save(cercopitheque_joined_current_data, cercopitheque_joined_future_data, file='data/cercopitheque_joined_data.RData')
  