  
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
    
    label_abv = gsub("%", "0", label_abv),
    hydro_abv = gsub("%", "0", hydro_abv)
  )

write.csv(tbl_rsb, "data/rum_hydrometer_rumshopboy.csv")
