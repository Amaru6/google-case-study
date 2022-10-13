pacman::p_load(tidyverse, here, haven, janitor)

# get_data ---------------------

## ECE indice socioeconomico ------#
# This didn't work
# unzip(here("data", "raw_data", "2S_ECE_19.zip"),
#        exdir = here("data", "raw_data"))


# This worked!
### ece_2019
## NOTE: This "raw data" will not ve available in this repository
## since it is too large to fit in. But the data can be found in
## http://umc.minedu.gob.pe/resultadosnacionales2019/

read_sav(unz(here("data", "raw_data", "2S_ECE_19.zip"),
             "ECE_2S_2019_WEB.sav")) -> ece_2019_status
ece_2019_status |> clean_names() -> ece_2019_status

ece_2019_status |> 
  distinct(id_ie, id_seccion, cor_est)

## See if get repeated

ece_2019_status |> 
  distinct(departamento, provincia, distrito) |> nrow()

ece_2019_status |> 
  distinct(distrito) # yes some district names are repeated

ece_2019_status |> 
  mutate(key = str_glue("{departamento}_{provincia}_{distrito}")) |> 
  group_by(key) |> 
  summarise(ise_mean = mean(ise, na.rm = T),
            ise_sd = sd(ise, na.rm = T),
            ise_median = median(ise, na.rm = T)) -> ece_2019_indicator_eco  

ece_2019_indicator_eco


# write_rds(ece_2019_indicator_eco, here("data", "raw_data", 
#                                        "ece_2019_indicator_eco.rds"))


# ECE resultados 2019

library(openxlsx)
read.xlsx(here("data", "raw_data", "ece_2s_15-19.xlsx"),
          sheet = "new_sheet") |> 
  as_tibble() |> 
  clean_names() -> resultados_ece

resultados_ece |> 
  select(region, provincia, distrito, lectura, matematica, area, gestion_2
         ) -> resultados_ece

# write_rds(resultados_ece, here("data","raw_data","resultados_ece.rds"))

