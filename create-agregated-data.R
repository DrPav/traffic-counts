#load the data
library(tidyverse)
library(forecast)
rtc <- read.csv("data/AADF-data-major-roads.csv") 
#Clean some labaelling errors in RCat
rtc$RCat <- as.character(rtc$RCat)
rtc$RCat[rtc$RCat == "Pu"] <- "PU"
rtc$RCat[rtc$RCat == "Tu"] <- "TU"
rtc$RCat <- factor(rtc$RCat)


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
  arrange(desc(LenNet)) %>%
  mutate(ONS.GOR.Name = factor(ONS.GOR.Name)) %>%
  saveRDS("data/rtc-road-aggregated.rds")

#Count point metadata
rtc %>% filter(AADFYear == 2015) %>%
  select(CP, ONS.GOR.Name, ONS.LA.Name, Road, RCat, S.Ref.E, S.Ref.N,
         A.Junction, B.Junction, LenNet, FdAll_MV) %>%
  unique %>% 
  mutate(ONS.GOR.Name = factor(ONS.GOR.Name)) %>%
  mutate(ONS.LA.Name = factor(ONS.LA.Name)) %>%
  saveRDS("data/count-point-meta.rds")

#Historic AADF data for each count point
rtc %>% select(AADFYear, CP, FdAll_MV) %>%
  saveRDS("data/count-point-data.rds")
