#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(leaflet)
library(rgdal)
library(readxl) 
library(DT)
library(dplyr)

library(htmlwidgets)




#Data

plot_schools<-read.csv("https://raw.githubusercontent.com/CodeTheCity/CTC27_CodeMaps/main/Data/Scotland%20Secondary%20School%20Coordinates.csv")
LCA<-readOGR("https://raw.githubusercontent.com/martinjc/UK-GeoJSON/master/json/administrative/sco/lad.json")
codeclubs<-read.csv("https://raw.githubusercontent.com/CodeTheCity/CTC27_CodeMaps/main/Data/Code_clubs.csv", header=TRUE)
teachers<-read.csv("https://raw.githubusercontent.com/CodeTheCity/CTC27_CodeMaps/main/Data/FTE%20by%20School_data.csv", header=TRUE)
school_teachers<-merge(teachers, plot_schools, by.x="School.Name")
teachers2016<- filter(school_teachers, Measure.Names=="2016")
teachers2020<- filter(school_teachers, Measure.Names=="2020")
teachers0<- filter(school_teachers, Measure.Values=="0")

# Define UI for application that draws a histogram
ui <- fluidPage(
   
   # Application title
   titlePanel("Code Maps"),
   
  
      # Show a plot of the maps
      mainPanel(
        leafletOutput("schools", height = "100vh", width="100vh"), 
        hr(),
        fluidRow(  
          column(12, DT::dataTableOutput("codeclub_table"))
        ),
      )
   
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  
  output$schools<-renderLeaflet({
    
    schools<- leaflet() 
    
    
    schools<-setView(schools, lng =-4.1826 , lat = 56.95, zoom = 7)
    #schools<-fitBounds(schools, -0.75, 59.9, -7.59, 55.51)
    
   schools<- addTiles(schools)
   
    
    schools<-addPolygons(schools, data=LCA, stroke = TRUE, group = "Local Authority", color = "black", smoothFactor = 0.3, fillOpacity = 0.1, weight=2,
                         
                         label = ~paste0("Local Authority: ", LAD13NM)) 
    
    
    schools<-addCircles(schools, lat=plot_schools$Latitude,lng =plot_schools$Longitude, label=plot_schools$School, color = "red", group="Secondary")
   
    
    schools<-addCircles(schools, lat=teachers2016$Latitude,lng =teachers2016$Longitude, label=teachers2016$School.Name, color = "blue", group="2016 Teachers")
    
    schools<-addCircles(schools, lat=teachers2020$Latitude,lng =teachers2020$Longitude, label=teachers2020$School.Name, color = "green", group="2020 Teachers")
    
    schools<-addCircles(schools, lat=teachers0$Latitude,lng =teachers0$Longitude, label=teachers0$School.Name, color = "darkblue", group="No Teachers")
    
    
    schools<-addLayersControl(schools, overlayGroups = c(  "Secondary",  "Local Authority", "2016 Teachers", "2020 Teachers", "No Teachers"), options=layersControlOptions(collapsed=FALSE) )
    
   #saveWidget(schools, file="schools.html")
  })
  output$codeclub_table<-DT::renderDataTable(codeclubs, extensions = 'Buttons', options = list(
    dom = 'Blfrtip',
    buttons = c('copy', 'csv', 'excel', 'pdf', 'print')
  ))
  
  


}

# Run the application 
shinyApp(ui = ui, server = server)


