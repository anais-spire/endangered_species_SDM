# pseudoabsence points with kludge (randomness on some parts of the map, not everywhere, no calculated avoidance of presence regions)

library(maptools)
load(file='data/species_data/cercopitheque_gbif.RData')

e <- extent(-3.5, 12, 3, 14)
data(wrld_simpl)
plot(wrld_simpl, xlim=c(-3.5, 12), ylim=c(3, 14), axes=TRUE, col="light yellow")
box()
points(cercopitheque_gbif_coords$Lon, cercopitheque_gbif_coords$Lat, col='red', pch=20, cex=1)
legend("bottomleft", legend = c("Presence"), col = c("red"), pch = 20)

# ADD 100 RANDOM POINTS
# random on x=-3.5-10, y = 7-14 /// x = 10-12, y=3, 14
# the first surface is 45,5 res²
# the second surface is 22 res²
# overall : 67,4% for the 1st surface, 32,6% for the 2nd surface
# thus, we're going to ask for 67 points for the 1st surface and 33 for the second surface (100 points in total)
pseudo_absence_points_1 <- data.frame(Lon = runif(n=67, min=-3.5, max=10), Lat = runif(n=67, min=7, max=14))
pseudo_absence_points_1
points(pseudo_absence_points_1$Lon, pseudo_absence_points_1$Lat, col='blue', pch=20, cex=1)

pseudo_absence_points_2 <- data.frame(Lon = runif(n=33, min=10, max=12), Lat = runif(n=33, min=3, max =14))
pseudo_absence_points_2
points(pseudo_absence_points_2$Lon, pseudo_absence_points_2$Lat, col='green', pch=20, cex=1)

pseudo_absence_points <- rbind(pseudo_absence_points_1, pseudo_absence_points_2)
points(pseudo_absence_points$Lon, pseudo_absence_points$Lat, col='black', pch=20, cex=1)

# placement of points by hand in other regions (we didn't use it in the end)
# pseudo_absence_points_3 <- data.frame(Lat = c(-1), Lon = c(6))
# points(points(pseudo_absence_points_3$Lon, pseudo_absence_points_3$Lat, col='green', pch=20, cex=1))

# uptades of the dataframe to indicate presence or absence
cercopitheque_gbif_coords$presence_cercopitheque <- rep(1, nrow(cercopitheque_gbif_coords))
pseudo_absence_points$presence_cercopitheque <- rep(0, nrow(pseudo_absence_points))
cercopitheque_coords <- rbind(cercopitheque_gbif_coords, pseudo_absence_points)

cercopitheque_coords

# SAVE
save(cercopitheque_coords, file='data/species_data/cercopitheque_coords.RData')


# MAP VISUALIZATION
# map with legend + color from the datafram cercopitheque_coords only
# We create a vector of colors based on the third column of cercopitheque_coords
point_colors <- ifelse(cercopitheque_coords$presence_cercopitheque == 1, "red", "black")

# Plot the points with the new colors and legend
points(cercopitheque_coords$Lon, cercopitheque_coords$Lat, col = point_colors, pch = 20, cex = 1)
legend("bottomleft", legend = c("Presence", "Absence"), col = c("red", "black"), pch = 20)