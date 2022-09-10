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


# Define UI for application that draws a histogram
ui <- fluidPage(
   
   # Application title
   titlePanel("Code Maps"),
   
  
      # Show a plot of the maps
      mainPanel(
        leafletOutput("schools"), 
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
    
    schools<-setView(schools, lng =-4.1826 , lat = 56.8169, zoom = 8)
    schools<-fitBounds(schools, -0.46991, 60.88658, -7.56539, 54.32438)
    
   schools<- addTiles(schools)
   
    
    schools<-addPolygons(schools, data=LCA, stroke = TRUE, group = "Local Authority", color = "black", smoothFactor = 0.3, fillOpacity = 0.1, weight=2,
                         
                         label = ~paste0("Local Authority: ", LAD13NM)) 
    
    
    schools<-addCircles(schools, lat=plot_schools$Latitude,lng =plot_schools$Longitude, label=plot_schools$School, color="red", group="Secondary")
   
    
    schools<-addLayersControl(schools, overlayGroups = c(  "Secondary",  "Local Authority"), options=layersControlOptions(collapsed=FALSE) )
    
   #saveWidget(schools, file="schools.html")
  })
  output$codeclub_table<-DT::renderDataTable(codeclubs, extensions = 'Buttons', options = list(
    dom = 'Blfrtip',
    buttons = c('copy', 'csv', 'excel', 'pdf', 'print')
  ))
  
  


}

# Run the application 
shinyApp(ui = ui, server = server)


