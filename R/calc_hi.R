#' Calculate heat index
#'
#' Calculates heat index in ºC given dry-bulb temperature in ºC and relative
#' humidity using the formula given by the national weather service
#' (https://www.weather.gov/ama/heatindex). This checks that dry-bulb temps are
#' above 80ºF and that the heat index is actually warmer than the dry-bulb temp.
#' If those conditions aren't met, the dry-bulb temp is returned.
#' 
#' @param temp temperature in ºC
#' @param vp vapor pressure in kPa. Used to estimate %RH by `calc_rh()`
#'
#' @return numeric vector of heat index temps in ºF
calc_hi <- function(temp, vp) {
  rh <- calc_rh(vp, temp)
  
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


#' Calcualte relative humidity from vapor pressure
#'
#' This uses an equation from Huang 2018
#' (https://doi.org/10.1175/JAMC-D-17-0334.1) to estimate saturation vapor
#' pressure from temperature and then calculate RH as vapor pressure /
#' saturation vapor pressure.
#' 
#' @param vp_kpa vapor pressure in kPa
#' @param temp_c air temperature in ºC
#'
#' @return numeric vector of %RH values between 0 and 100
calc_rh <- function(vp_kpa, temp_c) {
  vp_s <- ifelse(
    temp_c > 0,
    (exp(34.494 - ((4924.99)/(temp_c + 237.1))))/(temp_c + 105)^1.57 * 0.001,
    (exp(43.494 - (6545.8)/(temp_c + 278)))/(temp_c + 868)^2 * 0.001
  )
  #return:
  100 * vp_kpa/vp_s
}
