library(boxr)
library(tidyverse)
library(units)
box_auth_service(token_text = Sys.getenv("BOX_TOKEN_TEXT"))
# box_auth() ## If you want to run locally use this instead of box_auth_service()
dir_id <- "233031886906"
box_setwd(dir_id)
#list current files
files <- box_ls() |> as_tibble()

data <- files |> 
  filter(name == "gsi_living_lab_data.csv") |> 
  pull(id) |> 
  box_read(read_fun = readr::read_csv)

data_sample <- data |> 
  slice_sample(n = 100)

# WindChill = (12.1452 + 11.6222 * rad(windspeed) - 1.16222 * windspeed) (33 - T)

windspeed <- 12

# (12.1452 + 11.6222 * sqrt(data$wind_speed.value) - 1.16222 * data$wind_speed.value) * (33 - data$air_temperature.value)
air_temperature.value <- 7.5
wind_speed.value <-  2.16

calc_wind_chill <- function(air_temperature.value, wind_speed.value) {
  
  temp_f <- (air_temperature.value * (9/5)) + 32
  wind_mph <- wind_speed.value * 2.23694
  # message("Original temp in F: ", temp_f)
  
  #NWS version
  chill_f <- 35.74 + 0.6215 * temp_f - 33.75 * wind_mph^0.16 + 0.4275 * temp_f * wind_mph^0.16
  
  # from http://weather.uky.edu/aen599/wchart.htm
  # chill_f <- 0.0817 * (3.71 * sqrt(wind_mph) + 5.81 -0.25 * wind_mph) * (temp_f - 91.4) + 91.4
  chill_c <- (5/9) *(chill_f - 32)
  chill_c
  
}
calc_wind_chill(7.5, 2.16)



data_windchill <-
  data |> 
  mutate(
    wind_chill.value = ifelse(
      air_temperature.value < 10 & wind_speed.value > 1.34112, 
      calc_wind_chill(air_temperature.value, wind_speed.value),
      air_temperature.value
    ) 
  )

data_windchill |> 
  filter(wind_chill.value != air_temperature.value) |> 
  select(wind_chill.value, air_temperature.value, wind_speed.value)


calc_hi <- function(temp_f, rh) {
  
  ## coefficients for ºF
  c1 <- -42.379
  c2 <- 2.04901523
  c3 <- 10.14333127
  c4 <- -0.22475541
  c5 <- -6.83783e-3
  c6 <- -5.481717e-2
  c7 <- 1.22874e-3
  c8 <- 8.5282e-4 
  c9 <- -1.99e-6
  
  heat_index <- 
    c1 + c2*temp_f + c3*rh + c4*temp_f*rh + c5*temp_f^2 + c6*rh^2 +
    c7*temp_f^2*rh + c8*temp_f*rh^2 + c9*temp_f^2*rh^2
  
  #check that heat index is actually hotter and that temp is in appropriate range
  heat_index <-
    ifelse(
      test = heat_index < temp_f | temp_f < 80,
      yes = temp_f,
      no = heat_index
    )
  #return
  heat_index
}
calc_hi(95, 80)
calc_hi(60, 80)
calc_hi(85, 40)
calc_hi(85, 80)
