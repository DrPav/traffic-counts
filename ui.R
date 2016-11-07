#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
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

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  titlePanel("Average Daily Flow Forecats"),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
       selectInput("select_region", "Region", choices = regions),
       selectInput("select_rcat", "Road Type", choices = rcats)
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
       plotOutput("regionPlot"),
       dataTableOutput("roadTable"),
       leafletOutput("forecastMap")
       
    )
  )
))
