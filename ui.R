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
rcats <- list("Trunk motorway" =  "TM", 
              "Principal motorway" =  "PM", 
              "Urban trunk road" = "TU",
              "Urban principal road" = "PU",
              "Rural trunk road" =  "TR", 
              "Rural principal road" = "PR"
)

regions <- c("National", 
             "East Midlands",
             "East of England",
             "London",
             "North East",
             "North West",
             "Scotland",
             "South East",
             "South West",
             "Wales",
             "West Midlands",
             "Yorkshire and The Humber"
)


dashboardPage(title = "Traffic counts app",
  dashboardHeader(title = "Traffic Counts"),
  dashboardSidebar(sidebarMenu(
    sidebarSearchForm(textId = "searchText", buttonId = "searchButton",
                      label = "Search..."),
    menuItem("Count Points", tabName = "trafficCounts", icon = icon("car")),
    menuItem("Regional Forecast", tabName = "forecasts", icon = icon("line-chart"))
  )),
  dashboardBody(
    tabItems(
      # First tab content
      tabItem(tabName = "trafficCounts",
              h2("Traffic count points"),
              leafletOutput("mainMap"),
              tableOutput("pointData"),
              plotOutput("countPlot"),
              downloadButton("downloadButton", label = "Download")
      ),
      
      # Second tab content
      tabItem(tabName = "forecasts",
              h2("Regional Forecasts"),
              fluidRow(
                box(
                  selectInput("select_region", "Region", choices = regions),
                  selectInput("select_rcat", "Road Type", choices = rcats)
                ),
                box(dataTableOutput("roadTable"))
              ),
              fluidRow(
                box(plotOutput("regionPlot"), width = 12)
              )
      ),
      tabItem(tabName = "tab3", h2("Final tab"))
    )
  )
)