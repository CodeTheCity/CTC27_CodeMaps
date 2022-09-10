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


#Data
academys<-readOGR("https://services5.arcgis.com/0sktPVp3t1LvXc9z/arcgis/rest/services/Academy_School_Catchments/FeatureServer/0/query?outFields=*&where=1%3D1&f=geojson")
rc_schools<-readOGR("https://services5.arcgis.com/0sktPVp3t1LvXc9z/arcgis/rest/services/RC_School_Catchments/FeatureServer/0/query?outFields=*&where=1%3D1&f=geojson")
primary<-readOGR("https://services5.arcgis.com/0sktPVp3t1LvXc9z/arcgis/rest/services/Primary_School_Catchments/FeatureServer/0/query?outFields=*&where=1%3D1&f=geojson")
plot_schools<-read_excel("Aberdeen schools.xlsx")

# Define UI for application that draws a histogram
ui <- fluidPage(
   
   # Application title
   titlePanel("Code Maps"),
   
  
      # Show a plot of the maps
      mainPanel(
        leafletOutput("schools")
      )
   
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  
  output$schools<-renderLeaflet({
    
    schools<- leaflet() 
    
   schools<- addTiles(schools)
   
    schools<-addPolygons(schools, data=academys, stroke = TRUE, group = "Secondary schools", color = "red", smoothFactor = 0.3, fillOpacity = 0.1, weight=1,
                            
                            label = ~paste0("Secondary School catchment: ", NAME)) 
    
    schools<-addPolygons(schools, data=rc_schools, stroke = TRUE, group = "RC Schools", color = "purple", smoothFactor = 0.3, fillOpacity = 0.1, weight=1,
                            
                            label = ~paste0("RC School catchment: ", NAME)) 
    
    schools<-addPolygons(schools, data=primary, stroke = TRUE, group = "Primary Schools", color = "darkmagenta", smoothFactor = 0.3, fillOpacity = 0.1, weight=1,
                            
                            label = ~paste0("Primary School catchment: ", NAME)) 
    
    schools<-addCircles(schools, lat=plot_schools$Latitude,lng =plot_schools$Longitude, label=plot_schools$School, color="red", group="Secondary")
   
    
    schools<-addLayersControl(schools, overlayGroups = c( "Secondary schools", "RC Schools", "Primary Schools", "Secondary", "Primary", "RC", "Private", "Care"), options=layersControlOptions(collapsed=FALSE) )
    
    
  })
  
   
}

# Run the application 
shinyApp(ui = ui, server = server)

