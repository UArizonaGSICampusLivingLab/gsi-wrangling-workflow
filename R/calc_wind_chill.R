#' Calculate wind chill temperature
#'
#' Uses the national weather service equation
#' https://www.weather.gov/media/epz/wxcalc/windChill.pdf. If calculated wind
#' chill is greater than the real temperature, the real temperature is used. If
#' the temperature is ≥ 50ºF and or wind speed is ≤ 3mph, then wind chill is not
#' calculated and the real temperature is returned.
#' 
#' @param temp_f temperature in ºF
#' @param wind_mph wind speed in miles per hour
#'
#' @return numeric vector of wind chill temps
calc_wind_chill <- function(temp_f, wind_mph) {
  
  #NWS version
  chill_f <- 35.74 + 0.6215 * temp_f - 33.75 * wind_mph^0.16 + 0.4275 * temp_f * wind_mph^0.16
  
  # from http://weather.uky.edu/aen599/wchart.htm
  # chill_f <- 0.0817 * (3.71 * sqrt(wind_mph) + 5.81 -0.25 * wind_mph) * (temp_f - 91.4) + 91.4
  
  #check that chill_f is actually chillier and that temp and wind speed are in appropriate range
  chill_f <- ifelse(
    test =  chill_f > temp_f | temp_f >= 50 | wind_mph <= 3,
    yes = temp_f,
    no = chill_f
  )
  #return:
  chill_f
}

# calc_wind_chill(45, 4)
# calc_wind_chill(30, 5)
