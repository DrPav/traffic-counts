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
road_data_reg <- readRDS("data/rtc-road-aggregated-regional.rds")
road_data_nat <- readRDS("data/rtc-road-aggregated-national.rds")
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
  
  output$roadTable <- renderDataTable({
    if(input$select_region != "National"){
      x <- road_data_reg %>% filter(ONS.GOR.Name == input$select_region) %>%
        filter(RCat == input$select_rcat)
    } else {
      x <- road_data_nat %>% filter(RCat == input$select_rcat)
    }
    x %>% select(Road,
                 Length.km = LenNet,
                 AADF.2015 = avg.AADF.2015) %>%
      mutate(Length.km = round(Length.km, 0),
             AADF.2015 = round(AADF.2015, 0)) %>%
      arrange(desc(Length.km))
                         
  })
  
  
  output$forecastMap <- renderLeaflet({
    leaflet() %>% 
      setView(lat = 53, lng = -2.109, zoom = 6) %>%
      addProviderTiles("CartoDB.Positron")

  })
  
  

  
})
