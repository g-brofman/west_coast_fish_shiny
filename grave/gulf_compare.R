library(tidyverse)
library(here)
library(fmsb)
library(stats)
library(wesanderson)

## Loading in Guld and WC Data

fish <- read_csv(here("west_coast_eez_data", "SAU EEZ 848 v48-0.csv"))
fish_gulf <- read_csv(here("west_coast_eez_data", "SAU EEZ 852 v48-0.csv"))


## We'll join these two df by the column "area_name"

all_fish <- full_join(fish, fish_gulf, by = c("area_name",
                                              "area_type",
                                              "year",
                                              "common_name",
                                              "functional_group",
                                              "commercial_group",
                                              "fishing_sector",
                                              "reporting_status",
                                              "gear_type",
                                              "tonnes",
                                              "landed_value")) %>%
  select(area_name, area_type, year, common_name, functional_group, commercial_group, fishing_sector, reporting_status, gear_type, tonnes, landed_value)
                                              # Do all useful ones!))


## Below are two lengthy wrangling steps to get two rows for each commercial group of fish. One for each area (Gulf of Mexico, West Coast.) These rows include the percentage reported, tonnes, and landed value.

fish_counts <- all_fish %>%
  group_by(commercial_group, area_name, landed_value, tonnes) %>%
  count(reporting_status) %>%
  pivot_wider(names_from = reporting_status, values_from = n)

fish_counts_summarized <- fish_counts %>%
  group_by(commercial_group, area_name, Unreported, Reported) %>%
  summarize(landed_value = sum(landed_value, na.rm = TRUE),
            tonnes = sum(tonnes, na.rm = TRUE),
            Unreported = sum(Unreported, na.rm = TRUE),
            Reported = sum(Reported, na.rm = TRUE)) %>%
  summarize()

summary_2 <- fish_counts_summarized %>%
  group_by(commercial_group, area_name) %>%
  summarize(Unreported = sum(Unreported, na.rm = TRUE),
            Reported = sum(Reported, na.rm = TRUE),
            landed_value = sum(landed_value, na.rm = TRUE),
            tonnes = sum(tonnes, na.rm = TRUE)) %>%
  mutate(percent_reported = Reported/(Reported+Unreported)*100) %>%
  select(commercial_group, area_name, tonnes, landed_value, percent_reported)

# changing to merge
