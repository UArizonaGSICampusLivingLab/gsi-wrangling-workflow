library(httr2)
library(jsonlite)
library(tidyverse)

# Gould Simpson z6-20761 : Lat: 32.2294203 Long: -110.955557 Elevation: 746 m
# Old Main z6-19484: Lat: 32.231622 Long: -110.9537758 Elevation: 735 m
# PAS z6-20762 : Lat: 32.2294215 Long: -110.9541533 Elevation: 741 m


device_sn <- "z6-19484"
port_num <- 1
lat <- 32.231622
elev <- 735
# model_type <- "ETo" #other option is ETr, so just hard-coded for now
gsi_get_eto <- function(device_sn, port_num = 1,  wind_measurement_height = 2, elevation, latitude) {
  #Create a request
  req <- 
    request("https://zentracloud.com/api/v4") |> 
    req_url_path_append("get_env_model_data") |> 
    req_url_query(
      device_sn = device_sn,
      model_type = "ETo", 
      port_num = port_num, 
      # inputs = '{"elevation": 806, "latitude": 32.25, "wind_measurement_height": 2}'
      inputs = toJSON(list( #TODO hard code or get from site_info.csv?
        elevation = elevation,
        latitude = latitude,
        wind_measurment_height = wind_measurement_height
      ), auto_unbox  = TRUE)
    ) |> 
    req_headers(
      Authorization = paste("Token", Sys.getenv("ZENTRACLOUD_TOKEN")),
      accept = "application/json"
    ) |> 
    req_throttle(rate = 1/62) #ridiculously slow API limit
  
  #View the request
  req
  
  #Perform the request
  resp <- req |> 
    req_perform()
  
  #Extract data from the request
  
  output <- resp |> 
    #extremely annoying that response is not JSON like it claims
    resp_body_string() |> 
    #extremely annoying that there are invalid values (unquoted NaN) in the JSON text
    str_replace_all(pattern = 'NaN', replacement = '"NaN"') |> 
    fromJSON()
  
  #add metadata to data where appropriate
  out_df <- as_tibble(output$data$readings)
  out_final <- out_df |> 
    add_column(device_sn = device_sn, port = port_num) |> 
    #rename to match other data columns
    rename(
      ETo.value = value,
      ETo.error_flag = error_flag,
      ETo.error_description = error_description
    ) |> 
    mutate(
      datetime = parse_date_time(datetime, orders = "%Y-%m-%d %H:%M:%S%z", exact = TRUE) |> 
        with_tz("America/Phoenix") |> as_date()
    ) |> 
    select(device_sn, port, datetime, starts_with("ETo"))
  out_final
}
#Then repeat for every device_sn
eto <- gsi_get_eto(device_sn = "z6-19484", elevation = elev, latitude = lat)
eto

#TODO write this as a separate .csv file to Box