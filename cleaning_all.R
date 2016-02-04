library(dplyr)
library(functional)
library(randomForest)


setwd(".//Minicompetition")
data <- read.csv("unimelb_training.txt")

# RFCD = Department
# SEO = Socioeconomic Objective


### ----------- Cleaning Data -----------------###

data <- data %>% mutate_each(funs(factor), starts_with("RFCD.Code"), starts_with("SEO.Code"), starts_with("Person.ID"),
                             starts_with("Dept.No"), starts_with("Faculty.NO"), Grant.Status)


# Replace zeros by NA in certain columns
colnames.zero <- colnames(data %>% select(-matches("percentage"), -starts_with("A."), -starts_with("B."), -starts_with("C."), -Grant.Status))
data2 <- data
data2[colnames.zero][data2[colnames.zero] == 0] <- NA


# Get the Main Departments and socio-economic Objectives
colnames.dep <- colnames(data2 %>% select(starts_with("RFCD.Code")))
data2 <- mutate(data2, RFCD.Code.1.Main = substr(RFCD.Code.1,1,2))
data2 <- mutate(data2, RFCD.Code.2.Main = substr(RFCD.Code.2,1,2))
data2 <- mutate(data2, RFCD.Code.3.Main = substr(RFCD.Code.3,1,2))
data2 <- mutate(data2, RFCD.Code.4.Main = substr(RFCD.Code.4,1,2))
data2 <- mutate(data2, RFCD.Code.5.Main = substr(RFCD.Code.5,1,2))

data2 <- mutate(data2, SEO.Code.1.Main = substr(SEO.Code.1,1,2))
data2 <- mutate(data2, SEO.Code.2.Main = substr(SEO.Code.2,1,2))
data2 <- mutate(data2, SEO.Code.3.Main = substr(SEO.Code.3,1,2))
data2 <- mutate(data2, SEO.Code.4.Main = substr(SEO.Code.4,1,2))
data2 <- mutate(data2, SEO.Code.5.Main = substr(SEO.Code.5,1,2))


# Getting Percentages for each Department and each socio-economic Objective
department.names <- factor(paste("Dep." ,(levels(factor(data$RFCD.Code.1 %>% substring(1,2)))), sep=""))
for (name in department.names){
  dep.num <- substring(name,5,6)
  data2[name] <- rowSums(cbind((data2["RFCD.Code.1.Main"] == dep.num) * data2["RFCD.Percentage.1"],
  (data2["RFCD.Code.2.Main"] == dep.num) * data2["RFCD.Percentage.2"],
  (data2["RFCD.Code.3.Main"] == dep.num) * data2["RFCD.Percentage.3"],
  (data2["RFCD.Code.4.Main"] == dep.num) * data2["RFCD.Percentage.4"],
  (data2["RFCD.Code.5.Main"] == dep.num) * data2["RFCD.Percentage.5"]), na.rm=TRUE)
}

seo.names <- factor(paste("Seob." ,(levels(factor(data$SEO.Code.1 %>% substring(1,2)))), sep=""))
for (name in seo.names){
  seo.num <- substring(name,6,7)
  data2[name] <- rowSums(cbind((data2["SEO.Code.1.Main"] == seo.num) * data2["SEO.Percentage.1"],
                               (data2["SEO.Code.2.Main"] == seo.num) * data2["SEO.Percentage.2"],
                               (data2["SEO.Code.3.Main"] == seo.num) * data2["SEO.Percentage.3"],
                               (data2["SEO.Code.4.Main"] == seo.num) * data2["SEO.Percentage.4"],
                               (data2["SEO.Code.5.Main"] == seo.num) * data2["SEO.Percentage.5"]), na.rm=TRUE)
}
head(data2 %>% select(starts_with("SEO"), starts_with("Seob.")))


# The cleaned data ist named data2



# First shitty logistic Regression Models
data_logit <- data2 %>% select(Grant.Status, starts_with("Dep."))
logit <- glm(Grant.Status ~ ., data = data_logit, family = "binomial")

data_logit2 <- data2 %>% select(Grant.Status, starts_with("Seob."))
logit2 <- glm(Grant.Status ~., data = data_logit2, family="binomial")


# Random Forest
set.seed(99998)
variables.rf <- colnames(select(data2, starts_with("Dep."), starts_with("Seob.")))

data_rf <- data2[c("Grant.Status", variables.rf)]
rf <- randomForest(Grant.Status ~., data=data_rf)
pred_rf <- predict(rf, data_rf)
t_rf <- table(data_rf$Grant.Status, pred_rf)
print(t_rf)
acc <- (t_rf[1,1] + t_rf[2,2])/sum(t_rf)
print(acc)
