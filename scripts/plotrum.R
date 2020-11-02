library(readr)
library(ggplot2)
library(dplyr)
library(ggridges)
library(see)

rum <- read_csv("data/rum_data.csv") %>% 
  filter(ratings>10, type != "Unknown")


ggplot(rum ,
       aes(x = log(ratings), y = score,  color = type)) +
  geom_point() +
  facet_wrap(~type)

ggplot(rum,
       aes(y = type, x = score)) +
  stat_density_ridges(jittered_points = TRUE, position = "raincloud", alpha = 0.7)

#best so far
ggplot(rum,
       aes(x = type, y = score, fill = type)) +
  geom_violinhalf(position = position_nudge(x = .2, y = 0)) +
  coord_flip()+
  geom_jitter(aes(color = type),
              width=0.15, alpha = 0.6)+
  theme(legend.position="none") + 
  theme_classic(base_size = 17) +
  labs(x = "", y = "Score", title = "Data from Rum Ratings") +
  guides(color = "none", fill = "none")


ggplot(rum,
       aes(y = type, x = score)) +
  geom_boxplot() 
