## Introduction ##

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

Initially, the table contained too large an amount of factors, with each person ID and all possible departments and faculties. We reduced the amount of factors by lumping the least important factors together.

This was done as the  model function used had hard limits on the number of factors that could be used  as inputs and those factor levels that had the least people involved were deemed to contain the least predictive information, making a good target for simplifying the table.

This data is then saved in the data folder as *peopleTable.RData*

This is then used by the *people_model.R* script to build a glm() binomial logistic regression model using each persons variables to predict their grant application status success. The coefficients from this model associated with each person ID is then used as the 'people score' in the Team Model.



# Team Analysis #

Ricardo's part



# Grant Analysis #

The awesome part
<<<<<<< HEAD
=======

# Final model #

## Results ##

As our results are not directly comparable, as we had less data

>>>>>>> db023128648616cd3cd4bd990423254f5f84481a
