library(randomForest)
library(dplyr)
library(ROCR)
library(e1071)
library(xgboost)

path_data = "./Data/RData/"
path_original = paste(path_data, "cleaned_all.RData", sep="")
path_team = paste("./Data/text/", "teamTable.csv", sep="")




load(path_original)
team_data <- read.csv(path_team, na.strings=c("NA", ""), as.is=TRUE, strip.white = TRUE)

data_all <- cbind(data_cleaned, team_data)

# Splitting the data
train <- filter(data_all, Set_ID == "Training")
test <- filter(data_all, Set_ID == "Testing")
validation <- filter(data_all, Set_ID == "Validation")


### Dividing Sponsor.Code into Groups, trainined by Traning Data, but applied to all data
SC.Status <- with(train, table(Sponsor.Code, Grant.Status))
SC.Status <- cbind(SC.Status, SC.Status[,2]/rowSums(SC.Status))
SC.Status[,3][is.na(SC.Status[,3])] <- 0
tmp <- cbind(row.names(SC.Status), cut(SC.Status[,3], 10))
# Add new Column to all datasets
train$SC.Group <- as.numeric(tmp[,2][match(as.character(train$Sponsor.Code), tmp)])
test$SC.Group <- as.numeric(tmp[,2][match(as.character(test$Sponsor.Code), tmp)])
validation$SC.Group <- as.numeric(tmp[,2][match(as.character(validation$Sponsor.Code), tmp)])




## Random Forest Model
#list of all potential variables
variables_all <- colnames(dplyr::select(train, Grant.Status, Grant.Category.Code, Contract.Value.Band, starts_with("Dep."), starts_with("Seob."),
                                 A..papers, A.papers, B.papers, C.papers, Dif.countries, Number.people, PHD, Max.years.univ, Grants.succ,
                                 Grants.unsucc, Departments, Perc_non_australian, Season, SC.Group, Weekday, Month, Day.of.Month))

xgboost()


#### Tree ROC Curve
tree <- rf

tree.pr = predict(tree, type="prob", newdata=test)[,2]
tree.pred = prediction(tree.pr, test$Grant.Status)
tree.perf = performance(tree.pred, "tpr", "fpr")
auc <- as.numeric(performance(tree.pred, "auc")@y.values)

plot(tree.perf,main=paste("ROC Curve for Random Forest\n", "AUC = ", round(auc,3)), col=2, lwd=2)
abline(a=0,b=1,lwd=2,lty=2,col="gray")




#### SVM

#train.svm <- mutate_each_(train, c())

