#helper function
#take data for given road and RCat type
#Generate forecast
#return a dataframe of the forecast+historic in a tidy format


doForecast <- function(agg_data, selected_region, selecetd_RCat, forecast_years){
  #forecast_years is a numeric (number of years to forecast)
  #agg_data is located in data folder
  #selected_region and selected_RCat are strings to select from the data frame
  
  require(tidyverse)
  require(forecast)
  
  filtered_data <- agg_data %>% filter(ONS.GOR.Name == selected_region, RCat == selecetd_RCat, AADFYear != 2000) %>%
    arrange(AADFYear)
  
  #Some error handling
  #Return NA if there is missing or not enough data for forecasting
  if(nrow(filtered_data) < 5) return(NA)
  first_year <- min(filtered_data$AADFYear, na.rm = T)
  last_year <- max(filtered_data$AADFYear, na.rm = T)
  if(last_year != 2015) return(NA)
  if(last_year - first_year != nrow(filtered_data) - 1) return(NA)
  if(length(unique(filtered_data$AADFYear)) != nrow(filtered_data)) return(NA)
  
  future_years <- seq(from = last_year + 1, length.out = forecast_years)
  f_arima <- auto.arima(filtered_data$weighted.AADF) %>% 
    forecast(forecast_years)
  
  forecast_results <- data.frame(AADFYear = future_years,
                                 forecast_middle = as.numeric(f_arima$mean),
                                 forecast_upper = f_arima$upper[,"95%"],
                                 forecast_lower = f_arima$lower[,"95%"])
  
  # #Join up the historic and forecast
  # a <- filtered_data %>% select(AADFYear, value = weighted.AADF) %>% mutate(key = "historic")
  # b <- forecast_results %>% gather(key, value, forecast_middle, forecast_upper, forecast_lower) 
  # c<- data.frame(AADFYear = c(2015, 2015, 2015), value = rep(a$value[a$AADFYear == 2015], 3),
  #                key = c("forecast_middle", "forecast_upper", "forecast_lower"))
  # d <- rbind(b,c)
  # e <- rbind(a,d) %>% mutate(key = factor(key))
  
  a <- filtered_data %>% select(AADFYear, value = weighted.AADF) %>% 
    mutate(forecast_upper = value, forecast_lower = value)
  b <- forecast_results %>% rename(value = forecast_middle)
  c <- rbind(a,b)
  
  return(c)
}






