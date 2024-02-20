#TODO: some combinations of temp and wind speed give wind chill values *higher* than the real temperature.  Should probably check for that and replace those with the actual air temp.
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