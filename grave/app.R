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

library(d3Tree)
library(ECharts2Shiny)
library(here)

#hrbrthemes::import_roboto_condensed()

#d fish <- data.table::fread(here("grave", "west_coast_eez_data", "SAU EEZ 848 v48-0.csv"))

#d westcoast_eez_raw <- read_csv(here("grave", "west_coast_eez_data", "SAU EEZ 848 v48-0.csv"))


# -----------------------------------------------------------------
fish <- read_csv(here("west_coast_eez_data","SAU EEZ 848 v48-0.csv")) %>%
    select(4:16)

fish_by_gear <- fish %>%
    select(gear_type, tonnes, landed_value, commercial_group, common_name)

# species by year, landed value, and gear_type
fish_category_gear <- fish %>%
    group_by(year, common_name) %>%
    summarize(landed_value = sum(landed_value))

#fish_category_gear$year <- as.Date(fish_category_gear$year, "%Y")


# -----------------------------------------------------------------


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
                                  h1("Visualizing Fish Landings in the Pacific Coast Region EEZ"), #header on all tabs
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
                                    p("Data source: data sets for this application were provided by Sea Around Us, a research initiative which collects fisheries-realted data around the world in an effort to assess the impact of fishereis"), # end of p
                                    img(src = "eez.jpeg", height = 500),
                                    h4(""),
                                    a("Source: NOAA"),
                                    h4(""),
                                    img(src = "sea_around_us.png"),
                                    h4(""),
                                    a("Sea Around Us",
                                      href = "http://www.seaaroundus.org/",
                                      align = "center") # end of a
                            ),#end of tabItem1

                            tabItem(tabName = "fishermen_tab",
                                    h3("East vs. West Coast EEZ Comparison"),
                                    fluidPage(
                                      shinydashboard::box(plotOutput(outputId = "e_w_plot", height = 300, width = 700)#end of plotOutput
                                                          ), # end of box (where plot will go)
                                      shinydashboard::box(checkboxGroupInput("checkGroup", label = h3("Select fishing sector"),
                                                                         choices = list("Artisanal" = 1, "Industrial" = 2, "Recreational" = 3),
                                                                         selected = 1),

                                                            hr(),
                                                            fluidRow(column(3, verbatimTextOutput("value_tbd")))) #(where radio buttons are specified)



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

                                    ),#end of fluidRow
       p("description here")
                            ),#end of tabItem3

                            tabItem(tabName = "tree_graph_tab",
                                    h3("Descriptive subtitle here"),
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
      h4(""),
   shinydashboard::box(plotOutput(outputId = "fish_tree", width = 600),   #end of plotOutput
   #                     source(file = "treemap.R",
   #                            local = TRUE),    #end of source()
                       ), #end of box
                                    ), #end of fluidRow
   p("description here")
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
    # where end of first {} used to be before adding output section

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




gear_filtered <- reactive({
  fish_by_gear %>%
    filter(gear_type == input$gear_type)
})



    ## Creating a reactive treeplot
    output$fish_tree <- renderPlot({
      fish_tree <- treemap(gear_filtered(),
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
      ) #end of treemap()
       #End onf d3tree3]

    }) ## End of tree plot squiggle brackets.


 #   output$value <- renderPrint({ input$checkGroup })


} # End of server squigglies



#### End of sort-of-working app




# ---------------------------------------------------------------------------

shinyApp(ui = ui, server = server)

# ---------------------------------------------------------------------------





