library(shiny)
library(tidyverse)
library(scales)
library(caret)
library(ggplot2)
library(countrycode)
library(plotly)
options(scipen = 999)

covid <- read.csv("WHO-COVID-19-global-data.csv", header = TRUE,
                  fileEncoding="UTF-8-BOM", na.strings=c(""))
pop <- read.csv("API_SP.POP.TOTL_DS2_en_csv_v2_1308146.csv", 
                header = TRUE, skip = 4)
pop2 <- pop %>% select(Country.Code,X2019) %>%
  rename(Population = X2019)

covid$Country_code  <- countrycode(covid$Country_code, origin = "iso2c", destination = "wb") 
covid$Country_code  <- as.character(covid$Country_code)
pop2$Country.Code <- as.character(pop2$Country.Code)
pop2$Population <- as.numeric(pop2$Population)
covid$Date_reported <- as.Date(covid$Date_reported)

shinyServer(function(input, output){

    output$plot1 <- renderPlotly({
      DatesMerge <- input$DatesMerge
      covid <- covid %>% filter(Date_reported == DatesMerge, Country != "Other") %>%
          rename(Date = Date_reported, Country.Name = Country, 
                 Country.Code = Country_code) %>%
          select(Country.Code, Country.Name, Cumulative_cases)
        
      rto <- as.numeric(input$radio)
      
      if(input$radio == '1'){
        rtstring <- "Number of Cases"
      }
      else if(input$radio == '10000') {
        rtstring <- "Cases per 10k People"
      }
      else if(input$radio == '100000') {
        rtstring <- "Cases per 100k People"
      } else {
        rtstring <- "Cases per Million People"
      }

      
      cap <- covid %>% inner_join(pop2) %>% 
        rename(Total.Cases = Cumulative_cases) %>%
        mutate(Case_Ratio = Total.Cases/Population,
               CaseMod = Total.Cases / rto) %>%
        filter(!is.na(Total.Cases))
      
        if(input$params == '1'){
          plot1 <- cap %>% plot_ly(x=~Population, y=~CaseMod,  
                         type = 'scatter', mode = 'markers',
                         text =~Country.Name) %>%
            layout(xaxis = list(title="Population"),
                   yaxis = list(title=rtstring),
                   showlegend = F)
  
          }         
          else{
          plot1 <- cap %>% plot_ly(x=~Population, y=~Case_Ratio,  
                                   type = 'scatter', mode = 'markers',
                                   text =~Country.Name) %>%
            layout(xaxis = list(title="Population"),
                   yaxis = list(title="Cases per Population")) 
          }
      
    })
    
    })