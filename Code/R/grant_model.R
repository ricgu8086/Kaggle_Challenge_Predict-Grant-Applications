library(randomForest)
library(dplyr)

load(".//Data//RData//cleaned_all.RData")

# Splitting the data
train <- filter(data_cleaned, Set_ID == "Training")
test <- filter(data_cleaned, Set_ID == "Testing")
validation <- filter(data_cleaned, Set_ID == "Validation")


# Dividing Sponsor.Code into Groups
SC.Status <- with(train, table(Sponsor.Code, Grant.Status))
SC.Status <- cbind(SC.Status, SC.Status[,2]/rowSums(SC.Status))
SC.Status[,3][is.na(SC.Status[,3])] <- 0
SC.Status <- cbind(SC.Status, cut(SC.Status[,3], 10))

# Map Trained Sponsor Groups to whole dataset
train[Sponsor.Group] <- 




## Simple Random Forest Model
# Sponsor.Code has too many fators
train.rf <- select(train, Grant.Status, Grant.Category.Code, Contract.Value.Band, starts_with("Dep."), starts_with("Seob."))
rf <- randomForest(Grant.Status~., data=train.rf)
pred_rf <- predict(rf, test)
t_rf <- table(test$Grant.Status, pred_rf)
acc <- (t_rf[1,1] + t_rf[2,2])/sum(t_rf)











# 
# # First shitty logistic Regression Models
# data_logit <- data2 %>% select(Grant.Status, starts_with("Dep."))
# logit <- glm(Grant.Status ~ ., data = data_logit, family = "binomial")
# 
# data_logit2 <- data2 %>% select(Grant.Status, starts_with("Seob."))
# logit2 <- glm(Grant.Status ~., data = data_logit2, family="binomial")
# 
# 
# # Random Forest
# set.seed(99998)
# variables.rf <- colnames(select(data2, starts_with("Dep."), starts_with("Seob.")))
# 
# data_rf <- data2[c("Grant.Status", variables.rf)]
# rf <- randomForest(Grant.Status ~., data=data_rf)
# pred_rf <- predict(rf, data_rf)
# t_rf <- table(data_rf$Grant.Status, pred_rf)
# print(t_rf)
# acc <- (t_rf[1,1] + t_rf[2,2])/sum(t_rf)
# print(acc)
