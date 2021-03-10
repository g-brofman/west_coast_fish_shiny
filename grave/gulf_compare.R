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
            Reported = sum(Reported, na.rm = TRUE))

summary_2 <- fish_counts_summarized %>%
  group_by(commercial_group, area_name) %>%
  summarize(Unreported = sum(Unreported, na.rm = TRUE),
            Reported = sum(Reported, na.rm = TRUE),
            landed_value = sum(landed_value, na.rm = TRUE),
            tonnes = sum(tonnes, na.rm = TRUE)) %>%
  mutate(percent_reported = Reported/(Reported+Unreported)*100) %>%
  select(commercial_group, area_name, tonnes, landed_value, percent_reported)

# changing to merge
# parallel coordinates plot example

# Libraries
library(tidyverse)
library(hrbrthemes)
library(patchwork)
library(GGally)
library(viridis)

# Data set is provided by R natively
data <- iris

iris_data <- iris

# Plot
data %>%
  ggparcoord(
    columns = 1:4, groupColumn = 5, order = "anyClass",
    showPoints = TRUE,
    title = "Parallel Coordinate Plot for the Iris Data",
    alphaLines = 0.3
  ) +
  scale_color_viridis(discrete=TRUE) +
  theme_ipsum()+
  theme(
    plot.title = element_text(size=10)
  )

summary_factor <- summary_2 %>%
  mutate(commercial_group = as.factor(commercial_group)) %>%
  mutate(area_name = as.factor(area_name))

summary_factor %>%
  ggparcoord(
    columns = 3:5, groupColumn = 2, order = "anyClass",
    showPoints = TRUE,
    title = "Parallel Coordinate Plot for Coastal Data",
    alphaLines = 0.3
  ) +
  scale_color_discrete(c("blue", "red")) +
  theme_ipsum()+
  theme(
    plot.title = element_text(size=10)
  )
