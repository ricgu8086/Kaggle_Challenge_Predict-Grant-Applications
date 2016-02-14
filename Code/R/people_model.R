load(file = './Data/RData/peopleTable.RData')


d <- glm( y ~ ., family = binomial(link = 'logit'), data = people)

#model is d
peopleCoefList = d$coefficients
save(peopleCoefList, file = './Data/RData/peopleCoefs.RData')
