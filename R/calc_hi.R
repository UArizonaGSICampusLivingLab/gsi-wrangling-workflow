#' Calculate heat index
#'
#' Calculates heat index in ºF given dry-bulb temperature in ºF and relative
#' humidity using the formula given by the national weather service
#' (https://www.weather.gov/ama/heatindex). This checks that dry-bulb temps are
#' above 80ºF and that the heat index is actually warmer than the dry-bulb temp.
#' If those conditions aren't met, the dry-bulb temp is returned.
#' 
#' @param temp_f temperature in ºF
#' @param rh relative humidity in % (i.e. between 0 and 100)
#'
#' @return numeric vector of heat index temps in ºF
calc_hi <- function(temp_f, rh) {
  
  ## coefficients
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
# calc_hi(95, 80)
# calc_hi(60, 80)
# calc_hi(85, 40)
# calc_hi(85, 80)
