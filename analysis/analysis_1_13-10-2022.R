pacman::p_load(tidyverse, janitor, here)
library(ggradar2)
source(here("functions", "functions_1.R"))
theme_set(theme_julio())
# get workfile

read_rds(here("data", "workfile", "workfile.rds")) -> workfile_orig
workfile_orig |> 
  select(key, lectura, matematica, area, gestion_2, ise_mean) -> workfile


# EDA

workfile |> 
  mutate(test = (lectura + matematica)/2) |> 
  select(key, area, gestion_2, test, ise_mean, lectura, matematica) -> workfile

## radar chart

### cleaned_input
workfile |> 
  select(key, lectura, matematica) |>
  mutate(test = (lectura + matematica)/2) |> 
  mutate(across(.cols = c(lectura, matematica),
                .fns = scale,
                .names = "{col}")
  ) -> workfile_eda_1 # I first need to scale the variables to get
# a calculation from both because they have different scales!


workfile_eda_1 |> 
  mutate(test = (lectura + matematica)/2) -> workfile_eda_1
workfile_eda_1 |> 
  separate(key, into = c("departamento", "provincia", "distrito"),
           sep = "_") |> 
  group_by(departamento) |> 
  summarise(
    metric = c("lectura", "matematica", "test"),
    measurement = c(mean(lectura, na.rm = T), 
      mean(matematica, na.rm = T), 
      mean(test, na.rm = T))
  ) -> workfile_eda_1_2 # cleaned all the names

#### histogram
workfile_eda_1_2 |> 
  ggplot(aes(x = test, y = stat(density))) + 
  geom_line(stat = "density", size = 1) + labs(x = "Test", y = ""
                                               )
#### nothing extreme going on!

workfile_eda_1_2 |> 
  skimr::skim(test, matematica, lectura)


#------------#

workfile_eda_1_2 |> 
  pivot_wider(names_from = metric, values_from = measurement) -> workfile_eda_1_2

workfile_eda_1_2 |> ungroup() -> workfile_eda_1_2 
workfile_eda_1_2 |> 
  rename(Lectura = lectura,
         Matemática = matematica,
         Test = test) |> 
  filter(departamento %in% c("LIMA", "CALLAO", "HUANCAVELICA")) |> 
  column_to_rownames(var = "departamento") |> 
  ggradar2(grid.line.trend = "increase",
           gridline.max.colour = "black",
           gridline.min.colour = "black",
           gridline.max.linetype = "solid",
           polygonfill = F,
           gridline.mid.colour = "white"
           ) # I don't know this is very useful...

### bar plot (ordered by test score)

workfile_eda_1_2 |> 
  mutate(pos = test > 0) |> 
  ggplot(aes(x = test, y = fct_reorder(departamento,test), fill = pos)) + 
  geom_col() + 
  theme(legend.position = "none") + 
  scale_fill_manual(values = c("grey20", "steelblue")) + 
  labs(y = "", x = "Test"
) # Seems like Loreto got it worse along with Huancavelica. Sadly, this is expected.


# who performed it better? Public or private schools ?

workfile |> distinct(gestion_2)
workfile |> 
  separate(key, into = c("departamento",
                         "provincia",
                         "distrito"),
           sep = "_") |> 
  mutate(across(.cols = c(lectura, matematica),
                .fns = scale,
                .names = "{col}")) |> 
  mutate(test = (lectura + matematica)/2) |> 
  ggplot(aes(y = departamento, x = test, fill = as.factor(gestion_2))) + 
  geom_boxplot(outlier.shape = NA) + theme(legend.title = element_blank()) + 
  labs(y = "") + 
  scale_fill_manual(values = c("grey70", "steelblue")) 
## As expected No government schools perform better than no governmental ones
## That doesn't mean that they are "better" or are causing a greater
## test score since the kids who go there probably have other conditions
## they can enjoy that makes them better at school. These are call
## confounders. One of them is the "economic conditions of the family". We 
## can use regression to hold that variable constant

# regression analysis

workfile |>  
  mutate(across(.cols = c(lectura, matematica),
                .fns = scale,
                .names = "{col}")) |> 
  mutate(test = (lectura + matematica)/2) |> 
  lm(test ~ gestion_2 + ise_mean, data = _) |> 
  broom::tidy()


### We get that schools with no governmental administration and holding
### constant the economic indicators aggregated per district perform
### better than governmental ones. Of course, this is a raw estimate
### serious problems occurs because each school have a couple of
### confounders that we wish to control for such as the quality of books,
### teachers, etc. A proxy solution would be to use panel data.
### But we don't have that here.




