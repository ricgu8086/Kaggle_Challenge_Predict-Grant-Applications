library(randomForest)
library(dplyr)

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




## Simple Random Forest Model
# Sponsor.Code has too many fators
variables <- colnames(select(train, Grant.Status, Grant.Category.Code, Contract.Value.Band, starts_with("Dep."), starts_with("Seob."),
               A..papers, A.papers, B.papers, C.papers, Dif.countries, Number.people, PHD, Max.years.univ, Grants.succ,
               Grants.unsucc, Departments, Perc_non_australian, Season, SC.Group, Weekday, Month, Day.of.Month))


train.rf <- select(train, .dots = variables)
rf <- randomForest(Grant.Status~., data=train.rf, ntree=1500)
pred_rf <- predict(rf, test)
t_rf <- table(test$Grant.Status, pred_rf)
acc <- (t_rf[1,1] + t_rf[2,2])/sum(t_rf)
acc



save(rf.77, file=".//..//..//Data//RData//rf.77.RData")
