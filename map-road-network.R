library(rgdal)
library(ggmap)
x <- readOGR("data/road-network/major-roads-link-network2015.shp", 
             layer = "major-roads-link-network2015" ) %>%
  spTransform(CRS("+init=epsg:4326"))

leaflet(x) %>% addTiles() %>%
  addPolylines()