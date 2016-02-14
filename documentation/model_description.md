## Introduction ##

People have more than 2 months, we have 3 days


Started: 9:22 am, Monday 13 December 2010 UTC
Ended: 10:00 pm, Sunday 20 February 2011 UTC (69 total days) 

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

John`s part



# Team Analysis #

Ricardo's part



# Grant Analysis #

The awesome part

# Final model #

## Results ##

As our results are not directly comparable, as we had less data

