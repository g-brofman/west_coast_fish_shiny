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
library(palmerpenguins)
library(tidyverse)
library(shinydashboard)
library(shinythemes)
library(hrbrthemes)
library(here)

# -----------------------------------------------------------------
fish <- read_csv(here("west_coast_eez_data","SAU EEZ 848 v48-0.csv")) %>%
    select(4:16)

# species by year, landed value, and gear_type
fish_category_gear <- fish %>%
    group_by(year, common_name, gear_type) %>%
    summarize(landed_value = sum(landed_value))
# -----------------------------------------------------------------

my_theme <- bs_theme(
    bg = "slategray",
    fg = "black",
    primary = "black",
    base_font = font_google("Times")
)


# icons below from: https://fontawesome.com/icons?d=gallery&q=world
# Creating the user interface
ui <- dashboardPage(skin = "blue",
                    dashboardHeader(title = "Fish 4 Life"),
                    dashboardSidebar(
                        sidebarMenu(id = "menu",
                                    menuItem("Home",
                                             tabName = "home_tab",
                                             icon = icon("fas fa-globe")),
                                    menuItem("Home Item 2",
                                             tabName = "test_tab",
                                             icon = icon("fas fa-globe")),
                                    menuItem("Fishermen",
                                             tabName = "fishermen_tab",
                                             icon = icon("fas fa-anchor")),
                                    menuItem("Fish",
                                             tabName = "fish_graph_tab",
                                             icon = icon("fish")))),

                    dashboardBody(
                        fluidPage(theme = my_theme,
                                  h3("Visualizing fish landings on the West Coast"), #header on all tabs
                                  p("Fish tend to have two eyes", #subheader on all tabs
                                    a("What IS a fish exactly?", #subheader on all tabs
                                      href = "https://en.wikipedia.org/wiki/Fish")#end of a
                                  )#end of p
                        ),#end of fluidPage
                        tabItems(
                            # took this next tab from a different example - it's not showing up yet
                            tabItem(tabName = "home_tab",
                                    h3("App description:"),
                                    p("App summary:This application provides visualizations of fish landings within the EEZ of the West Coast of the U.S. Economic Exclusion Zones (EEZs) were implemented in 1983, allowing for nations to hold jurisdiction over natural resources along their coasts (NOAA). The United States exercises sovereign control over a 200 mile width strip of ocean Along California, Oregon, and Washington (there is also an Alaskan EEZ, but is excluded from this app). In this app you can observe visualizations of fish landings by weight and value, gear type, and species from 1950 - 2016"),#end of p
                                    p("Data source: data sets for this application were provided by Sea Around Us, a research initiative which collects fisheries-realted data around the world in an effort to assess the impact of fishereis"), # end of p
                                    img(src = "sea_around_us.png"),
                                    a("Sea Around Us",
                                      href = "http://www.seaaroundus.org/",
                                      align = "center") # end of a
                            ),#end of tabItem1
                            tabItem(tabName = "fishermen_tab",
                                    h3("Fish or not a fish?"),
                                    p("word"),
                                    p("Description blah blah text")#end of p
                            ), # end of tabItem2
                            tabItem(tabName = "test_tab",
                                    h3("other interesting thing"),
                                    p("WOW!"),#end of p
                                    p("Data for this app was provided by Sea Around Us (link here)")#end of p
                            ),#end of tabItem2_b

                            tabItem(tabName = "fish_graph_tab",
                                    fluidRow(
                                        shinydashboard::box(title = "Catch value by method graph",
                                                            selectInput("common_name",
                                                                        label = h4("Choose fish species"),
                                                                        choices = c(unique(fish_category_gear$common_name)#end of unique
                                                                        ),#end of c
                                                                        selected = 1,
                                                                        multiple = FALSE

                                                            ),#end of selectInput
                                                            hr(),
                                                            fluidRow(column(3, verbatimTextOutput("value"))#end o fluidRow
                                                            )),#end of box
                                        shinydashboard::box(plotOutput(outputId = "fish_plot")#end of plotOutput
                                        )#end of box
                                    )#end of fluidRow
                            )#end of tabItem3
                        )#end of tabItems


                    )#end of dashboardBody
)#end of dashboardPage


# -------------------------------------------------------------------------
# Build the server
server <- function(input, output) {


    fish_select <- reactive({
        fish_category_gear %>%
            filter(common_name == input$common_name)#end of filter


    }#end of reactive({})
    )#end of reactive
    # where end of first {} used to be before adding output section

    # Create a reactive plot, which depends on 'species' widget selection:

    output$fish_plot <- renderPlot({

        ggplot(data = fish_select(), aes(x = year, y = landed_value)) +
            geom_point(aes(color = gear_type)) #removed point color aspect

    })

    output$value <- renderPrint({ input$common_name })
} #end of first {} in server



#### End of sort-of-working app






# ---------------------------------------------------------------------------
# Create a reactive plot (this section doesn't work right now)
# running this code causes an error and won't allow the app to run- is it because we don't have the radio buttons like on the earlier version?
# output$fish_plot <- renderPlot({
#
#     ggplot(data = fish_select(), aes(x = year, y = catch_sum)) +
#         geom_point(color = input$pt_color, size = 5)
#
# })

# ---------------------------------------------------------------------------

shinyApp(ui = ui, server = server)

# ---------------------------------------------------------------------------





