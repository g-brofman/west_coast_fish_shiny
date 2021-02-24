library(here)
library(tidyverse)
library(treemap)
fish_data_raw_dg <- read.csv(here("grave", "west_coast_eez_data", "SAU EEZ 848 v48-0.csv")) 


## Looking at fish, over all years, by gear type 

fish_by_gear_allyears <- fish_data_raw_dg %>% 
  arrange(gear_type)

fish_treeable <- fish_by_gear_allyears %>% 
  select(commercial_group, common_name) %>% 
  group_by(commercial_group)

treemap(fish_by_gear_allyears,
        index= c("commercial_group", "common_name"),
vSize="landed_value",
type="index")
