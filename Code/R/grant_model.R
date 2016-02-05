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


# Dividing Sponsor.Code into Groups
SC.Status <- with(train, table(Sponsor.Code, Grant.Status))
SC.Status <- cbind(SC.Status, SC.Status[,2]/rowSums(SC.Status))
SC.Status[,3][is.na(SC.Status[,3])] <- 0
SC.Status <- cbind(SC.Status, cut(SC.Status[,3], 10))

# TODO: Map Trained Sponsor Groups to whole dataset
#train[Sponsor.Group] <- 




## Simple Random Forest Model
# Sponsor.Code has too many fators
train.rf <- select(train, Grant.Status, Grant.Category.Code, Contract.Value.Band, starts_with("Dep."), starts_with("Seob."),
                   A..papers, A.papers, B.papers, C.papers, Dif.countries, Number.people, PHD, Max.years.univ, Grants.succ,
                   Grants.unsucc, Departments, Perc_non_australian)
rf <- randomForest(Grant.Status~., data=train.rf, ntree=1000)
pred_rf <- predict(rf, test)
t_rf <- table(test$Grant.Status, pred_rf)
acc <- (t_rf[1,1] + t_rf[2,2])/sum(t_rf)
acc





