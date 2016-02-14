*Intruduction*


bla bla bla


*People Model*

John`s part



*Team Modlel*

Ricardo's part


**Final Model**

The final model predicts if a grant application will be accepted or not. A random forest with 3000 trees is used for this classification. The input variables are the combination of the output of the Team Model with the cleaned and supplemented data from the University of Melbourne.

In total the model uses 65 features, 14 of them are taken from the output of the Team Model. The rest of the features are either taken from the original competition dataset or directly engineered from it.

The model produces an area under the ROC of 91.4. This result would have placed us on rank 78 on the Kaggle Competition leaderboard, however as the competition was already over, we were not able to test our model on the official testing data. Instead we cut our testing set from the training data. 
If we had been able to train this model on the full training data, we might have been able to achieve an even better result.

|  Prediction | Granted  | not Granted |
|-------------|----------|-------------|
|  Granted    |    482   |      88     |
|  Not Granted|    384   |     603     |


The model is quite good at finding the applications which will eventually get granted, even though it missclassifies some of the application which did ot receive funding.

The most important features were:

Number of unsuccelsful applications of Team members
Number of succesful applications of Team members
Sponsor of the grant
Day of Month
Month
Contract Value Band
Grant Category Code

All these variables are intuitively related to the sucess of an application,except for *Day of Month* and *Month*. A possible explanation for the high importance of these features is, that for many sponsors the probability of granting funding decreases to zero after reaching their budget. This makes it less likely for an application to be successful later in the months. Similar reasoning might explain the importance of the month of the application. At certain times of the year, their may be varying funding budgets and also a varying number of competing applications.



** Cleaning the Data **

The original dataset from the University of Melbourne is formated quite ugly. There are 249 features, mainly because for every person working on a project there are 15 featurs to describe this person and the maximium team size is 15 people. So 225 of the 249 features describe the people who created the application. As many application were created by teams much smaller than 15 people, most of the columns are filled very scarcely.

These 225 features were handled in the People and the Team Model, so the *cleaning_all.r* file just takes care of the first 24 features.

The date column was properly formated and these new features were derived from it: Weekday, Month, Day and Month, Day of Month and Season.

As there was a significant amount of missing values in the dataset, we had to find way to deal with them.

For the feature *Contract Value Band*, which is a factrorial variable classifying the contract value into 14 levels, we filled the missing data with random samples from an empirical distribution of the existing data.

For the columns *Grant Category Code* and *Sponsor Code* which are factorial variables as well, we were able to use a more accurate model. As both variables are significantly correlated with the *Contract Value Band*, we could use this information to create conditional empirical distributions for *Grant Category Code* and *Sponsor Code* depending on the *Contract Value Band*of the respective application.

Each application has up to 5 *RFCD Codes*, which describe the university departments working on this project and up to 5 socioeconomic objectives in the *SEO Code* columns. For each of these ten columns there is an additional column showing the percentage of the project related to the respective department or scioeconomic objectve. As the majority of the application have a maximum of two departments and SEOs, most of these features are empty.
To be able to use this information we created columns for each possible department and socioeconomic objective, stating respected percentage. This organization simplyfies the access to information greatly. instead of checking five different columns to see if the project is related to a certain department, you have to check just one. 

After the cleaning, the was split into a training, a testing and a validation set.