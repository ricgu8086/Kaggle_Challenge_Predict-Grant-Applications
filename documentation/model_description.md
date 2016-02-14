*Intruduction*

This project was done as a part of the Data Science Retreat batch 6.

The original competition ran during the dates below.

Started: 9:22 am, Monday 13 December 2010 UTC
Ended: 10:00 pm, Sunday 20 February 2011 UTC (69 total days)

We however, completed our approach in a 3 day period.

Here we will describe our approach to creating a model.

The first problem we encountered with this dataset was that each row, which corresponded to each individual grant application, would have multiple columns to list aspects within a variable. For example, there was room for 15 people for each project, with each person being randomly allocated to either person 1 or person 2 columns in each row.

This was an issue, as a model would be unable to find trends in data if variables were split across columns. So to combat this we decided to create two smaller models to sum up the information contained within each person and their team. The first being the people model and the second being the team model.

# Splitting #

Because of the test data available lacked the *Grant.Status* field, i.e. the target we want to predict, we arrange our labeled data (training dataset) in the following way: in the first round,we take data from group 1 (see Figure 1) for training, and data from group 2 for validation (parameter tuning). After we achieved one model we were confident on it, we move to the second round, where we use data from group 1 and group 2 for training (keeping the same parameters learned) and used data from group 3 for testing. The predictions obtained in this group 3, are the results presented in the Results section.

You can find the exact ids used to do the splitting in the following files:

1. *testing_ids.txt*
2. *training2_ids.txt*


![Splitting data](https://raw.githubusercontent.com/ricgu8086/Kaggle_Challenge_Predict-Grant-Applications/master/Documentation/Pic/Splitting.jpg)

Figure 1. Splitting data.

## Feature Analysis ##

![How the model was built](https://raw.githubusercontent.com/ricgu8086/Kaggle_Challenge_Predict-Grant-Applications/master/Documentation/Pic/How%20the%20model%20was%20built.jpg)

Figure 2. Overview of our analysis on the presented features.

# People Analysis #

The people model takes the data output from *cleaning_all.R* and uses it to build a table that has one row for each person ID/project combination, alongside each individual variable that correspond to each person.

This is built from a for loop that takes each set of variables from each person on each row and then gives it its own row on a new table, alongside whether the application succeeded or failed.

This table is then cleaned to make it ready for logistic regression, through methods such as changing NAs to seperate factors, changing non factor variables to factor variables and removing NA people ID rows.

This data is then saved in the data folder as *peopleTable.RData*

This is then used by the *people_model.R* script to build a glm() binomial logistic regression model using each persons variables to predict their grant application status success. The coefficients from this model associated with each person ID is then used as the 'people score' in the Team Model.



# Team Analysis #

Ricardo's part



# Grant Analysis #

The final model predicts if a grant application will be accepted or not. A random forest with 3000 trees is used for this classification. The input variables are the combination of the output of the Team Model with the cleaned and supplemented data from the University of Melbourne.

In total the model uses 65 features, 14 of them are taken from the output of the Team Model. The rest of the features are either taken from the original competition dataset or directly engineered from it.

The model produces an area under the ROC of 91.4. This result would have placed us on rank 78 on the Kaggle Competition leaderboard, however as the competition was already over, we were not able to test our model on the official testing data. Instead we cut our testing set from the training data. 
If we had been able to train this model on the full training data, we might have been able to achieve an even better result.

|  Prediction | Granted  | not Granted |
|-------------|----------|-------------|
|  Granted    |    482   |      88     |
|  Not Granted|    384   |     603     |

As our results are not directly comparable, as we had less data

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