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


dashboardPage(
  dashboardHeader(title = "Traffic Counts"),
  dashboardSidebar(sidebarMenu(
    menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard"),
             menuSubItem("Level 2", tabName = "dashboard2")),
    menuItem("Widgets", tabName = "widgets", icon = icon("th")),
    menuItem("Last tab", tabName = "tab3"),
    sliderInput("sliderInput", "Magnitudes", min(quakes$mag), max(quakes$mag),
                value = range(quakes$mag), step = 0.1)
  )),
  dashboardBody(
    tabItems(
      # First tab content
      tabItem(tabName = "dashboard2",
              h2("Main tab contents"),
              leafletOutput("mainMap"),
              tableOutput("pointData")
      ),
      
      # Second tab content
      tabItem(tabName = "widgets",
              h2("Widgets tab content")
      ),
      tabItem(tabName = "tab3", h2("Final tab"))
    )
  )
)