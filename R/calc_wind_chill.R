#TODO: some combinations of temp and wind speed give wind chill values *higher* than the real temperature.  Should probably check for that and replace those with the actual air temp.
calc_wind_chill <- function(temp_f, wind_mph) {
  
  #NWS version
  chill_f <- 35.74 + 0.6215 * temp_f - 33.75 * wind_mph^0.16 + 0.4275 * temp_f * wind_mph^0.16
  
  # from http://weather.uky.edu/aen599/wchart.htm
  # chill_f <- 0.0817 * (3.71 * sqrt(wind_mph) + 5.81 -0.25 * wind_mph) * (temp_f - 91.4) + 91.4
  
  #check that chill_f is actually chillier.  If it isn't, just use the real temperature
  
  chill_f <- ifelse(chill_f > temp_f, temp_f, chill_f)
  
  #return:
  chill_f
}

# calc_wind_chill(45, 4)
# calc_wind_chill(30, 5)
