

files <- list.files(folder_path, pattern='grd$', full.names=TRUE)
predictors <- stack(files)
predictors
names(predictors)
plot(predictors)