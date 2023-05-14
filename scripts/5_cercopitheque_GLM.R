# GLM

library(glm)
library(corrplot) # for correlation matrix
library(mecofun) # for selection of variables
library(caret) # for selection of variables (alternative to mecofun)
library(RColorBrewer) # for response curves colors
library(lattice) # for response curves surfaces

# load files
load(file='data/cercopitheque_joined_data.RData')
head(cercopitheque_joined_current_data)
head(cercopitheque_joined_future_data)



# CURRENT DATA
df <- cercopitheque_joined_current_data
df_env <- df[,-c(1:3)]


# get presence/absence vector
presence_cerco <- df[, 3]
presence_cerco


# 1] GLM: first dumb trials
m1 <- glm(presence_cerco ~ bio01, family = "binomial", data = df)
summary(m1)

m2 <- glm(presence_cerco ~ bio01 + I(bio01^2), family="binomial", data= df)
summary(m2)

# Or use the poly() function:
summary( glm(presence_cerco ~ poly(bio01, 2) , family="binomial", data= df) )
summary( glm(presence_cerco ~ poly(bio01, 3) , family="binomial", data= df) )

# Fit two linear variables:
summary( glm(cercopitheque_gbif_2.2 ~ bio01:bio19, family="binomial", data= df))

# Fit three linear variables:
summary( glm(presence_cerco~ bio01 + bio02+ bio03+ bio04+ bio05+ bio06+ bio07+ bio08+ bio09 + bio10 + bio11+ bio12+ bio13+ bio14+ bio15+ bio16+ bio17+ bio18+ bio19 ,
             family="binomial", data= df) )

# Fit three linear variables with up to three-way interactions
summary( glm(presence_cerco ~ bio01 * bio02 * bio03, family="binomial", data= df) )


summary( glm(presence_cerco ~ bio04 * bio05 * bio06, family="binomial", data= df) )

summary( glm(presence_cerco ~ bio07 * bio08 * bio09, family="binomial", data= df) )

# Fit three linear variables with up to two-way interactions
summary( glm(presence_cerco ~ bio01 + bio04 + bio07 + 
               bio01:bio04 + bio01:bio07 + bio04:bio07, 
             family="binomial", data= df) )


# 2] SELECT BEST ENV VARIABLES
# 2] A] CORRELATION MATRIX

# We use Spearman rank correlation coefficient, as we do not know whether all variables are normally distributed.
corr_matrix <- cor(df_env, method='spearman')
corr_matrix

# Visualization of the correlation matrix. 
# For better visibility, we plot the correlation coefficients as percentages.
corrplot.mixed(corr_matrix, tl.pos='lt', tl.cex=0.6, number.cex=0.5, addCoefasPercent=T)

# 2] B] SELECT VARIABLES

# mecofun library doesn't work
# var_sel <- select07(X=df_env, 
#                    y=presence_cerco, 
#                    threshold=0.7)


# let's try with caret library

highly_correlated_vars <- findCorrelation(corr_matrix, cutoff = 0.7)
str(highly_correlated_vars)
print(highly_correlated_vars)

# removal of highly correlated variables
selected_vars <- df_env[, -highly_correlated_vars]
selected_vars # less correlated variables: bio 8, 11, 15, 19
head(selected_vars)
select<-str(selected_vars)

# Because we have 65 points, we need no more than 6 parameters.
# Because we want to include quadratic terms, we can only include 3 parameters in the model
# We need to find the 3 most important variables in terms of univariate AIC

# ... to do


# 3] BETTER GLM - MODEL FITTING

# Adjust model to simplify it.

m_full <- glm( presence_cerco ~ bio08 + I(bio08^2) + 
                                bio11 + I(bio11^2) + 
                                bio15 + I(bio15^2) + 
                                bio19 + I(bio19^2),
               family='binomial', data=df)
summary(m_full)

extractAIC(m_full, scale = 0, k = 2) # mpdem measurement

# simplification of the model: stepwise variable selection
m_step <- step(m_full)
summary(m_step)
# variable bio19 semble être moins importante

m_full_2 <- glm( presence_cerco ~ 
                 bio08 + I(bio08^2) + 
                 bio11 + I(bio11^2) + 
                 bio15 + I(bio15^2),
               family='binomial', data=df)
summary(m_full_2)



# MODEL ASSESSMENT

# prediction of response curves

# m_full
head(predict(m_full, type='response'))
names(m_full)
head(m_full$fitted)

# m_step
head(predict(m_step, type='response'))
names(m_step)
head(m_step$fitted)

# m_full_2
head(predict(m_full_2, type='response'))
names(m_full_2)
head(m_full_2$fitted)

# Visualization of response curves



# We want to make predictions for all combinations of the two predictor variables
# and along their entire environmental gradients:
xyz <- expand.grid(
  # We produce a sequence of environmental values within the predictor ranges:
  bio08 = seq(min(df$bio08),max(df$bio08),length=30),
  bio11 = seq(min(df$bio11),max(df$bio11),length=30),
  bio15 = seq(min(df$bio15),max(df$bio15),length=30),
  bio19 = seq(min(df$bio19),max(df$bio19),length=30))

# Now we can make predictions to this new data frame
xyz$z <- predict(m_step, newdata=xyz, type='response')
xyz$z
class(xyz$z)
summary(xyz)

# As result, we have a 3D data structure and want to visualise this.
# Here, I first set a color palette
cls <- colorRampPalette(rev(brewer.pal(11, 'RdYlBu')))(30)

# Finally, we plot the response surface using the wireframe function from the lattice package
wireframe( z ~ bio08 + bio11 + bio15 + bio19, 
           data = xyz, 
           zlab = list("Occurrence prob.", rot=90), 
           drape = TRUE, col.regions = cls,
           scales = list(arrows = F),
           zlim = c(0, 1),
           main = "Carte de probabilité d'occurrence du\n cercopitheque erythrogaster")


# We can also rotate the axes to better see the surface
wireframe(z ~ bio08 + bio14, data = xyz, zlab = list("Occurrence prob.", rot=90), 
          drape = TRUE, col.regions = cls, scales = list(arrows = FALSE), zlim = c(0, 1), 
          screen=list(z = -160, x = -70, y = 3),      main = "Carte de probabilité d'occurrence du\n cercopitheque erythrogaster")

# save data
save(xyz, file='results/GLM.Rdata')

