import pandas as pd
import numpy as np

# Paths
########
from matplotlib.finance import index_bar
from sphinx.addnodes import index

path_data = r"..\..\Data\text\\"
path_original = path_data + "unimelb_training.txt"
path_people = path_data + "peopleCoefs.csv"
path_output = path_data + "teamTable.csv"


# Loading data
###############

df = pd.read_csv(path_original, sep=",", low_memory=False)
people_scores_df = pd.read_csv(path_people, low_memory=False)




team_cols = ["People.score", "A..papers", "A.papers", "B.papers", "C.papers",\
             "Dif.countries", "Number.people", "PHD", "Max.years.univ", "Grants.succ",\
             "Grants.unsucc", "Departments", "Perc_non_australian"] #All are sum unless specified in the name

team_df = pd.DataFrame(columns = team_cols)


# Get total papers of each category
input_cols = ["A.", "A", "B", "C"]
output_cols = [x+".papers" for x in input_cols]

for inp, outp in zip(input_cols, output_cols):
    interest_cols = [inp+".%d" % x for x in range(1,16)]
    team_df[outp] = df[interest_cols].apply(lambda x: np.nansum(x), axis =1)


# Get total different countries
inp = "Country.of.Birth"
outp = "Dif.countries"
interest_cols = [inp+".%d" % x for x in range(1,16)]
team_df[outp] = df[interest_cols].apply(lambda x: len(set(x[~x.isnull()])), axis =1)

# Get the size of the team
inp = "Person.ID"
outp = "Number.people"
interest_cols = [inp+".%d" % x for x in range(1,16)]
team_df[outp] = df[interest_cols].apply(lambda x: len(set(x[~x.isnull()])), axis =1)

# Get the number of PHDs
inp =  'With.PHD'
outp = "PHD"
interest_cols = [inp+".%d" % x for x in range(1,16)]
aux = df[interest_cols].replace({"Yes ": 1, np.nan: 0, "No": 0, "yes":1})
team_df[outp] = aux.apply(lambda x: np.nansum(x), axis =1)

# Get the people with more years working in the university per each team
# This data is a bit more difficult as we don't have just numbers but categories
inp =  "No..of.Years.in.Uni.at.Time.of.Grant" 
outp = "Max.years.univ"
interest_cols = [inp+".%d" % x for x in range(1,16)]

categories_of_years = pd.Series(df[interest_cols].values.ravel()).unique()
year_converter = dict(zip(categories_of_years, [0, 0, 20, 10, 5, 15]))

aux = df[interest_cols].replace(year_converter)
team_df[outp] = aux.apply(lambda x: np.nansum(x), axis =1)


# Get the number of successful grants per team
inp =  'Number.of.Successful.Grant'
outp = "Grants.succ"
interest_cols = [inp+".%d" % x for x in range(1,16)]
team_df[outp] = df[interest_cols].apply(lambda x: np.nansum(x), axis =1)

# Get the number of unsuccessful grants per team
inp =  "Number.of.Unsuccessful.Grant"
outp = "Grants.unsucc"
interest_cols = [inp+".%d" % x for x in range(1,16)]
team_df[outp] = df[interest_cols].apply(lambda x: np.nansum(x), axis =1)


# Get the degree of multidepartamentality, i.e. how many departments are in each team
inp =  "Dept.No."
outp = "Departments"
interest_cols = [inp+".%d" % x for x in range(1,16)]
team_df[outp] = df[interest_cols].apply(lambda x: len(set(x[~x.isnull()])), axis =1)

# Get the percentage of non australian people (probably there are some grants
# reserved for foreign people
inp = "Country.of.Birth"
outp = "Perc_non_australian" # From 0 to 1
interest_cols = [inp+".%d" % x for x in range(1,16)]

def compute_perc(x):
    total = len(x[~x.isnull()])
    
    if total == 0:
        return 0
    
    australian = len([elem for elem in x if elem == "Australia"])
    return australian/float(total)
    
team_df[outp] = df[interest_cols].apply(compute_perc, axis =1)

# Get a feature based on people scores for each team
# TODO
# By the moment just fill it with -1
team_df["People.score"].fillna(-1, inplace=True)


# Done, saving
##############

team_df.to_csv(path_output, index_label=False)
print "Yataaa!!"  # In honor to Hiro Nakamura

