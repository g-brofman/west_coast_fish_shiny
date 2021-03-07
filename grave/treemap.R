library(tidyverse)
library(here)
library(janitor)
library(shiny)
library(treemap)
library(d3Tree)

## Reading in West Coast fishery data, playing with it.

westcoast_eez_raw <- read_csv(here("grave", "west_coast_eez_data", "SAU EEZ 848 v48-0.csv"))

fish_by_gear <- westcoast_eez_raw %>%
  select(gear_type, tonnes, landed_value, commercial_group, common_name)



fish_tree <- treemap(fish_by_gear,
                     index=c("commercial_group","common_name"),
                     vSize="tonnes",
                     type="index",
                     palette = "Set2",
                     fontsize.labels=c(15,12),
                     fontcolor.labels=c("black","white"),
                     align.labels=list(
                       c("center", "top"),
                       c("center", "bottom")
                     )
)

# interactive_tree <- d3tree(fish_tree)
# interactive_tree
