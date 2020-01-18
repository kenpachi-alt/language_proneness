#Acknowledgement: For implementation we used Berger et al. Source code 

#importing packages
library(MASS)

#print results in decimals 
options(scipen = 999)

#reading data source file
training_df <- read.csv("PATH to the data source", header=TRUE)

#addding 1 to avoid log(0)
training_df$tins<-1+training_df$tins

#casting dataframe columns to integer
training_df$commits<-as.numeric(training_df$commits)
training_df$bcommits<-as.numeric(training_df$bcommits)
training_df$tins<-as.numeric(training_df$tins)
training_df$devs<-as.numeric(training_df$devs)
training_df$max_commit_age<-as.numeric(training_df$max_commit_age)



#This function applies log transformation to control variables
log_transform = function(df, log1 = log) {
  data.frame(
    class = df$class,
    ldevs = log1(df$devs),
    lcommits=log1(df$commits),
    ltins=log1(df$tins),
    lmax_commit_age=log1(df$max_commit_age),
    lbcommits=log1(df$bcommits + 0.5*(df$bcommits==0)),
    bcommits=df$bcommits,
    
    #replace "Sec" with the desired bug category
    Sec=df$Sec,
    class_r = relevel(df$class, rev(levels(df$class))[1]),
    commits = df$commits
    
  )
}

# Takes the glm model and the relevant second model for the last observation and combines them together returning a single data frame
combine_models = function(model, model_r, var, p_val_adjust = "none") {
  control_variables = 4
  summary_model = summary(model)$coefficients
  summary_r_model = summary(model_r)$coefficients
  row_names = model_row_names(model, var)
  coef = round(c(summary_model[,1], summary_r_model[control_variables + 2, 1]), 2)
  se = round(c(summary_model[,2], summary_r_model[control_variables + 2, 2]), 2)
  pVal = c(summary_model[,4], summary_r_model[control_variables + 2, 4])
  if (p_val_adjust == "bonferroni" || p_val_adjust == "fdr")
    pVal[(control_variables + 2):length(pVal)] = p.adjust(pVal[(control_variables + 2):length(pVal)], p_val_adjust)
  names(coef) = row_names
  data.frame(
    coef, 
    se,
    pVal
  )
} 


#weighted contrast encoding of the categorical variable
Weighted_contrast_encoding <- function(catergorical_var)
{
  f_dist=summary(catergorical_var)
  f_Sum=contr.sum(levels(catergorical_var))		
  f_Sum[nrow(f_Sum),] = -f_dist[1:ncol(f_Sum)]/f_dist[length(f_dist)]
  f_Sum
}


model_row_names = function(model, temp_var) {
  control_variables = 4
  row_names = c(dimnames(summary(model)$coefficients)[[1]][1:(1 + control_variables)], names(summary(temp_var)))
  names(row_names) = row_names
  row_names[["(Intercept)"]] = "Intercept"
  row_names[["lmax_commit_age"]] = "log age"
  row_names[["ltins"]] = "log size"
  row_names[["ldevs"]] = "log devs"
  row_names[["lcommits"]] = "log commits"
  row_names
}
#applying log transformation on control variables
log_transform_df=log_transform(training_df, log)

#fitting first NBR model 
#replace "Sec" with the desired bug category
nbr_fit = glm.nb(Sec~lmax_commit_age+ltins+ldevs+lcommits+class, contrasts = list(class = Weighted_contrast_encoding(log_transform_df$class)), data=log_transform_df)

#fitting second NBR model 
#replace "Sec" with the desired bug category
nbr_fit_r = glm.nb(Sec~lmax_commit_age+ltins+ldevs+lcommits+class_r, contrasts = list(class_r = Weighted_contrast_encoding(log_transform_df$class_r)), data=log_transform_df)

# combine them into single result table
result = combine_models(nbr_fit, nbr_fit_r, log_transform_df$class)
result

#anova analysis
anova(nbr_fit)
