load('./Data/RData/peopleCoefs.RData')



forRicardocsv = data.frame( factorName = attr(peopleCoefList, 'names'), coefficents = peopleCoefList )


write.csv(forRicardocsv, file = './Data/text/peopleCoefs.csv')
