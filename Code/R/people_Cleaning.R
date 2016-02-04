library(data.table)
library(dplyr)
library(speedglm)
library('biglm')

load(file = 'cleaned_all.RData')

###---------Building People Table--------####
#turn the cleaned table into just people

for (i in 1:15) {
  x = i - 1
  if (x == 0) {
    people = data_cleaned[(12+(i*15)):(11+15+(i*15))]
    people = cbind(people, data_cleaned$Grant.Status)
    people$index = 1:length(people$Person.ID.1)
    print(i)
  }
  else {
    tempPrsn = data_cleaned[(12 + (i*15)):(11+15+(i*15))]
    tempPrsn = cbind(tempPrsn, data_cleaned$Grant.Status)
    tempPrsn$index = length(people$Person.ID.1)+1:length(tempPrsn$Person.ID.1)+(length(people$Person.ID.1)+1)
    names(tempPrsn) = names(people)
    people = rbind(people, tempPrsn)
    
  }
  print(i)
}


levels(people$With.PHD.1)[1] = 'No'

#Turn it into binary var




people$Year.of.Birth.1[(is.na(people$Year.of.Birth.1))] = median(people$Year.of.Birth.1, na.rm = TRUE)

people$age <- 2007 - people$Year.of.Birth.1

#length(people$Home.Language.1[people$Home.Language.1 == '']) / length(people$Home.Language.1) #0.9906063


length(people[-is.na(people$Person.ID.1)]$Person.ID.1)

people <- filter(people, !is.na(Person.ID.1))

people$Person.ID.1 <- as.factor(people$Person.ID.1)

people$Dept.No..1 <- as.factor(people$Dept.No..1)

people$Faculty.No..1 <- as.factor(people$Faculty.No..1)

saveRDS(people, 'peopleTable.RData')

