load('./Data/RData/peopleCoefs.RData')

str(peopleCoefList)

peopleCoefList


attr(peopleCoefList, 'names')

forRicardocsv = data.frame( factorName = attr(peopleCoefList, 'names'), coefficents = peopleCoefList )


forRicardocsv = data.frame( factorName = attr(peopleCoefList, 'names'), coefficents = peopleCoefList )


write.csv(forRicardocsv, file = './Data/text/peopleCoefs.csv')
