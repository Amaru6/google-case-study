pacman::p_load(tidyverse, janitor, here)
library(ggradar2)
library(tidymodels)
source(here("functions", "functions_1.R"))
theme_set(theme_julio())

# data ------#
read_rds(here("data", "workfile", "workfile.rds")) -> workfile_data
#----------#
# LITTLE NOTE: This is a simple machine learning model (decision tree).
# I don't want to go too much in deep so I just use this model as a
# exploratory tool and as a first model to come up with evidence
# about predictors. The process of prediction naturally doesn't match
# up with my analysis. 
# To come up with a good model we could have followed the following steps:
# (1) Split the data
# (2) Feature enginerring
# (3) Tune a model
# (4) Evaluate the model on unseen data.
# I didn't follow that process as explained above.


#---------------------------------#
decision_tree(tree_depth = 3) |> 
  set_engine("rpart") |> 
  set_mode("regression") -> tree_spec

workfile_data |>
  separate(key, into = c("departamento", "provincia", "distrito"),
           sep = "_") |> 
  select(area, gestion_2, ise_mean, matematica, lectura,
         departamento, provincia, distrito) |> 
  mutate(across(.cols = c(matematica, lectura),
                .fns = scale)) |> 
  mutate(test = (matematica + lectura)/2) |> 
  select(departamento, provincia, distrito, 
         area, gestion_2, ise_mean, test) -> workfile_to_model
workfile_to_model |> 
  mutate(across(.cols = where(is.character),
                .fns = as.factor)) -> workfile_to_model

workfile_to_model |> 
  recipe(test ~ ., data = _) |> 
  step_dummy(all_nominal_predictors()) -> recipe_1

workflow() |> 
  add_recipe(recipe_1) |> 
  add_model(tree_spec) -> wf_1

### fit_model ------#
wf_1 |> 
  fit(workfile_to_model) -> tree_model_fitted

tree_model_fitted |> 
  extract_fit_engine() -> tree_model_rpart
tree_model_rpart |> treemisc::tree_diagram()

### From this simple model and the diagram we can clearly see that
### one of the most important variables to consider is the economic
### situation of the family. As mentioned above, all those confounders
### seem to be important.




### I can guess the most important factor is the economic condition
### but we need to confirm that with data and come up with evidence.

# GET THE MOST IMPORTANT PREDICTORS

pacman::p_load(DALEXtra, DALEX)
explain_tidymodels(
  model = tree_model_fitted,
  data = workfile_to_model |> select(-test),
  y = workfile_to_model |> pull(test),
  label = "rpart_model"
) -> model_explained
set.seed(6)
model_parts(model_explained) -> mod_var_imp
plot(mod_var_imp)  # Confirmed.


# Question and solution:
## PROBLEM: A governmental or a non-profit organization wants to
## tackle the problem of low test scores among schools, particularly in
## public schools. They want to tackle the problem but don't have an
## infinite budget so they must focus on the most important factors to
## consider. So they ask:

## ASK: What are important factors to consider when it comes to 
## predicting test scores in a given school?

## SOLUTION: One important factor to consider are the economic conditions
## of the household. Transfer programs that aim to help the economic
## conditions of the household or voucher schemes could faciliate the
## problem to parent by allowing parents increase their budget. We can also
## tackle the services available to student's houses. 
