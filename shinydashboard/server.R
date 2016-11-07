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
library(magrittr)
data(quakes)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
   
  clickedPoint <- reactive({
    x <- input$mainMap_marker_click
    
    f = (quakes$lat == x["lat"]) & (quakes$long == x["lng"])
    quakes[f, ]
  })
  
  filteredData <- reactive({
    quakes[quakes$mag >= input$sliderInput[1] & quakes$mag <= input$sliderInput[2],]
  })
  
  
  output$mainMap <- renderLeaflet({
    leaflet() %>%
      addProviderTiles("CartoDB.Positron") %>%
      addMarkers(data = quakes, ~long, ~lat, popup = ~as.character(mag),
                 clusterOptions = markerClusterOptions())
      
  })
  
  observe({
    x <- filteredData()

    leafletProxy("mainMap") %>%
      clearMarkerClusters() %>%
      addMarkers(data = x, ~long, ~lat, popup = ~as.character(mag),
                 clusterOptions = markerClusterOptions())

  })
  
  observe({
    x <- clickedPoint()
    output$pointData <- renderTable(x)
  })
  
  
})
