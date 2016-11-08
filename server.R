#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(leaflet)
library(dplyr)
library(forecast)
library(ggplot2)
source("helper-func.R")
agg_data <- readRDS("data/rtc-aggregated.rds")
road_data_reg <- readRDS("data/rtc-road-aggregated-regional.rds")
road_data_nat <- readRDS("data/rtc-road-aggregated-national.rds")
cords_meta <- readRDS("data/count-point-meta.rds") %>% filter(RCat == "PU")
cords_data <- readRDS("data/count-point-data.rds") %>% filter(CP %in% cords_meta$CP)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
   
  clickedPoint <- reactive({
    x <- input$mainMap_marker_click
    
    # f = (cords_meta$lat == x["lat"]) & (cords_meta$long == x["lng"])
    # cords_meta[f, ]
    
    #cords_meta %>% filter(CP == x["id"]) #%>% inner_join(cords_data, by = "CP")
    y <- cords_meta[cords_meta$CP == x["id"],] %>% 
      select(CP, Region = ONS.GOR.Name, Authority = ONS.LA.Name, RCat, A.Junction, B.Junction)
    y
  })
  
  clickedPointData <- reactive({
    x <- input$mainMap_marker_click

    cords_data[cords_data$CP == x["id"], c("AADFYear", "FdAll_MV")] %>% 
      select(Year = AADFYear, AADF = FdAll_MV)
  })
  
  # filteredData <- reactive({
  #   quakes[quakes$mag >= input$sliderInput[1] & quakes$mag <= input$sliderInput[2],]
  # })
  
  
  output$mainMap <- renderLeaflet({
    leaflet() %>%
      addTiles() %>%
      addMarkers(data = cords_meta, ~long, ~lat, popup = ~as.character(Road),
                 layerId = ~CP, clusterOptions = markerClusterOptions(maxZoom = 13))
  })
  
  # observe({
  #   x <- filteredData()
  # 
  #   leafletProxy("mainMap") %>%
  #     clearMarkerClusters() %>%
  #     addMarkers(data = x, ~long, ~lat, popup = ~as.character(mag),
  #                clusterOptions = markerClusterOptions())
  # 
  # })
  
  observe({
    x <- clickedPoint()
    output$pointData <- renderTable(x)
  })
  
  output$countPlot <- renderPlot({
    ggplot(clickedPointData(), aes(Year, AADF)) + geom_line(size = 1) + theme_minimal()
  })
  
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
    
  }, options = list(pageLength = 4))
  
  
})
