#'-------------------------------------------
#' Scrape Drecon's list of rums measured
#' with hydrometer
#' 
#' http://www.drecon.dk/index.php/17-list-of-rum-measured
#'-------------------------------------------

library(rvest)
library(purrr)
library(dplyr)

drecon <- read_html("http://www.drecon.dk/index.php/17-list-of-rum-measured")

tbls <- html_nodes(drecon, "table")

parse_rum_table <- function(atab){
  out <- html_table(atab, header = TRUE) %>%
    mutate(`%ABV label` = gsub(",", ".", `%ABV label`) %>% as.numeric,
           `Hydrometer Measurement/Reading` = gsub(",", ".", `Hydrometer Measurement/Reading`),
           `Sugar g/L` = gsub(",", ".", `Sugar g/L`) %>% as.character,
           `Sugar g/L` = gsub("0-5", "0", `Sugar g/L`),#see webpage - no sugar added
           `Sugar g/L` = gsub(">66", "66", `Sugar g/L`) %>% as.numeric,
           
    ) 
  
  #inconsistent names
  names(out) <- gsub(" \\(SAMPLE\\)", "", names(out))
  
  out
}


tbls_df <- map_df(tbls, parse_rum_table) %>%
  janitor::clean_names() %>%
  mutate(hydrometer_measurement_reading = gsub("<", "", hydrometer_measurement_reading),
         hydrometer_measurement_reading = as.numeric(hydrometer_measurement_reading))

write.csv(tbls_df, "data/rum_hydrometer_drecon.csv", row.names = FALSE)
