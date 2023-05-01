library(randomForest)


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

