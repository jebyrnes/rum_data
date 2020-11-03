#'------------------------------
#' Merge Rum Data Sets
#'------------------------------

#libraries
library(dplyr)
library(stringr)
library(tidyr)
library(purrr)
library(readr)

setwd(here::here())

rum_ratings <- read_csv("data/rum_data.csv") %>%
  select(-price) #gone

# merge rum hydrometer data sets
decon <- read_csv("data/rum_hydrometer_drecon.csv") %>%
  rename(additives_g_l = sugar_g_l,
         hydro_abv = hydrometer_measurement_reading,
         label_abv = percent_abv_label) %>%
  mutate(hydro_source = "decon")


fatrum <- read_csv("data/rum_hydrometer_fatrumpirate.csv") %>%
  rename(hydro_abv = percent_abv_measured,
         label_abv = percent_abv_label) %>%
  mutate(hydro_source = "fat rum pirate")

boy <- read_csv("data/rum_hydrometer_rumshopboy.csv") %>%
  rename(additives_g_l = est_sugar) %>%
  mutate(rum = paste(brand_bottler, rum),
         hydro_source = "rumshopboy") %>%
  select(-brand_bottler)

#merge data and eliminate dups
hydro_data <- bind_rows(decon, fatrum, boy) %>%
  tidyr::drop_na(rum) %>%
  mutate(rum = gsub("  ", " ", rum)) %>%
  group_by(rum) %>%
  slice(1L) %>% #just get the first one
  ungroup() %>%
  rename(hydro_rum_name = rum)
  
write_csv(hydro_data, "data/merged_hydro_data.csv")

# merge hydrometer data with rum ratings
hydro_lut <- read_csv("data/hydro_rr_lut.csv")

hydro_rr_join <- left_join(hydro_data, hydro_lut) %>%
  filter(!is.na(name)) %>%
  mutate(name = iconv(name, from = 'UTF-8', to = 'ASCII//TRANSLIT')) %>%
  right_join(rum_ratings)

plot(score ~ additives_g_l, data = hydro_rr_join)

# merge in systembolage for price info
systembolage <- read_csv("data/systembolage_rums.csv") %>%
  rename(company_name = name) %>%
  mutate(name = paste(company_name, name2))

all_sources_join <- left_join(hydro_rr_join, systembolage)

write_csv(all_sources_join, "merged_rum_master.csv")
