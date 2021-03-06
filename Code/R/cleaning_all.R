library(dplyr)
library(functional)
library(randomForest)


data <- read.csv(".//..//..//Data//text//unimelb_training.txt", na.strings=c("NA", ""), as.is=TRUE, strip.white = TRUE)


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
head(colSums(is.na(data2)), 10)

# Format the dates
data2$Start.date <- as.Date(data2$Start.date, "%d/%m/%y")
data2$Weekday <- weekdays(data2$Start.date)
data2$Month <- months(data2$Start.date)
data2$Day.and.Month <- format(data2$Start.date, "%d %b")
data2$Day.of.Month <- format(data2$Start.date, "%d")
data2$Season <- quarters(data2$Start.date)

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


## Turn Charaters into factors
for (column in names(data2)){
  if (is.character(unlist(data2[column])) == TRUE) {
    data2[column] <- as.factor(unlist(data2[column]))
  }
}



###### IMPORTANT: SEO Codes had a regime shift
##### MUSS NOCH ANGEPASST WERDEN


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

# The following is not neccesary
# ### Replace NAs of RFCD.Code.1.Main similar distributed as the rest
# RF.prop <- prop.table(table(data2$RFCD.Code.1.Main))
# data2$RFCD.Code.1.Main[is.na(data2$RFCD.Code.1.Main)] <- base::sample(x=unlist(dimnames(RF.prop)), size=sum(is.na(data2$RFCD.Code.1.Main)), replace=TRUE, prob=as.vector(RF.prop))
# data2$RFCD.Percentage.1[is.na(data2$RFCD.Percentage.1)] <- 100
# 
# # ### Replace NAs of SEO.Code.1.Main similar distributed as the rest
# SEO.prop <- prop.table(table(data2$SEO.Code.1.Main))
# data2$SEO.Code.1.Main[is.na(data2$SEO.Code.1.Main)] <- base::sample(x=unlist(dimnames(SEO.prop)), size=sum(is.na(data2$SEO.Code.1.Main)), replace=TRUE, prob=as.vector(SEO.prop))
# data2$SEO.Percentage.1[is.na(data2$SEO.Percentage.1)] <- 100
# 
# 

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


## Turn Charaters into factors
for (column in names(data2)){
  if (is.character(unlist(data2[column])) == TRUE) {
    data2[column] <- as.factor(unlist(data2[column]))
  }
}


## Training, Testing und Validation Split
test_id <- unlist(read.csv(".//..//..//Data//text//training2_ids.txt", na.strings=c("NA", ""), as.is=TRUE, strip.white = TRUE))
validation_id <- unlist(read.csv(".//..//..//Data//text//testing_ids.txt", na.strings=c("NA", ""), as.is=TRUE, strip.white = TRUE))

data2["Set_ID"] <- "Training"
data2$Set_ID[test_id] <- "Testing"
data2$Set_ID[validation_id] <- "Validation"
data2$Set_ID <- as.factor(data2$Set_ID)






data_cleaned <- data2
save(data_cleaned, file=".//..//..//Data//RData//cleaned_all.RData")






