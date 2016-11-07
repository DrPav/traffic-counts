#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shinydashboard)
library(leaflet)
data(quakes)


dashboardPage(title = "Traffic counts app",
  dashboardHeader(title = "Traffic Counts"),
  dashboardSidebar(sidebarMenu(
    menuItem("Count Points", tabName = "trafficCounts", icon = icon("car")),
    menuItem("Regional Forecast", tabName = "forecasts", icon = icon("line-chart")),
    sliderInput("sliderInput", "Magnitudes", min(quakes$mag), max(quakes$mag),
                value = range(quakes$mag), step = 0.1)
  )),
  dashboardBody(
    tabItems(
      # First tab content
      tabItem(tabName = "trafficCounts",
              h2("Main tab contents"),
              leafletOutput("mainMap"),
              tableOutput("pointData")
      ),
      
      # Second tab content
      tabItem(tabName = "forecasts",
              h2("The forecast tab from the other app")
      ),
      tabItem(tabName = "tab3", h2("Final tab"))
    )
  )
)