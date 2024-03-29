#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(bslib)
library(tidyverse)
library(shinydashboard)
library(shinythemes)
library(hrbrthemes)
library(treemap)
library(patchwork)
library(GGally)
library(viridis)
library(fmsb)
library(stats)
library(d3Tree)
library(ECharts2Shiny)
library(here)

#hrbrthemes::import_roboto_condensed()


# -----------------------------------------------------------------
fish_1 <- read_csv(here("west_coast_eez_data","SAU EEZ 848 v48-0.csv")) %>%
    select(4:16)

fish_annual <- fish_1 %>%
  group_by(year, common_name) %>%
  summarize(tonnes = sum(tonnes))

fish_by_gear <- fish_1 %>%
    select(gear_type, tonnes, landed_value, commercial_group, common_name)

# species by year, landed value, and gear_type
fish_category_gear <- fish_1 %>%
    group_by(year, common_name) %>%
    summarize(landed_value = sum(landed_value))

#fish_category_gear$year <- as.Date(fish_category_gear$year, "%Y")

# --------- Code for E vs. W Coast Comparison ---------------------

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
  group_by(commercial_group, area_name, landed_value, tonnes, fishing_sector) %>%
  count(reporting_status) %>%
  pivot_wider(names_from = reporting_status, values_from = n)

fish_counts_summarized <- fish_counts %>%
  group_by(commercial_group, area_name, Unreported, Reported, fishing_sector) %>%
  summarize(landed_value = sum(landed_value, na.rm = TRUE),
            tonnes = sum(tonnes, na.rm = TRUE),
            Unreported = sum(Unreported, na.rm = TRUE),
            Reported = sum(Reported, na.rm = TRUE))

summary_2 <- fish_counts_summarized %>%
  group_by(commercial_group, area_name, fishing_sector) %>%
  summarize(Unreported = sum(Unreported, na.rm = TRUE),
            Reported = sum(Reported, na.rm = TRUE),
            landed_value = sum(landed_value, na.rm = TRUE),
            tonnes = sum(tonnes, na.rm = TRUE)) %>%
  mutate(percent_reported = Reported/(Reported+Unreported)*100) %>%
  select(commercial_group, area_name, tonnes, landed_value, percent_reported, fishing_sector)


summary_factor <- summary_2 %>%
  mutate(commercial_group = as.factor(commercial_group)) %>%
  mutate(area_name = as.factor(area_name)) %>%
  mutate(fishing_sector = as.factor(fishing_sector))

# -------------------end of E vs. W code wrangling------------------------


my_theme <- bs_theme(
    bg = "lightgrey",
    fg = "midnightblue",
    primary = "midnightblue",
    secondary = "yellow",
    base_font = font_google("Times")
)


# icons below from: https://fontawesome.com/icons?d=gallery&q=world
# Creating the user interface
ui <- dashboardPage(skin = "red",
                    dashboardHeader(title = "Display 'o Fish"),
                    dashboardSidebar(
                        sidebarMenu(id = "menu",
                                    menuItem("Home",
                                             tabName = "home_tab",
                                             icon = icon("fas fa-globe")),
                                    menuItem("Fish Species",
                                             tabName = "fish_graph_tab",
                                             icon = icon("fish")),
                                    menuItem("Gear Types",
                                             tabName = "tree_graph_tab",
                                             icon = icon("anchor")),
                                    menuItem("Regional Comparison",
                                             tabName = "fishermen_tab",
                                             icon = icon("ship"))

                                    )),


                    dashboardBody(tags$head(
                      tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")
                    ), #end of tags$head
                        fluidPage(theme = my_theme,
                                  h2("Visualizing Fish Landings within the West Coast Economic Exlcusion Zone") #header on all tabs
                                 # p("Fish tend to have two eyes", #subheader on all tabs
                                  #  a("What IS a fish exactly?", #subheader on all tabs
                                  #    href = "https://en.wikipedia.org/wiki/Fish")#end of a
                                #  )#end of p
                        ),#end of fluidPage

                        tabItems(
                            # took this next tab from a different example - it's not showing up yet
                            tabItem(tabName = "home_tab",
                                    h3("Introduction:"),
                                    p("This interface provides visualizations of fish landings within the EEZ of the West Coast of the U.S. Economic Exclusion Zones (EEZs) were implemented in 1983, allowing for nations to hold jurisdiction over natural resources along their coasts (NOAA). The United States exercises sovereign control over a 200 mile width strip of ocean Along California, Oregon, and Washington (there is also an Alaskan EEZ, but is excluded from this app). In this app you can observe visualizations of fish landings by weight and value, gear type, and species from 1950 - 2016"),#end of p

                                    img(src = "eez.jpeg", height = 500),
                                    h4(""),
                                    a("Source: NOAA"),
                                    h4("Using Display O' Fish:"),
                                    p("
Selecting a tab on the left sidebar will take you to a new page. Each tab contains a different visualization of fish catch trends based on inputs such as timeframe, gear used, and fishing sector. Some tabs produce graphs which may be wider than the page. If you encounter this issue, simply click the main menu button in the top left corner of the red header bar, and the graph width will change to fit your screen."),
                                    h4("Data:"),
                                    p("
Data sets for this application were provided by Sea Around Us, a research initiative which compiles fisheries-related data from around the world in an effort to assess the impact of fisheries. The data sets here contain observations specific to the West and Gulf Coast EEZs, including year, catch by weight and value, species type, fishing method, industry type, catch type (e.g. discard vs. landings), and reporting status."),
                                    h4("Source:"),
                                    p("Pauly D, Zeller D, and Palomares M.L.D. (Editors) (2020) Sea Around Us Concepts, Design and Data (www.seaaroundus.org)"),
                                    h4(""),
                                    img(src = "sea_around_us.png"),
                                    h4(""),
                                    a("Sea Around Us",
                                      href = "http://www.seaaroundus.org/",
                                      align = "center") # end of a
                            ),#end of tabItem1

                            tabItem(tabName = "fishermen_tab",
                                h3("West Coast EEZ vs. Gulf Coast Comparison"),
                                    fluidPage(
                                      shinydashboard::box(plotOutput(outputId = "e_w_plot", width = 1000)#end of plotOutput
                                                          ), # end of box (where plot will go)
                                      shinydashboard::box(radioButtons(
                                        inputId = "sector_choice",
                                        label = "Choose one Fishing Sector",
                                        choices = c("Industrial", "Artisanal", "Recreational"),
                                        selected = "Industrial"),


                                                            hr(),
                                                            fluidRow(column(3, verbatimTextOutput("fishing_sector")))),
                                      p("Select a fishing sector to compare the Gulf Coast and West Coast fisheries. Each line on this graph is a different fish group, like Shrimps or Flatfishes. The Y-axis shows values relative to the other 11 observations, as it accounts for percentage of reported catch, tons landed, and landed value in dollars."), #(where radio buttons are specified)

                                    ) #end of fluidPage
                            ), # end of tabItem2

                            tabItem(tabName = "fish_graph_tab",
                                    h3("Value of fish catch over time"),
                                    fluidRow(
                                        shinydashboard::box(title = "Selection 1", status = "primary", solidHeader = TRUE,
                                                            selectInput("common_name",
                                                                        label = h4("Choose fish species"),
                                                                        choices = c(unique(fish_category_gear$common_name)#end of unique
                                                                        ),#end of c
                                                                        selected = "Coho salmon",
       multiple = FALSE

                                                            ),#end of selectInput
                                                            hr(),
                                                            fluidRow(column(3, verbatimTextOutput("value"))#end of column
                                                            )#end of fluidRow
       ),#end of box

                                        shinydashboard::box(title = "Selection 2", status = "primary", solidHeader = TRUE,
                                                            sliderInput("slider2",
                                                                        label = h4("Select date range"),
                                                                        min = 1950,
                                                                        max = 2016,
                                                                        value = c(1950, 2016)
                                                                        ),#end of sliderInput
                                                            hr(),
                                                            fluidRow(column(3, verbatimTextOutput("range"))#end of column
                                                                     )#end of fluidRow

                                                            ), #end of box

                                        shinydashboard::box(plotOutput(outputId = "fish_plot", height = 300, width = 700)#end of plotOutput
                                        ),#end of box
       h4("second plot title"),
                                        shinydashboard::box(plotOutput(outputId = "fish_plot2", height = 300, width = 700)), #end of plotOutput
       p("Play with different fish-types and year ranges. You'll notice how tons and dollar-values can mirror each other with fish like Coho Salmon, or see major swings with the likes of Arrowtooth Flounder")

# ----------- box 2 will start here
                                    ),#end of fluidRow
                            ),#end of tabItem3


                            tabItem(tabName = "tree_graph_tab",
                                    p("By selecting one gear type, you will see the of fish caught with that gear in a tree map. The size of the rectangles is based on the tons of each fish species caught. Commercial groups of fish are broken up by color."),
                                    fluidRow(
                shinydashboard::box(title = "Fish Catch by Gear",
        selectInput(inputId = "gear_type",
        label = h4("Choose Gear Type:"),
      choices = c(unique(fish_by_gear$gear_type) #end of unique
                     ),#end of c
      multiple = FALSE), #end of selectInput
            hr(),
          fluidRow(column(1)
          # verbatimTextOutput("landed_value")) # changed br to hr, just to see.
                                                            )),#end of box
      img(src = "gillnet.png", height = 210, width = 320),

   shinydashboard::box(plotOutput(outputId = "fish_tree", width = 750)
                       #end of plotOutput
   #                     source(file = "treemap.R",
   #                            local = TRUE),    #end of source()
                       ),#end of box
   p("In the Treemap above, you can see how much of any fish species or fish-group are caught by different fishing gear types. Explore how some gear types bring in diverse fish, while others land a few high-demand species. These figues can show how certain fisheries have been fished over the last half-century, as this data accounts for fish caught between 1950-2016") #end of p

) #end of fluidRow
                            ) #end of tabItem4
                        ) #end of tabItems


                    ) #end of dashboardBody
) #end of dashboardPage


# -------------------------------------------------------------------------
# Build the server
server <- function(input, output) {


    fish_select <- reactive({
        fish_category_gear %>%
            filter(common_name == input$common_name) %>%
            filter(year >= input$slider2[1], year <= input$slider2[2])

    }#end of reactive({})
    )#end of reactive

    # second reactive df for fish tab: fish catch by tons over time

    fish_select2 <- reactive({
      fish_annual %>%
        filter(common_name == input$common_name) %>%
        filter(year >= input$slider2[1], year <= input$slider2[2] )

    }) # end of reactive({})

    # Create a reactive plot, which depends on 'species' widget selection:

    output$fish_plot <- renderPlot({

        ggplot(data = fish_select(), aes(x = year, y = landed_value)) + #should x = input$slider2?
            geom_point(color = "darkblue") +
        geom_smooth(color = "cornflowerblue") +
        theme_minimal() +
        labs(x = "Year",
             y = "Landed Value (USD)",
             title = "Fish catch by landed value over time")

    })
    # second reactive plot, same data
    output$fish_plot2 <- renderPlot({

      ggplot(data = fish_select2(),
             aes(x = year, y = tonnes)) +
        geom_point(color = "red4") +
        geom_smooth(color = "red") +
        theme_minimal() +
        labs(x = "Year",
             y = "Landed Tonnes",
             title = "Fish catch by landed, tons over time")
    })



sector_selected <- reactive({
  summary_factor %>%
    filter(fishing_sector == input$sector_choice)
}) #End or sector_selected





gear_filtered <- reactive({
  fish_by_gear %>%
    filter(gear_type == input$gear_type) %>%
    mutate(Tons = tonnes)
})


output$e_w_plot <- renderPlot({
  sector_selected()  %>%
    ggparcoord(
      columns = 3:5, groupColumn = 2, order = "anyClass",
      showPoints = TRUE,
      title = "Comparing West Coast Fish Landings with the Gulf of Mexico",
      alphaLines = 0.3
    ) +
    scale_color_discrete("#0D0C4D", "darkred") +
    theme_ipsum()+
    theme(
      plot.title = element_text(size=10),
      legend.title = element_blank()) +
    labs(x = "Fishing Variables",
         y = "Relative Scale") +
    scale_x_discrete(labels=c("Percent Reported","Tons Caught","Landed Value (USD)"))


}) # end of of renderPlot squiggles

## Output for radio button (region comparison)
output$txt <- renderText({
  paste("You chose", input$sector_choice)
})



    ## Creating a reactive treeplot
    output$fish_tree <- renderPlot({
      fish_tree <- treemap(gear_filtered(),
                           index=c("commercial_group","common_name"),
                           vSize="Tons",
                           type="index",
                           palette = "Set2",
                           fontsize.labels=c(15,12),
                           fontcolor.labels=c("black","white"),
                           align.labels=list(
                             c("center", "top"),
                             c("center", "bottom"),
                             format.legend = list(scientific = FALSE, big.mark = " ")
                           )
      ) #end of treemap()
       #End onf d3tree3]

    }) ## End of tree plot squiggle brackets.


 #   output$value <- renderPrint({ input$checkGroup })

} # End of server squigglies





# ---------------------------------------------------------------------------

shinyApp(ui = ui, server = server)

# ---------------------------------------------------------------------------





