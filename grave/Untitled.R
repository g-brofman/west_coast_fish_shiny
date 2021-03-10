fish_category_gear %>%
  filter(common_name == input$common_name) %>%
  filter(year == c(input$slider1:input$slider2))


# for radio buttons:
# ui:

fluidPage(

  radioButtons("radio", label = h3("Select reporting status"),
               choices = list("Reported" = 1, "Unreported" = 2, "All" = 3),
               selected = 1),

  hr(),
  fluidRow(column(3, verbatimTextOutput("value")))

  # something like:

  shinydashboard::box(plotOutput(outputId = "e_w_plot", height = 300, width = 700)#end of plotOutput
  )#end of box
)#end of fluidRow
),#end of tabItem3


)

# server:

function(input, output) {

  # You can access the values of the widget (as a vector)
  # with input$radio, e.g.
  output$value <- renderPrint({ input$radio })


  # output$value will say output$plot_name (e.g. e_w_plot)
  # use renderPlot({ ggplot info here from reactive df  })

}






