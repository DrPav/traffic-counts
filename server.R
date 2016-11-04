#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(ggplot2)
source("helper-func.R")
agg_data <- readRDS("data/rtc-aggregated.rds")
# Define server logic required to draw a histogram
shinyServer(function(input, output) {
   
  output$regionPlot <- renderPlot({
    
    tryCatch({
      f <- doForecast(agg_data, input$select_region, input$select_rcat, 5)
      ggplot(f, aes(x = AADFYear, y = value, ymin = forecast_lower, ymax = forecast_upper)) + 
        geom_ribbon(fill = "grey70") + geom_line(size = 1)  + 
        ggtitle(input$select_region) + theme_minimal()
    }, error = function(e) ggplot())
    
    
  })
  

  
})
