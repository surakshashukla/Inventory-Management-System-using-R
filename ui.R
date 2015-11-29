library(shiny)


shinyUI(fluidPage(
  
  headerPanel(span("Inventory Management System", style = "color:blue")),br(),
  
  
  selectInput(inputId = "product_id", label = h4("Select Product:"),
              c("Washington Berry Juice" = 1,
                "Washington Mango Drink" = 2,
                "Washington Strawberry Drink" = 3,
                "Washington Cream Soda" = 4,
                "Washington Diet Soda" = 5,
                "Washington Cola" = 6,
                "Washington Diet Cola"= 7,
                "Washington Orange Juice" = 8,
                "Washington Cranberry Juice" = 9)), br(),
  
  
  titlePanel(h3(textOutput("product_text"))), br(),
  
  sidebarPanel(
    radioButtons("method", h4( "Forecast Technique: ", style = "color:blue"),
                 c("Naive" = "naive",
                   "Moving Average" = "ma",
                   "Exponential Smoothing" = "es")), 
    br(),
    
    h4("Calculation", style = "color:blue"), br(),
    
    strong(textOutput("lead_time")),br(),
    
    strong(textOutput("safety_stock")),br(),
    
    strong(textOutput("reorder_point")),br(),
    class = 'leftAlign'
  ),
  
  sidebarPanel(
    plotOutput("product_plot"),
    width = 8,
    class = 'leftAlign'
  ),
  
  
  mainPanel(
    
    
    
    tabsetPanel(type = "tabs", 
                tabPanel("Forecast",
                         strong("Naive"),verbatimTextOutput("forecast_naive_output"),
                         strong("Moving Average"),verbatimTextOutput("forecast_sma_output"),
                         strong("Exponential Smoothing"),verbatimTextOutput("forecast_es_output")
                ), 
                tabPanel("Error rates", 
                         strong("Naive"),verbatimTextOutput("forecast_naive_accuracy"),
                         strong("Moving Average"), verbatimTextOutput("forecast_sma_accuracy"),
                         strong("Exponential Smoothing"), verbatimTextOutput("forecast_es_accuracy")
                ), 
                tabPanel("Plots", 
                         plotOutput("naive_plot"),
                         plotOutput("sma_plot"),
                         plotOutput("es_plot"),
                         class = 'rightAlign'), 
                tabPanel("Data",
                         dataTableOutput("product_dataHead")
                )
    )
  )
)
)