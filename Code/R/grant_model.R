load(".//Data//RData//cleaned_all.RData")




























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
