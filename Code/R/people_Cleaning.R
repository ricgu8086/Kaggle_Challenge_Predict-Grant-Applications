library(data.table)
library(dplyr)
library(speedglm)
library('biglm')

load(file = './Data/RData/cleaned_all.RData')

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

table(people$Dept.No..1, people$`data_cleaned$Grant.Status`) < 10
table(people$Faculty.No..1, people$`data_cleaned$Grant.Status`) < 20

######### Option1 all lower departments  become one variable
peopleNoOther = people 
names(table(people$Dept.No..1 )[table(people$Dept.No..1 ) < 10])

lapply(names(table(people$Faculty.No..1))[table(people$Faculty.No..1) > 20], function(x) 
  levels(people$Faculty.No..1)[grep(x, levels(people$Faculty.No..1))] = 'Other')

#### faculty turning NAs into other aswell as under 20 app departments
fac2change = names(table(people$Faculty.No..1)[table(people$Faculty.No..1) < 20])
 
levels(people$Faculty.No..1) = c(levels(people$Faculty.No..1), 'Other')
for (i in 1:length(fac2change)) {
  
  faccode = fac2change[i]
  people$Faculty.No..1[grep(faccode, people$Faculty.No..1)] = 'Other'
  people$Faculty.No..1[is.na(people$Faculty.No..1)] = 'Other'
  print(i)
}

#### dept turning NAs into other aswell as under 20 app departments
dep2change = names(table(people$Dept.No..1)[table(people$Dept.No..1) < 10])

levels(people$Dept.No..1) = c(levels(people$Dept.No..1), 'Other')
for (i in 1:length(dep2change)) {
  
  depcode = dep2change[i]
  people$Dept.No..1[grep(depcode, people$Dept.No..1)] = 'Other'
  people$Dept.No..1[is.na(people$Dept.No..1)] = 'Other'
  print(i)
}

#### factor turning NAs into other aswell as under 1 IDzzz
ID2change = names(table(people$Person.ID.1)[table(people$Person.ID.1) < 2])

levels(people$Person.ID.1) = c(levels(people$Person.ID.1), 'Other')
for (i in 1:length(ID2change)) {
  
  IDcode = ID2change[i]
  people$Person.ID.1[grep(IDcode, people$Person.ID.1)] = 'Other'
  people$Person.ID.1[is.na(people$Person.ID.1)] = 'Other'
  print(i)
}

#change y var to less awkward name

people$y = people$`data_cleaned$Grant.Status`
people$`data_cleaned$Grant.Status` = NULL

#peopleWOther = people
save(people, file = './Data/RData/peopleTable.RData' )
#save(people, file='./Data/RData/peopleTable.RData')


