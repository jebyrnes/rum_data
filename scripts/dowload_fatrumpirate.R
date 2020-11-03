#'-------------------------------------------
#' Scrape The Fat Rum Pirate's list of rums measured
#' with hydrometer
#' 
#' https://thefatrumpirate.com/hydrometer-tests-2
#'-------------------------------------------

library(rvest)
library(purrr)
library(dplyr)

fatrum <- read_html("https://thefatrumpirate.com/hydrometer-tests-2")

tbl <- html_nodes(fatrum, "table")[[1]] %>%
  html_table() %>%
  janitor::clean_names() %>%
  as_tibble() %>%
  mutate(additives_g_l = gsub("0-5", "0", additives_g_l),
         additives_g_l = gsub("Unknown \\(producer states 99 g/L", "100", additives_g_l),
         additives_g_l = as.numeric(additives_g_l),
         percent_abv_measured = as.numeric(percent_abv_measured)
  )

write.csv(tbl, "data/rum_hydrometer_fatrumpirate.csv", row.names = FALSE)
