# https://damariszurell.github.io/EEC-MGC/a1_SpatialData.html
# https://pialentini.com/2018/01/25/getting-spatial-data-into-shape-for-species-distribution-modelling-sdms/

install.packages(c('terra'), dep=T)
library(terra)

set.seed(12345) # We set a seed for the random number generator, so that we all obtain the same results

coords <- cbind(
  x <- rnorm(10, sd=2),
  y <- rnorm(10, sd=2)
)

str(coords)
plot(coords)
sp <- terra::vect(coords)
class(sp)
sp
sp <- terra::vect(coords, crs = '+proj=longlat +datum=WGS84')
sp
terra:: values(sp) <- cercopitheque_gbif
sp
