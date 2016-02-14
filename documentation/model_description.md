*Intruduction*


bla bla bla


*People Model*

The people model takes the data output from *cleaning_all.R* and uses it to build a table that has one row for each person ID/project combination, alongside each individual variable that correspond to each person.

This is built from a for loop that takes each set of variables from each person on each row and then gives it its own row on a new table, alongside whether the application succeeded or failed.

This table is then cleaned to make it ready for logistic regression, through methods such as changing NAs to seperate factors, changing non factor variables to factor variables and removing NA people ID rows.

This data is then saved in the data folder as *peopleTable.RData*

This is then used by the *people_model.R* script to build a glm() binomial logistic regression model using each persons variables to predict their grant application status success. The coefficients from this model associated with each person ID is then used as the 'people score' in the Team Model.



*Team Modlel*

Ricardo's part



*Grant Model*

The awesome part
