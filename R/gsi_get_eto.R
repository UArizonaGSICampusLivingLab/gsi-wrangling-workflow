#' Get data from models endpoint
#'
#' Accesses the zentracloud API models endpoint (documented here:
#' https://zentracloud.com/api/v3/documentation/?) and returns a tibble.  This
#' function works for a single device only and returns data for the previous 30
#' days.
#' 
#' @param device_sn Device ID
#' @param port_num Port number for ATMOS sensor, currently 1 for all sites (this
#'   is the default)
#' @param wind_height Height of wind sensor from ground in meters
#' @param elevation Elevation in meters
#' @param latitude Latitude of device
#'
#' @return a tibble
#' @examples
#' #for Old Main
#' gsi_get_eto(device_sn = "z6-19484", wind_height = 2.1, elevation = 735, latitude = 32.231622)
#' 
gsi_get_eto <- function(device_sn, port_num = 1,  wind_height, elevation, latitude) {
  #Create a request
  req <- 
    request("https://zentracloud.com/api/v4") |> 
    req_url_path_append("get_env_model_data") |> 
    req_url_query(
      device_sn = device_sn,
      model_type = "ETo", #only other option is ETr, so just hard-coded for now
      port_num = port_num, 
      # inputs = '{"elevation": 806, "latitude": 32.25, "wind_measurement_height": 2}'
      inputs = toJSON(list(
        elevation = elevation,
        latitude = latitude,
        wind_measurment_height = wind_height
      ), auto_unbox  = TRUE) #removes [] from length 1 numeric vectors in JSON. Possibly not necessary
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
  
  eto_units <- str_trim(output$data$metadata$units)
  
  #add metadata to data where appropriate
  out_df <- as_tibble(output$data$readings)
  out_final <- out_df |> 
    add_column(device_sn = device_sn, port = port_num, ETo.units = eto_units) |> 
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
