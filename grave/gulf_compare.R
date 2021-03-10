library(tidyverse)
library(here)

## Loading in Guld and WC Data

fish <- read_csv(here("west_coast_eez_data", "SAU EEZ 848 v48-0.csv"))
fish_gulf <- read_csv(here("west_coast_eez_data", "SAU EEZ 852 v48-0.csv"))


## We'll join these two df by the column "area_name"

all_fish <- full_join(fish, fish_gulf, by = c("area_name", "area_type", "year", # Do all useful ones!))



# radarchart(fish, axistype=1 ,
#
#             #custom polygon
#             pcol=rgb(0.2,0.5,0.5,0.9) , pfcol=rgb(0.2,0.5,0.5,0.5) , plwd=4 ,
#
#             #custom the grid
#             cglcol="grey", cglty=1, axislabcol="grey", caxislabels=seq(0,20,5), cglwd=0.8,
#
#             #custom labels
#             vlcex=0.8
# )
