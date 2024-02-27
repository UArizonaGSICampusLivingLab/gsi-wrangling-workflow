#' Calculate heat index
#'
#' Calculates heat index in ºC given dry-bulb temperature in ºC and relative
#' humidity using the formula given by the national weather service
#' (https://www.weather.gov/ama/heatindex). This checks that dry-bulb temps are
#' above 80ºF and that the heat index is actually warmer than the dry-bulb temp.
#' If those conditions aren't met, the dry-bulb temp is returned.
#' 
#' @param temp temperature in ºC
#' @param rh the realative_humidity.value column, RH between 0 and 1
#'
#' @return numeric vector of heat index temps in ºF
calc_hi <- function(temp, rh) {
  #convert RH to 0-100
  rh <- rh*100
  
  ## coefficients for ºC (from https://en.wikipedia.org/wiki/Heat_index)
  c1 <- -8.78469475556
  c2 <- 1.61139411
  c3 <- 2.33854883889
  c4 <- -0.14611605
  c5 <- -0.012308094
  c6 <- -0.0164248277778
  c7 <- 2.211732e-3
  c8 <- 7.2546e-4
  c9 <- -3.582e-6
  
  heat_index <- 
    c1 + c2*temp + c3*rh + c4*temp*rh + c5*temp^2 + c6*rh^2 +
    c7*temp^2*rh + c8*temp*rh^2 + c9*temp^2*rh^2
  
  #check that heat index is actually hotter and that temp and RH are in appropriate range
  heat_index <-
    ifelse(
      test = heat_index < temp | temp < 26.667 | rh < 40,
      yes = temp,
      no = heat_index
    )
  #return
  heat_index
}

