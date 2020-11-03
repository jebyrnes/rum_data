  
#'-------------------------------------------
#' Scrape Rum Shop Boy's list of rums measured
#' with hydrometer
#' 
#' https://rumshopboy.com/hydrometer-tests/
#'-------------------------------------------
  
library(rvest)
library(purrr)
library(dplyr)

rumshopboy <- read_html("https://rumshopboy.com/hydrometer-tests/")


tbl_rsb <- html_nodes(rumshopboy, "table")[[1]] %>%
  html_table() %>%
  janitor::clean_names() %>%
  as_tibble() %>%
  mutate(
    est_sugar = gsub("0-5", "0", est_sugar),
    est_sugar = gsub("g", "", est_sugar),
    est_sugar = gsub("^$", "0", est_sugar),
    est_sugar = as.numeric(est_sugar),
    
    label_abv = gsub("%", "", label_abv) %>% as.numeric,
    hydro_abv = gsub("%", "", hydro_abv),
    hydro_abv = gsub("41-42", "41.5", hydro_abv),
    hydro_abv = gsub("57-80", "NA", hydro_abv),
    hydro_abv = as.numeric(hydro_abv)

  )

write.csv(tbl_rsb, "data/rum_hydrometer_rumshopboy.csv", row.names = FALSE)
