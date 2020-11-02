#'------------------------------------------------
#' Import data from Systembolage
#' 
#' https://www.omsystembolaget.se/english/
#' https://www.systembolaget.se/
#' 
#' Data access from https://github.com/AlexGustafsson/systembolaget-api-data/tree/master/json
#' 
#' Thanks, Alex Gustafsson!
#'------------------------------------------------

library(dplyr)
library(purrr)
library(jsonlite)

#sb_json <- fromJSON("systembolage/systembolaget-api-data-master/json/assortment.json")
sb_json <- fromJSON("https://github.com/AlexGustafsson/systembolaget-api-data/blob/master/json/assortment.json?raw=true")

rums <- sb_json$items %>% 
  as_tibble() %>%
  filter(group == "Rom" | type == "Smaksatt sprit av rom") %>%
  
  #get rid of unneded columns
  select(-type, #dark and light covered elsewhere
         -discontinued, #all FALSE
         -group, #it's all rum
         -style, #nothing here
         -testedVintage, #nothing here
         -ethical, #it's all false?
         -assortmentText, #not needed
         ) %>%
  mutate(base = case_when(
    ingredientDescription == "Sockerrör." ~ "Sugar Cane",
    ingredientDescription == "Rörsocker." ~ "Cane Sugar",
    ingredientDescription == "Sockerrörsmelass." ~ "Sugar cane molasses",
    ingredientDescription == "Melass av sockerrör." ~ "Sugar cane molasses",
    ingredientDescription == "Melass." ~ "Molasses",
    
    TRUE ~ ""
    )) %>%
  select(-ingredientDescription) %>% #don't need it anymore
  mutate(price_per_liter_use = pricePerLiter*0.11) #as of 2020-11-02

write.csv(rums, "data/systembolage_rums.csv")

# get sugar content?
# # Sockerhalt
# library(rvest)
# library(V8)
# get_sugar <- function(id, n1){
#   base_url <- "https://www.systembolaget.se/produkt/sprit/"
#   n1 <- tolower(n1) %>%
#     gsub(" ", "-", .)
#   url <- paste0(base_url, n1, "-", id)
#   
#   page <- read_html(url)
#   
#   page_script <- page %>%
#     html_nodes("script")
#   
#   jread <- v8()
#   
#   info <- jread$eval(page_script)
# }