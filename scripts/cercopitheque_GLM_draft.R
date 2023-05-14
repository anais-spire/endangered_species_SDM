# GLM (from Tidjani files)

library(terra)
library(sp)
library(terra)
library(geodata)
library(raster)

#  CLIMATE DATA (worldclim)
wrld_simpl <- getData("worldclim", var="alt", res= 10)
plot(wrld_simpl)
folder_path <- ("C:\\Users\\33769\\OneDrive\\Bureau\\cours L3 Bioinfo Unice\\S6\\pluridisciplinaire_version2\\data\\environmental_data\\Worldclim")
getwd()
terra::aggregate(clim[[1]], fact=6, fun="mean")

# A] CURRENT DATA

# download the 19 bioclimatic variables at a 10’ resolution
clim <- geodata::worldclim_global(var = 'bio', res = 10, download = F, path = 'data')
clim
plot(clim)
# on peut crop les data avec terra


# B] FUTURE DATA
# Download future climate scenario from 'ACCESS-ESM1-5' climate model.
# Please note that you have to set download=T if you haven't downloaded the data before:
clim_fut <- geodata::cmip6_world(model='ACCESS-ESM1-5', ssp='245', time='2041-2060', var='bioc', download=F, res=10, path='data')

# Inspect the SpatRaster object:
clim_fut
#Nous voyons que les SpatRaster objets climatiques actuels et futurs ont des noms de couches différents. Cela pourrait causer des problèmes dans 
#la modélisation de la distribution et nous voulons donc nous assurer qu'ils ont tous les mêmes noms de couches

# we keep the names of the future data cuz there are simpler
names(clim) <- names(clim_fut)
names(clim)
names(clim_fut)
getwd()
# C] SAVE CLIMATE DATA (SpatRaster object)
terra::writeRaster(clim,filename='data/bioclim_global_res10.grd',overwrite=TRUE)
terra::writeRaster(clim_fut,filename='data/bioclim_fut_global_res10.grd',overwrite=TRUE)



# LAND COVER DATA (ESA) : marche

# Installation du package "raster" si nécessaire
# install.packages("raster")

# Chargement du package "raster"
library(raster)

# Téléchargement des données de couverture terrestre globale de 2015 (version 2.0.7) depuis l'ESA
lc_data <- getData("worldclim", var="bio", res=10)

# Affichage des informations sur les données téléchargées
print(lc_data)


# A] CURRENT DATA
trees_30sec <- geodata::landcover(var='trees', path='https://biogeo.ucdavis.edu/data/climate/worldclim/1_4/grid/cur/bio_10m_bil.zip', download=F)
trees_30sec

# map the tree cover
plot(trees_30sec)

# Aggregate tree cover to 10-min spatial resolution (like the climate map)
trees_10 <- terra::aggregate(trees_30sec, fact=20, fun='mean')
trees_10
plot(trees_10)

env_cur <- c(clim, trees_10)

terra::ext(clim)

terra::ext(trees_10)

terra::extend(trees_10, clim)

env_cur <- c(clim, terra::extend(trees_10, clim))

env_cur
load("C:/Users/33769/OneDrive/Bureau/cours L3 Bioinfo Unice/S6/pluridisciplinaire_version2/data.RData")
head(cercopitheque_gbif)
load("C:/Users/33769/OneDrive/Bureau/cours L3 Bioinfo Unice/S6/pluridisciplinaire_version1/cercopitheque_coords.RData")
cercopitheque_coords
nrow(cercopitheque_coords)
pseudo_absence_points_1 <- data.frame(Lon = runif(n=67, min=-3.5, max=10), Lat = runif(n=67, min=7, max=14))
pseudo_absence_points_1
points(pseudo_absence_points_1$Lon, pseudo_absence_points_1$Lat, col='blue', pch=20, cex=1)

pseudo_absence_points_2 <- data.frame(Lon = runif(n=33, min=10, max=12), Lat = runif(n=33, min=3, max =14))
pseudo_absence_points_2
points(pseudo_absence_points_2$Lon, pseudo_absence_points_2$Lat, col='green', pch=20, cex=1,xlim=c(-3, 15),ylim=c(4, 13))

pseudo_absence_points <- rbind(pseudo_absence_points_1, pseudo_absence_points_2)
points(pseudo_absence_points$Lon, pseudo_absence_points$Lat, col='black', pch=20, cex=1)
point_colors <- ifelse(cercopitheque_coords$presence_cercopitheque == 1, "red", "black")

names(cercopitheque_coords)
#cercopitheque_gbif_2 <- cercopitheque_gbif[,c("key", "scientificName", "Lat", "Lon", "basisOfRecord", "speciesKey", "species", "year","occurrenceStatus")]

#cercopitheque_gbif_2

#head(terra::extract(x = env_cur, y = data.frame(cercopitheque_gbif_2[,c('Lon','Lat')]), cells=T ))

head(terra::extract(x = env_cur, 
                    y = data.frame(cercopitheque_coords$Lon,cercopitheque_coords$Lat), cells=T ))

print(terra::extract(x = env_cur, 
                y = data.frame(cercopitheque_coords$Lon,cercopitheque_coords$Lat), cells=T ))
names((terra::extract(x = env_cur, 
                      y = data.frame(cercopitheque_coords$Lon,cercopitheque_coords$Lat), cells=T )))
# Finally, we put species and environmental data into the same data frame:
cercopitheque_gbif_2.2 <- cbind(cercopitheque_coords, terra::extract(x = env_cur, y = data.frame(cercopitheque_coords[,c('Lon','Lat')]), cells=T ))

cercopitheque_gbif_2.2
names(cercopitheque_gbif_2.2)

summary(cercopitheque_gbif_2.2)

#duplicated(cercopitheque_gbif_2.2$cells)

#cercopithecus_gbif_env <- cercopitheque_gbif_2.2[!duplicated(cercopitheque_gbif_2.2$cells),]
#cercopithecus_gbif_env
#names(cercopithecus_gbif_env)

save(cercopitheque_gbif_2.2,file='C:/Users/33769/OneDrive/Bureau/cours L3 Bioinfo Unice/S6/pluridisciplinaire_version1/cercopitheque_coords.RData')

# PARC MODELISATION 

library(terra)
library(maps)

#presence <- ifelse(!is.na(cercopitheque_coords$presence_cercopitheque), 1, 0)
presence<-ifelse(cercopitheque_coords$presence_cercopitheque == 1, "red", "black")
presence
map("world", xlim = range(cercopitheque_coords$Lon), ylim = range(cercopitheque_coords$Lat)) # if the map doesn't appear right at first, run this command again
points(cercopitheque_coords$Lon, cercopitheque_coords$Lat, pch = 19,col = presence)
#plot(cercopitheque_gbif_2.2[ , c("Lon", "Lat")],col=c('turquoise','red'),axes=F)
names(presence)


clim

# Filtrer les données en éliminant les lignes avec des valeurs manquantes pour scientificName
cercopitheque_gbif_filtered <- cercopitheque_coords[complete.cases(cercopitheque_coords$presence_cercopitheque),]

cercopitheque_gbif_filtered

# Créer le vecteur de présence/absence basé sur cercopitheque_gbif_filtered
presence_cerco <- ifelse(!is.na(cercopitheque_coords$presence_cercopitheque), 1, 0)
presence_cerco
presence

# Création d'un nouveau data frame avec les variables explicatives et la variable binaire de présence/absence
# chaque ligne est un point d'observation de l'espèce avec les variables climatiques associé au point géographique de présence
cercopitheque_coords
#df <- data.frame(presence= presence_cerco, bio1 = )

df <- data.frame(presence_c = presence_cerco, # nom de colonne 1 : presence_cercopitheque
                 bio01 = cercopitheque_gbif_2.2$bio01, # nom de colonne 2 : bio1
                 bio02 = cercopitheque_gbif_2.2$bio02,
                 bio03 = cercopitheque_gbif_2.2$bio03,
                 bio04 = cercopitheque_gbif_2.2$bio04,
                 bio05 = cercopitheque_gbif_2.2$bio05,
                 bio06 = cercopitheque_gbif_2.2$bio06,
                 bio07 = cercopitheque_gbif_2.2$bio07,
                 bio08 = cercopitheque_gbif_2.2$bio08,
                 bio09 = cercopitheque_gbif_2.2$bio09,
                 bio10 = cercopitheque_gbif_2.2$bio10,
                 bio11 = cercopitheque_gbif_2.2$bio11,
                 bio12 = cercopitheque_gbif_2.2$bio12,
                 bio13 = cercopitheque_gbif_2.2$bio13,
                 bio14 = cercopitheque_gbif_2.2$bio14,
                 bio15 = cercopitheque_gbif_2.2$bio15,
                 bio16 = cercopitheque_gbif_2.2$bio16,
                 bio17 = cercopitheque_gbif_2.2$bio17,
                 bio18 = cercopitheque_gbif_2.2$bio18,
                 bio19 = cercopitheque_gbif_2.2$bio19)
df
names(df)

# Ajouter les nouvelles colonnes au data frame df
#presence <- ifelse(!is.na(cercopitheque_gbif_2$scientificName), 1, 0)
#df$bio010 <- cercopitheque_gbif_2$bio010
#df$bio011 <- cercopitheque_gbif_2$bio011
#df$bio012 <- cercopitheque_gbif_2$bio012
#df$bio013 <- cercopitheque_gbif_2$bio013
#df$bio014 <- cercopitheque_gbif_2$bio014
#df$bio015 <- cercopitheque_gbif_2$bio015
#df$bio016 <- cercopitheque_gbif_2$bio016
#df$bio017 <- cercopitheque_gbif_2$bio017
#df$bio018 <- cercopitheque_gbif_2$bio018
#df$bio019 <- cercopitheque_gbif_2$bio019
cercopitheque_gbif_2$bio010
cercopitheque_gbif_2$bio011
cercopitheque_gbif_2$bio012
cercopitheque_gbif_2$bio09
cercopitheque_gbif_2$bio018
df10<- cercopitheque_gbif_2$bio010
df10

# Créer une liste de vecteurs aléatoires pour les 10 nouvelles colonnes
#new_cols <- list(
  #bio010 = rnorm(nrow(df)),
 # bio011 = rnorm(nrow(df)),
#  bio012 = rnorm(nrow(df)),
#  bio013 = rnorm(nrow(df)),
#  bio014 = rnorm(nrow(df)),
#  bio015 = rnorm(nrow(df)),
#  bio016 = rnorm(nrow(df)),
#  bio017 = rnorm(nrow(df)),
#  bio018 = rnorm(nrow(df)),
 # bio019 = rnorm(nrow(df)))
# Ajouter les nouvelles colonnes au data frame df
df

# Modèle de régression logistique (GLM)
#GLM plus complexes
m1 <- glm(presence_c~ bio01, family = "binomial", data = df)
summary(m1)

m2 <- glm(presence_c ~ bio01 + I(bio01^02), family="binomial", data= df)
summary(m2)

# Or use the poly() function:
summary( glm(presence_c ~ poly(bio01,02) , family="binomial", data= df) )
summary( glm(presence_c ~ poly(bio01,03) , family="binomial", data= df) )

# Fit two linear variables:
summary( glm(cercopitheque_gbif_2.2 ~ bio01:bio19, family="binomial", data= df))

# Fit three linear variables:
summary( glm(presence_c~ bio01 + bio02+ bio03+ bio04+ bio05+ bio06+ bio07+ bio08+ bio09 + bio10 + bio11+ bio12+ bio13+ bio14+ bio15+ bio16+ bio17+ bio18+ bio19 ,
             family="binomial", data= df) )

# Fit three linear variables with up to three-way interactions
summary( glm(presence_c ~ bio01 * bio02 * bio03, family="binomial", data= df) )


summary( glm(presence_c ~ bio04 * bio05 * bio06, family="binomial", data= df) )

summary( glm(presence_c ~ bio07 * bio08 * bio09, family="binomial", data= df) )

# Fit three linear variables with up to two-way interactions
summary( glm(presence_c ~ bio01 + bio04 + bio07 + 
               bio01:bio04 + bio01:bio07 + bio04:bio07, 
             family="binomial", data= df) )

#install.packages('glm')
library(glm)

library(corrplot)

# We first estimate a correlation matrix from the predictors. 
# We use Spearman rank correlation coefficient, as we do not know 
# whether all variables are normally distributed.
cor_mat <- cor(df[,-c(1:3)], method='spearman')
cor_mat
# We can visualise this correlation matrix. For better visibility, 
# we plot the correlation coefficients as percentages.
corrplot.mixed(cor_mat, tl.pos='lt', tl.cex=0.6, number.cex=0.5, addCoefasPercent=T)

df
# alternaalternative à mecofun pour selectionner les meilleure variables
library(caret)

# Sélectionner les variables à partir desquelles sélectionner
X <- df[, 2:20]
#  Colinéarité et sélection de variables
# Corrélation entre les prédicteurs
# Trouver les variables hautement corrélées
corr_matrix <- cor(X)
highly_correlated_vars <- findCorrelation(corr_matrix, cutoff = 0.7)
str(highly_correlated_vars)
#Sélection des variables : suppression des variables hautement corrélées

# Sélectionner les variables non hautement corrélées
selected_vars <- X[, -highly_correlated_vars]
selected_vars
select<-str(selected_vars)

sum(df$presence_c)


#Sélection du modèle


#Maintenant que nous avons sélectionné un ensemble de variables faiblement corrélées, 
#nous pouvons ajuster le modèle complet puis le simplifier. Cette dernière est généralement 
#appelée sélection de modèle. Ici, je n'utilise que les deux variables les plus importantes et 
#j'inclus des termes linéaires et quadratiques dans le modèle complet.

m_full <- glm( presence_c ~ bio08 + I(bio08^06) + bio11 + I(bio11^06) + bio14 + I(bio14^06)+ bio16 + I(bio16^06),
               family='binomial', data=df)
summary(m_full)

extractAIC(m_full, scale = 0, k = 2)



m_step <- step(m_full) 
summary(m_step)

head(predict(m_step, type='response'))
names(m_step)
head(m_step$fitted)


#Évaluation du modèle

# Visualisation des courbes de réponse


# Wwe want to make predictions for all combinations of the two predictor variables
# and along their entire environmental gradients:
xyz <- expand.grid(
  # We produce a sequence of environmental values within the predictor ranges:
  bio08 = seq(min(df$bio08),max(df$bio08),length=30),
  bio14 = seq(min(df$bio14),max(df$bio14),length=30))

# Now we can make predictions to this new data frame
xyz$z <- predict(m_step, newdata=xyz, type='response')
xyz$z
class(xyz$z)
summary(xyz)
xyz
summary(xyz$z)
subset(xyz$z)

# As result, we have a 3D data structure and want to visualise this.
# Here, I first set a color palette
library(RColorBrewer)
cls <- colorRampPalette(rev(brewer.pal(11, 'RdYlBu')))(30)

# Finally, we plot the response surface using the wireframe function from the lattice package
library(lattice)
wireframe( z~ bio08 + bio14, data = xyz, zlab = list("Occurrence prob.", rot=90), 
          drape = TRUE, col.regions = cls,
          scales = list(arrows = F),
          zlim = c(0, 1),
          main = "Carte de probabilité d'occurrence du\n cercopitheque erythrogaster")


# We can also rotate the axes to better see the surface
wireframe(z ~ bio08 + bio14, data = xyz, zlab = list("Occurrence prob.", rot=90), 
          drape = TRUE, col.regions = cls, scales = list(arrows = FALSE), zlim = c(0, 1), 
          screen=list(z = -160, x = -70, y = 3),      main = "Carte de probabilité d'occurrence du\n cercopitheque erythrogaster")


#update.packages("gratia")
#install.packages('MASS')
#install.packages("gratia")
#library(gratia)
#library(MASS)



library(dismo)
install.packages('plotmo')
library(plotmo)
# Charger les données d'exemple
df

#_________________-------------------
library(ecodist)
install.packages('randomForest')
library(randomForest)
# Dans ce code, la fonction "randomForest" est utilisée pour créer un modèle de forêt aléatoire pour prédire la variable
#"bio06" en fonction de toutes les autres variables dans le jeu de données "df". La ligne 
#"set.seed(123)" est utilisée pour initialiser le générateur de nombres aléatoires, de sorte que
#les résultats soient reproductibles.

#Le résultat renvoyé par la fonction "randomForest" est un objet de type "randomForest" qui 
#contient des informations sur le modèle créé. La première ligne du résultat indique que le 
#modèle est de type "regression", ce qui signifie qu'il est utilisé pour prédire une variable 
#numérique continue. La deuxième ligne indique que 500 arbres ont été créés pour le modèle. 
#La troisième ligne indique que, à chaque division de l'arbre, six variables ont été sélectionnées
#au hasard pour être testées.

#Ensuite, le résultat affiche la moyenne des résidus au carré, qui est une mesure de la qualité de
#l'ajustement du modèle. Plus cette valeur est faible, meilleure est la qualité de l'ajustement. 
#Dans cet exemple, la moyenne des résidus au carré est de 0,1604982.

#Enfin, le pourcentage de variance expliqué par le modèle est affiché. Ce pourcentage indique à 
#quel point les variables explicatives ont contribué à expliquer la variabilité de la variable de 
#réponse. Dans cet exemple, le modèle explique 98,23% de la variance dans la variable de réponse.

# Créer un data.frame avec la variable "bio08"
pred_bio08<- data.frame(bio08 = xyz[, "bio08"])
pred_bio08<- unique(pred_bio08)
pred_bio08

# réalisation d'un randomForest
names(df)
df
set.seed(123)
my_preds <- c('bio08', 'bio14')
my_preds


# Prédire les valeurs de la variable dépendante pour les données de test
pred <- predict(rf, newdata = df)

# Calculer la RMSE
rmse <- sqrt(mean((df$bio08 - pred)^2))

# Afficher la RMSE
rmse

#La fonction predict() permet de prédire les valeurs de la variable dépendante pour de nouvelles
#observations en utilisant un modèle préalablement entraîné (rf dans ce cas). Les valeurs de la 
#variable dépendante prédites sont stockées dans l'objet pred.

#Ensuite, la racine de l'erreur quadratique moyenne (RMSE) est calculée en comparant les valeurs
#prédites avec les valeurs réelles de la variable dépendante (dans ce cas, la variable bio08 du 
#jeu de données df). La RMSE est une mesure courante de l'erreur de prédiction pour les modèles de
#régression, et elle représente la différence moyenne entre les valeurs prédites et les valeurs 
#réelles, en prenant en compte leur écart quadratique.

#Dans ce cas, la RMSE calculée est de 0.1235749. Cela signifie que l'erreur moyenne de prédiction 
#entre les valeurs prédites et les valeurs réelles de bio08 est de 0.1235749. Plus la RMSE est 
#petite, plus le modèle est précis dans ses prédictions

# We want two panels next to each other:
#par(mfrow=c(1,2))
rf <- randomForest(bio08 ~ ., data = df)
rf
rf1 <- randomForest(bio08 ~ ., data = cercopithecus_gbif_env)
rf1
rf2 <- randomForest(bio08 ~ ., data = cercopitheque_gbif_2.2)
rf2


# Définir la méthode de validation croisée
my_control <- trainControl(method = "repeatedcv", number = 5, repeats = 3)

# Entraîner le modèle avec la méthode de validation croisée
m_full <- glm( presence_c ~ bio08 + I(bio08^06) + bio11 + I(bio11^06) + bio14 + I(bio14^06)+ bio16 + I(bio16^06),
               family='binomial', data=df)
summary(m_full)
df
# pas marcher 
#my_preds1.2 <- names(df)[1:20]
#my_preds1.2
#my_results <- train(x = df[, my_preds], y = df$bio08, trControl = my_control, method = "glm", family = "binomial",metric = "ROC")

# Voir les résultats de la validation croisée
#my_results$results

# Names of our variables:
my_preds <- c('bio01', 'bio08')

install.packages("PresenceAbsence")
library(PresenceAbsence)
library(PresenceAbsence)

#Nous pouvons comparer les présences et les absences observées et prévues sur la base de ces 
#seuils. Pour cela, nous prenons nos prédictions de la validation croisée. La comparaison est 
#illustrée plus facilement dans une matrice de confusion, par exemple en utilisant la fonction
#cmxdans le PresenceAbsencepackage.

#Jetez un œil à Liu et al. (2005) pour voir quels seuils ils recommandent. Ici, nous utiliserons
#le seuil qui maximise la somme de la sensibilité et de la spécificité (la troisième ligne dans la
#trame de données des seuils) :
pred <- predict(m_step, newdata = cercopitheque_coords)
pred

predd <- predict(m_step, newdata = cercopitheque_gbif_2)
predd

preddd <- predict(m_step, newdata = cercopitheque_gbif_2.2)
preddd

thresh_dat <- data.frame(
  ID = seq_len(nrow(cercopitheque_coords)), 
  obs = cercopitheque_coords$presence_cercopitheque, 
  pred =pred)
thresh_dat

#La fonction PresenceAbsence::cmx() permet de calculer la matrice de confusion pour un seuil
#donné. Dans cet exemple, la matrice de confusion est calculée pour le seuil optimal trouvé avec
#la fonction PresenceAbsence::optimal.thresholds(). La variable thresh_cv contient les seuils 
#optimaux pour chaque prédicteur, ainsi que le seuil global. La matrice de confusion pour le seuil
#optimal global est extraite en sélectionnant la troisième ligne de thresh_cv (correspondant au
#seuil global) et la deuxième colonne (correspondant à la valeur du seuil).

(thresh_cv <- PresenceAbsence::optimal.thresholds(DATA= thresh_dat))

(cmx_maxSSS <- PresenceAbsence::cmx(DATA= thresh_dat, threshold=thresh_cv[3,2]))

PresenceAbsence::pcc(cmx_maxSSS, st.dev=F)

PresenceAbsence::sensitivity(cmx_maxSSS, st.dev=F)


PresenceAbsence::specificity(cmx_maxSSS, st.dev=F)

PresenceAbsence::Kappa(cmx_maxSSS, st.dev=F)
install.packages('pROC')
library(TSS)
TSS(cmx_maxSSS)
library(pROC)
unique(cercopitheque_coords$presence_cercopitheque)
cercopitheque_coords
install.packages('geodata')
library(geodata)
#____________ 2eme fois