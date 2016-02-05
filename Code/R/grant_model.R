library(randomForest)
library(dplyr)
library(ROCR)
library(e1071)
library(reshape2)

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
               People.score,  Avg.People.score, A..papers, A.papers, B.papers, C.papers, Dif.countries, Number.people, PHD, Max.years.univ, Grants.succ,
               Grants.unsucc, Departments, Perc_non_australian, Season, SC.Group, Weekday, Month, Day.of.Month))

# Use all the variables
train.rf_all <- select_(train, .dots = variables_all)
rf_all <- randomForest(Grant.Status~., data=train.rf_all, ntree=1500)
pred_rf_all <- predict(rf_all, test)
conf_rf_all <- table(test$Grant.Status, pred_rf_all)
acc_all <- (conf_rf_all[1,1] + conf_rf_all[2,2])/sum(conf_rf_all)
acc_all
importance <- rf_all$importance

# Find boptimal numbers of Split-Variables at each node
bestmtry <- tuneRF(train.rf[-1],train$Grant.Status, mtryStart = 7, ntreeTry=800, stepFactor=1.1, improve=0.001, trace=TRUE, plot=TRUE, doBest=FALSE)


### Feature Selection
# filter variables by feature Importance
# for (threshold in seq(0,10,2)){
#   variables_filtered <- c(variables_all[importance > threshold])
#   train.rf <- select_(train, .dots = variables_filtered)
#   
#   #Create tree
#   rf <- randomForest(Grant.Status~., data=train.rf, ntree=1000, mtry = 7)
#   
#   # Accuracy
#   rf.pred.class <- predict(rf, test)
#   t_rf <- table(test$Grant.Status, rf.pred.class)
#   rf.acc <- (t_rf[1,1] + t_rf[2,2])/sum(t_rf)
#   cat("Threshold: ", threshold, "\n")
#   cat("Accuracy over test set: ", rf.acc, "\n")
#   
#   # AUC
#   rf.pred.prob = predict(rf, type="prob", newdata=test)[,2]
#   rf.pred = prediction(rf.pred.prob, test$Grant.Status)
#   rf.perf = performance(rf.pred, "tpr", "fpr")
#   rf.auc <- as.numeric(performance(rf.pred, "auc")@y.values)
#   cat("AUC: ", rf.auc, "\n")
# }
### => Include all features!
  
  
  




#### Final Tree trained on more Data
train.tree <- select_(rbind(train, test), .dots = variables_all)
tree <- randomForest(Grant.Status~., data=train.tree, ntree=3000, mtry = 7)

# Accuracy
tree.pred.class <- predict(tree, validation)
t_tree <- table(validation$Grant.Status, tree.pred.class)
tree.acc <- (t_tree[1,1] + t_tree[2,2])/sum(t_tree)
cat("Accuracy over Validation set: ", tree.acc, "\n")

#AUC
tree.pr = predict(tree, type="prob", newdata=validation)[,2]
tree.pred = prediction(tree.pr, validation$Grant.Status)
tree.perf = performance(tree.pred, "tpr", "fpr")
auc <- as.numeric(performance(tree.pred, "auc")@y.values)

plot(tree.perf,main=paste("ROC Curve for Random Forest\n", "AUC = ", round(auc,3)), col=2, lwd=2)
abline(a=0,b=1,lwd=2,lty=2,col="gray") 

# Best Model so far
save(tree, file=".//..//..//Data//RData//tree91.RData")



#------------------------------------------------------------------------------------------------------------------------------




#### SVM
# Select variables
#variables <- colnames(select(train, Grant.Status, Contract.Value.Band, C.papers))
variables <- colnames(select(train, Grant.Status, Grant.Category.Code, Contract.Value.Band, starts_with("Dep."), starts_with("Seob."),
                                 People.score, Avg.People.score, A..papers, A.papers, B.papers, C.papers, Dif.countries, Number.people, PHD, Max.years.univ, Grants.succ,
                                 Grants.unsucc, Departments, Perc_non_australian, Season, SC.Group, Weekday, Month, Day.of.Month))
train.svm.var <- select_(train, .dots = variables)
test.svm.var <- select_(test, .dots = variables)

# Scale Parameters
num.names <- colnames(train.svm.var %>% select(which(sapply(.,is.numeric))))
range01 <- function(x){(x-min(x))/(max(x)-min(x))}
train.svm <- mutate_each_(train.svm.var, funs(range01),vars=num.names)
test.svm <- mutate_each_(test.svm.var, funs(range01),vars=num.names)


svm.model <- svm(Grant.Status~., data=train.svm, cross=3, probability=TRUE)


svm.pr.class <- predict(svm, newdata=test.svm)
t.svm <- table(test.svm$Grant.Status, svm.pr.class)
svm.acc <- (t.svm[1,1] + t.svm[2,2])/sum(t.svm)
cat("SVM Accuracy over test set: ", svm.acc, "\n")

svm.pr.tr <- predict(svm, newdata=train.svm)
t.svm.tr <- table(train.svm$Grant.Status, svm.pr.tr)
svm.acc.tr <- (t.svm.tr[1,1] + t.svm.tr[2,2])/sum(t.svm.tr)
cat("SVM Accuracy over training set: ", svm.acc.tr, "\n")

#AUC
svm.pr = predict(svm, type="prob", test.svm)[,2]
svm.pred = prediction(svm.pr, test$Grant.Status)
svm.perf = performance(svm.pred, "tpr", "fpr")
svm.auc <- as.numeric(performance(svm.pred, "auc")@y.values)
