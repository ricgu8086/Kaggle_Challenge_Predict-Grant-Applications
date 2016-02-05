load(file = '/data/RData/peopleTable.RData')
library(speedglm)
library('biglm')
library(data.table)

#model = glm(`data$Grant.Status`~., family = binomial(link = 'logit'), data = people)

#model = glm(people$`data$Grant.Status`~., family = binomial(link = 'logit'), data = data.frame(people$Person.ID.1, people$`data$Grant.Status`))
subsetModel = length(people$Person.ID.1)/2

miniDataset = data.frame(pplID = people$Person.ID.1[1:subsetModel], grntStatus = people$data.Grant.Status[1:subsetModel])

model = speedglm(grntStatus~., family = binomial(link = 'logit'), data = miniDataset)

#  phase 2 

miniDataset = data.frame(pplID = people$Person.ID.1[1:subsetModel], grntStatus = people$data.Grant.Status[1:subsetModel], age = as.factor(people$A..1[1:subsetModel]))

model = speedglm(grntStatus~., family = binomial(link = 'logit'), data = miniDataset)

miniDataset = data.frame(grntStatus = people$data.Grant.Status[1:subsetModel], pubz = (people$C.1[1:subsetModel]))

model = speedglm(data.Grant.Status~., family = binomial(link = 'logit'), data = (select(people, -Person.ID.1)))
                 '
b<-bigglm( log(data.Grant.Status) ~ Person.ID.1, data = people)
                 
save.image(file = 'MiniDSRComp')
                 
##############model testing
                 
peopleA <- people
                 
peopleA$`data_cleaned$Grant.Status` = as.numeric(peopleA$`data_cleaned$Grant.Status`)

peopleA$Person.ID.1 = as.factor(peopleA$Person.ID.1)

b<-bigglm( `data_cleaned$Grant.Status` ~ Person.ID.1, family = binomial(link = "logit"), data = peopleA)                 
b<-bigglm( `data_cleaned$Grant.Status` ~ Person.ID.1, family = binomial(link = "logit"), data = people)

glm()
b <- bigglm( `data_cleaned$Grant.Status` ~ Person.ID.1, family = binomial(link = "logit"), data = na.omit(peopleA), maxit = 2500, chunksize = 100)

b <- glm( `data_cleaned$Grant.Status` ~ ., family = binomial(link = "logit"), data = na.omit(peopleA))

length(people$`data_cleaned$Grant.Status`)

mean(table(people$Person.ID.1))

summary(table(people$Person.ID.1))
range(table(people$Person.ID.1)

# table(table(people$Person.ID.1)) distribution of applicants per person
perso

glm( `data_cleaned$Grant.Status` ~ ., family = binomial(link = "logit"), data = na.omit(peopleA))

c <- glm( `data_cleaned$Grant.Status` ~ ., family = binomial, data = na.omit(peopleA),
control = list(maxit = 500))
c$
save(toSave, file = 'firstRoundCoefficentz.RData')

library(lattice)
densityplot(predict(c, type='link'))

d <- glm( `data_cleaned$Grant.Status` ~ ., family = binomial(link = 'logit'), data = na.omit(peopleA), control = list(maxit = 500))

d <- glm( y ~ ., family = binomial(link = 'logit'), data = people)

#model is d!!
peopleCoefList = d$coefficients
save(peopleCoefList, file = '/data/RData/peopleCoefs.RData')
