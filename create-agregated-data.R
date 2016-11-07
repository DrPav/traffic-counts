#load the data
library(tidyverse)
library(rgdal)
rtc <- read.csv("data/AADF-data-major-roads.csv") 
#Clean some labaelling errors in RCat
rtc$RCat <- as.character(rtc$RCat)
rtc$RCat[rtc$RCat == "Pu"] <- "PU"
rtc$RCat[rtc$RCat == "Tu"] <- "TU"
rtc$RCat <- factor(rtc$RCat)

#Remove the 95 count points with no co-ordinates
rtc <- rtc[!(is.na(rtc$S.Ref.E)),]


#Create a dataset containing AADF aggregated by RCat and region, plus a natinal region
regional_df <- rtc %>% mutate(weighted.AADF = FdAll_MV*LenNet) %>% group_by(AADFYear, RCat, ONS.GOR.Name) %>%
  summarise(LenNet = sum(LenNet), weighted.AADF = sum(weighted.AADF)) %>% ungroup %>%
  mutate(weighted.AADF = weighted.AADF/LenNet)

national_df <- rtc %>% mutate(weighted.AADF = FdAll_MV*LenNet) %>% group_by(AADFYear, RCat) %>%
  summarise(LenNet = sum(LenNet), weighted.AADF = sum(weighted.AADF)) %>% ungroup %>%
  mutate(weighted.AADF = weighted.AADF/LenNet, ONS.GOR.Name = "National")

new_df <- rbind(national_df, regional_df) %>% mutate(ONS.GOR.Name = factor(ONS.GOR.Name))

saveRDS(new_df, "data/rtc-aggregated.rds")

#Road metadata and 2015 average AADF by RCat and Region
rtc %>% mutate(weighted.AADF = FdAll_MV*LenNet) %>% 
  filter(AADFYear == 2015) %>%
  group_by(ONS.GOR.Name, RCat, Road) %>% 
  summarise(LenNet = sum(LenNet), weighted.AADF = sum(weighted.AADF)) %>% 
  ungroup %>% 
  mutate(avg.AADF.2015 = weighted.AADF/LenNet) %>% 
  select(-weighted.AADF) %>%
  arrange(desc(LenNet)) %>%
  mutate(ONS.GOR.Name = factor(ONS.GOR.Name)) %>%
  saveRDS("data/rtc-road-aggregated-regional.rds")

#Road metadata and 2015 average AADF for national selection
rtc %>% mutate(weighted.AADF = FdAll_MV*LenNet) %>% 
  filter(AADFYear == 2015) %>%
  group_by(RCat, Road) %>% 
  summarise(LenNet = sum(LenNet), weighted.AADF = sum(weighted.AADF)) %>% 
  ungroup %>% 
  mutate(avg.AADF.2015 = weighted.AADF/LenNet) %>% 
  select(-weighted.AADF) %>%
  arrange(desc(LenNet)) %>%
  saveRDS("data/rtc-road-aggregated-national.rds")


#Count point metadata
#https://en.wikipedia.org/wiki/Ordnance_Survey_National_Grid
#http://gis.stackexchange.com/questions/48949/epsg-3857-or-4326-for-googlemaps-openstreetmap-and-leaflet#48952
#os code = EPSG:27700
#WGS-84 (EPSG:4326)
cord.osgb <- SpatialPoints(cbind(rtc$S.Ref.E, rtc$S.Ref.N), 
                          proj4string = CRS("+init=epsg:27700"))

cord.wgs84 <- spTransform(cord.osgb, CRS("+init=epsg:4326"))

rtc$lat <- cord.wgs84@coords[,1]
rtc$lon <- cord.wgs84@coords[,2]

rtc %>% filter(AADFYear == 2015) %>%
  select(CP, ONS.GOR.Name, ONS.LA.Name, Road, RCat, lat, lon,
         A.Junction, B.Junction) %>%
  unique %>% 
  mutate(ONS.GOR.Name = factor(ONS.GOR.Name)) %>%
  mutate(ONS.LA.Name = factor(ONS.LA.Name)) %>%
  saveRDS("data/count-point-meta.rds")

#Historic AADF and length data for each count point
rtc %>% select(AADFYear, CP, FdAll_MV, LenNet) %>%
  saveRDS("data/count-point-data.rds")
