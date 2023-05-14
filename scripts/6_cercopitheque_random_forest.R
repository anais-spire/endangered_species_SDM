library(randomForest)
library(dismo)
library(plotmo)
library(gratia)
library(MASS)
library(ecodist)
library(PresenceAbsence)
library(TSS)
library(pROC)

load(file='data/cercopitheque_joined_data.RData')
load(file='results/GLM.Rdata')

# Dans ce code, la fonction "randomForest" est utilisée pour créer un modèle de forêt aléatoire pour prédire la variable
#"bio08" en fonction de toutes les autres variables dans le jeu de données "df".

#Le résultat renvoyé par la fonction "randomForest" est un objet de type "randomForest" qui 
#contient des informations sur le modèle créé. La première ligne du résultat indique que le 
#modèle est de type "regression", ce qui signifie qu'il est utilisé pour prédire une variable 
#numérique continue. La deuxième ligne indique que 500 arbres ont été créés pour le modèle. 
#La troisième ligne indique que, à chaque division de l'arbre, six variables ont été sélectionnées
#au hasard pour être testées.

#Enfin, le pourcentage de variance expliqué par le modèle est affiché. Ce pourcentage indique à 
#quel point les variables explicatives ont contribué à expliquer la variabilité de la variable de 
#réponse. Dans cet exemple, le modèle explique 98,23% de la variance dans la variable de réponse.

# Créer un data.frame avec la variable "bio08"
pred_bio08<- data.frame(bio08 = xyz[, "bio08"])
pred_bio08<- unique(pred_bio08)
pred_bio08

# predictor variables
my_preds <- c('bio08', 'bio11')
my_preds

# Prédire les valeurs de la variable dépendante pour les données de test pour de nouvelles
#observations en utilisant un modèle préalablement entraîné (rf dans ce cas).
pred <- predict(rf, newdata = df)

# Calculer la RMSE (moyenne des résidus au carré)
rmse <- sqrt(mean((df$bio08 - pred)^2))
rmse
# mesure de la qualité de l'ajustement du modèle (diff moyenne entre prédit et réel). 
# Plus cette valeur est faible, meilleure est la qualité de l'ajustement. 

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


# ne marche pas 
#my_preds1.2 <- names(df)[1:20]
#my_preds1.2
#my_results <- train(x = df[, my_preds], y = df$bio08, trControl = my_control, method = "glm", family = "binomial",metric = "ROC")

# Voir les résultats de la validation croisée
#my_results$results

# Names of our variables:
my_preds <- c('bio08', 'bio11')


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
  obs = cercopitheque_coords$presence_cercoercopitheque, 
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
TSS(cmx_maxSSS)

unique(cercopitheque_coords$presence_cercoercopitheque)
cercopitheque_coords





# DRAFT

load(file='data/cercopitheque_data.RData')

# Easting = lon, Northing = lat in another coordinate system
sp_dat <- cercopitheque_gbif_env

# Let's only use the two most important predictors for now
my_preds <- c('bio12','bio09')

# First, we randomly select 70% of the rows that will be used as training data
train_i <- sample(seq_len(nrow(sp_dat)), size=round(0.7*nrow(sp_dat)))

# Then, we can subset the training and testing data
sp_train <- sp_dat[train_i,]
sp_test <- sp_dat[-train_i,]
sp_train
sp_train[,my_preds]
# We store the split information for later:
write(train_i, file='data/indices_traindata.txt')

# Fit RF
m_rf <- randomForest( x=sp_train[,my_preds], y=sp_train$presence_absence, 
                      ntree=1000, importance =T)

# Variable importance:
importance(m_rf,type=1)

varImpPlot(m_rf)

