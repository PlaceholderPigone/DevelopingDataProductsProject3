library(shiny)
library(tidyverse)
library(scales)
library(caret)
library(ggplot2)
library(plotly)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  tags$style(type="text/css",
             ".shiny-output-error { visibility: hidden; }",
             ".shiny-output-error:before { visibility: hidden; }"
  ),
    titlePanel("Display of COVID Statistics by Country"),

        sidebarPanel(
            sliderInput("DatesMerge",
                        "Select Date to View:",
                        min = as.Date("2020-01-04","%Y-%m-%d"),
                        max = as.Date("2020-09-12","%Y-%m-%d"),
                        value = as.Date("2020-09-12"),
                        timeFormat="%Y-%m-%d"),

            selectInput("params", "Case Display Format",
                         choices = list("Number of Cases" = '1',
                                        "As Percentage of Population" = '2'), 
                         selected = 1),
            conditionalPanel(
            condition = "input.params == '1'",
            radioButtons("radio", "Choose Case Ratio",
                         choices = list("No Ratio" = 1,
                                        "Per 10k People" = 10000,
                                        "Per 100k People" = 100000,
                                        "Per 1 Million People" = 1000000)
                         ,selected = 1),
            )),
  
        mainPanel(
          plotlyOutput('plot1')
          
        )
    )
)
