library(data.table)
library(dplyr)
library(speedglm)
data = data.frame(read.csv(list.files()[3]))

library('biglm')




# SEO = Socioeconomic Objective


###### ----------- Cleaning Data -----------------######

data <- data %>% mutate_each(funs(factor), starts_with("RFCD.Code"), starts_with("SEO.Code"), starts_with("Person.ID"),
                             starts_with("Dept.No"), starts_with("Faculty.NO"))

# Selecting factors
fac.names <- data %>% select(which(sapply(.,is.factor))) %>% names()
str(data[fac.names])

data.frame(treatment=substr(variable, 1,1), time=as.numeric(substr(variable,2,2))) #??

department.names <- factor(paste("Dep." ,(levels(factor(data$RFCD.Code.1 %>% substring(1,2)))), sep=""))

data2 <- data

data2[department.names[1]] <- 0

###---------Building People Table--------####
#15 vars per person and up to 15 people per application


for (i in 1:15) {
  x = i - 1
  if (x == 0) {
    people = data[(12+(i*15)):(11+15+(i*15))]
    people = cbind(people, data$Grant.Status)
    people$index = 1:length(people$Person.ID.1)
    print(i)
  }
  else {
    tempPrsn = data[(12 + (i*15)):(11+15+(i*15))]
    tempPrsn = cbind(tempPrsn, data$Grant.Status)
    tempPrsn$index = length(people$Person.ID.1)+1:length(tempPrsn$Person.ID.1)+(length(people$Person.ID.1)+1)
    names(tempPrsn) = names(people)
    people = rbind(people, tempPrsn)
    
  }
  print(i)
}



# cntrl z 
glimpse(data)

table(people$Country.of.Birth.1,people$Home.Language.1)


#person what they put in last time

levels(people$With.PHD.1)[1] = 'No'

#Turn it into binary var

median(people$Year.of.Birth.1, na.rm = TRUE)
#1960


people$Year.of.Birth.1[(is.na(people$Year.of.Birth.1))] = 1960

people$age <- 2007 - people$Year.of.Birth.1

length(people$Home.Language.1[people$Home.Language.1 == '']) / length(people$Home.Language.1) #0.9906063

write.csv(people, 'peopleTable.csv')

length(people[-is.na(people$Person.ID.1)]$Person.ID.1)

people <- filter(people, !is.na(Person.ID.1))

people$Person.ID.1 <- as.factor(people$Person.ID.1)

people$Dept.No..1 <- as.factor(people$Dept.No..1)

people$Faculty.No..1 <- as.factor(people$Faculty.No..1)
# create prelim model

write.csv(people, 'peopleTable.csv')

#model = glm(`data$Grant.Status`~., family = binomial(link = 'logit'), data = people)

#model = glm(people$`data$Grant.Status`~., family = binomial(link = 'logit'), data = data.frame(people$Person.ID.1, people$`data$Grant.Status`))
subsetModel = length(people$Person.ID.1)/2

miniDataset = data.frame(pplID = people$Person.ID.1[1:subsetModel], grntStatus = people$data.Grant.Status[1:subsetModel])

model = speedglm(grntStatus~., family = binomial(link = 'logit'), data = miniDataset)

#  phase 2 

miniDataset = data.frame(pplID = people$Person.ID.1[1:subsetModel], grntStatus = people$data.Grant.Status[1:subsetModel], age = as.factor(people$A..1[1:subsetModel]))

model = speedglm(grntStatus~., family = binomial(link = 'logit'), data = miniDataset)

miniDataset = data.frame(grntStatus = people$data.Grant.Status[1:subsetModel], pubz = (people$C.1[1:subsetModel]))

model = speedglm(data.Grant.Status~., family = binomial(link = 'logit'), data = (select(people, -Person.ID.1))

b<-bigglm( log(data.Grant.Status) ~ Person.ID.1, data = people)

save.image(file = 'MiniDSRComp')
