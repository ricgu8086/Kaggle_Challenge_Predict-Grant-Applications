library(randomForest)
library(dplyr)
library(ROCR)
library(e1071)

path_data = "..//..//Data//RData//"
path_original = paste(path_data, "cleaned_all.RData", sep="")
path_team = paste("..//..//Data//text//", "teamTable.csv", sep="")




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
variables_all <- colnames(select(train, Grant.Status, Grant.Category.Code, Contract.Value.Band, starts_with("Dep."), starts_with("Seob."),
               A..papers, A.papers, B.papers, C.papers, Dif.countries, Number.people, PHD, Max.years.univ, Grants.succ,
               Grants.unsucc, Departments, Perc_non_australian, Season, SC.Group, Weekday, Month, Day.of.Month))

# Use all the variables
train.rf_all <- select_(train, .dots = variables_all)
rf_all <- randomForest(Grant.Status~., data=train.rf_all, ntree=1500)
pred_rf_all <- predict(rf_all, test)
conf_rf_all <- table(test$Grant.Status, pred_rf_all)
acc_all <- (conf_rf_all[1,1] + conf_rf_all[2,2])/sum(conf_rf_all)
acc_all
importance <- rf_all$importance


# filter variables by feature Importance
variables_filtered <- c(variables_all[importance > 5])
train.rf <- select_(train, .dots = variables_filtered)

# Find boptimal numbers of Split-Variables at each node
bestmtry <- tuneRF(train.rf[-1],train$Grant.Status, mtryStart = 7, ntreeTry=800, stepFactor=1.1, improve=0.001, trace=TRUE, plot=TRUE, doBest=FALSE)

#Create tree
rf <- randomForest(Grant.Status~., data=train.rf, ntree=3000, mtry = 7)
pred_rf <- predict(rf, test)
t_rf <- table(test$Grant.Status, pred_rf)
acc <- (t_rf[1,1] + t_rf[2,2])/sum(t_rf)
acc

# Check for Overfitting
pred_rf_train <- predict(rf, train.rf)
t_rf <- table(train.rf$Grant.Status, pred_rf_train)
acc_train <- (t_rf[1,1] + t_rf[2,2])/sum(t_rf)
acc_train
rf.pr = predict(rf, type="prob", newdata=train.rf)[,2]
rf.pred = prediction(rf.pr, train.rf$Grant.Status)
rf.perf = performance(rf.pred, "tpr", "fpr")
auc <- as.numeric(performance(rf.pred, "auc")@y.values)

plot(rf.perf,main=paste("ROC Curve for Random Forest\n", "AUC = ", round(auc,3)), col=2, lwd=2)
abline(a=0,b=1,lwd=2,lty=2,col="gray")


# Best Model so far
save(rf.77, file=".//..//..//Data//RData//rf.77.RData")



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

