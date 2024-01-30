library(httr2)
library(jsonlite)
library(tidyverse)


device_sn <- "z6-19484"
port_num <- 1
# model_type <- "ETo" #other option is ETr, so just hard-coded for now

#Create a request
req <- 
  request("https://zentracloud.com/api/v3") |> 
  req_url_path_append("get_env_model_data") |> 
  req_url_query(
    device_sn = device_sn,
    model_type = "ETo", 
    port_num = port_num, 
    inputs = toJSON(list( #TODO hard code or get from site_info.csv?
      elevation = 3,
      latitude = 32.25,
      wind_measurment_height = 2
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
out_df |> 
  add_column(device_sn = device_sn, port_num = port_num) |> 
  #rename to match other data columns
  rename(
    ETo.value = value,
    ETo.error_flag = error_flag,
    ETo.error_description = error_description
    ) |> 
  #TODO: wrangle datetime in the same way as the rest of the data
  select(device_sn, port_num, datetime, starts_with("ETo"))
  #TODO: will first row always be an error?  If so, remove it

#Then repeat for every device_sn

#TODO create wrangle_response(resp)
#TODO create gsi_get_eto(device_sn) that uses wrangle_response() to output a tibble
#TODO add this to the main workflow so model data gets combined at the appropriate point?  OR add into gsi_get_data()?
