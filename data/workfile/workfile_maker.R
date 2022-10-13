pacman::p_load(tidyverse, here, haven, janitor)

read_rds(here("data", "raw_data", "01_ece_2019_indicator_eco.rds")) -> tbl_1

read_rds(here("data", "raw_data", "02_resultados_ece.rds")) |> 
  mutate(key = str_glue("{region}_{provincia}_{distrito}")) |> 
  select(-c(region, provincia, distrito)) |> 
  select(key, everything()) -> tbl_2

tbl_2 |> 
  inner_join(tbl_1, by = "key") -> tbl_to_analyse

write_rds(tbl_to_analyse, here("data", "workfile", "workfile.rds"))
