library(dplyr)
library(functional)
library(randomForest)


data <- read.csv("unimelb_training.txt", na.strings=c("NA", ""), as.is=TRUE, strip.white = TRUE)

# RFCD = Department
# SEO = Socioeconomic Objective

### ----------- Cleaning Data -----------------###

data <- data %>% mutate_each(funs(factor), starts_with("RFCD.Code"), starts_with("SEO.Code"), starts_with("Person.ID"),
                             starts_with("Dept.No"), starts_with("Faculty.NO"), Grant.Status)


# Replace zeros by NA in certain columns
colnames.zero <- colnames(data %>% select(-matches("percentage"), -starts_with("A."), -starts_with("B."), -starts_with("C."), -Grant.Status))
data2 <- data
data2[colnames.zero][data2[colnames.zero] == 0] <- NA


#Rename Contract.Value.Band
data2 <- rename(data2, Contract.Value.Band = Contract.Value.Band...see.note.A)

# Check for NAs per column
head(colSums(is.na(data2)))


### Replace Contract Value by random values distributed similar as the rest
set.seed(23483846)
CV.table <- table(data2$Contract.Value.Band)[1:8] / sum(table(data2$Contract.Value.Band)[1:8])
data2$Contract.Value.Band[is.na(data2$Contract.Value.Band)] <- base::sample(x=unlist(dimnames(CV.table)), size=sum(is.na(data2$Contract.Value.Band)), replace=TRUE, prob=as.vector(CV.table))


### Replace Grant.Category.Code by random values distributed conditionally over the Contract.Value.Band
GCC.table <- table(data2$Grant.Category.Code, data2$Contract.Value.Band)

# Select Columns with more then 5% of overall 
GCC.filter <- rowSums(GCC.table)/sum(GCC.table) > 0.05
GCC.table <- GCC.table[GCC.filter,]
GCC.prop <- prop.table(GCC.table, margin = 2)
GCC.prop[, 14] <- rowSums(GCC.prop[,10:13])/4

# Replace NA Values with condiational random sample
Contract.Bands <- unlist(dimnames(GCC.prop)[2])
for (cat in Contract.Bands){
  if (sum(is.na(data2$Grant.Category.Code[data2$Contract.Value.Band == cat])) > 0) {
    data2$Grant.Category.Code[(data2$Contract.Value.Band == cat) & is.na(data2$Grant.Category.Code)] <- sample(unlist(dimnames(GCC.prop)[1]), size=sum(is.na(data2$Grant.Category.Code[data2$Contract.Value.Band == cat])), replace = TRUE, prob=as.vector(GCC.prop[,cat]))
  }
}


### Replace Sponsor Code by artificial Sample Distribution of the Top-3 Sponsors
# Code of Top 3 Sponsors
top3 <- unlist(dimnames(table(data2$Sponsor.Code)[table(data2$Sponsor.Code) > 250])) 
# Conditional distribution of Sponsor.Code over Contract.Value.Band
SC.table <- table(data2$Sponsor.Code[data2$Sponsor.Code %in% top3], data2$Contract.Value.Band[data2$Sponsor.Code %in% top3])
SC.prop <- prop.table(SC.table, margin=2)

# fill J and K
tmp <- prop.table(table(data2$Sponsor.Code[data2$Sponsor.Code %in% top3]))
O <- as.vector(tmp)
K <- as.vector(tmp)

SC.prop <- cbind(SC.prop, O, K)

# Replace NA Values with conditional random sample
for (cat in Contract.Bands){
  if (sum(is.na(data2$Sponsor.Code[data2$Contract.Value.Band == cat])) > 0) {
    data2$Sponsor.Code[(data2$Contract.Value.Band == cat) & is.na(data2$Sponsor.Code)] <- sample(x=top3, size=sum(is.na(data2$Sponsor.Code[data2$Contract.Value.Band == cat])), replace = TRUE, prob=as.vector(SC.prop[,cat]))
  }
}


#### DON'T forget to turn Strings into FACTORS!!!



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
#head(data2 %>% select(starts_with("SEO"), starts_with("Seob.")))












data_cleaned <- data2
# The cleaned data ist named data2
save(data_cleaned, file="cleaned_all.RData")

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
