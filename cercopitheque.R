library(maptools)
# path <- "C:/Users/sa006427/OneDrive - Université Nice Sophia Antipolis/DL Maths-Bio/S6/SV/Projet pluridisciplinaire/0_Projet_especes_voie_disparition/Cercopitheque_rouge"
path <- "C:/Users/Anaïs/OneDrive - Université Nice Sophia Antipolis/DL Maths-Bio/S6/SV/Projet pluridisciplinaire/0_Projet_especes_voie_disparition/Cercopitheque_rouge"
setwd(path)
source("cercopitheque_data_visualization.R")


data(wrld_simpl)
lon_range <- c(range(myspecies_coords$Lon)[1]-1, range(myspecies_coords$Lon)[2]+2)
lat_range <- c(range(myspecies_coords$Lat)[1]-4, range(myspecies_coords$Lat)[2]+4)
plot(wrld_simpl, xlim=lon_range, ylim=lat_range, axes=TRUE, col="light yellow")
# restore the box around the map
box()
# add the points
points(myspecies_gbif$Lon, myspecies_gbif$Lat, col='red', pch=20, cex=1)
# plot points again to add a border, for better visibility
# points(myspecies_gbif$Lon, myspecies_gbif$Lat, col='red', cex=0.75)

# we can add administrative region using the raster package


