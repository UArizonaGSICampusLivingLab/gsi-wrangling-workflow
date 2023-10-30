gsi_get_data <- 
  function(start, devices = c("z6-19484", "z6-20761", "z6-20764", "z6-20762", "z6-20763")) {

  # Download data -----------------------------------------------------------
  readings_all <- 
    # provide an "anonymous function" to map() to iterate over `devices`
    map(devices, \(x) {
      getReadings(
        device_sn  = x,
        start_time = format(start, "%Y-%m-%d %H:%M:%S"), 
        end_time   = format(lubridate::now(), "%Y-%m-%d %H:%M:%S")
      )
    }) |> set_names(devices)

  # Wrangle data ------------------------------------------------------------
  all_df <- 
    readings_all |> 
    # collapse list of lists to list of data frames
    map(\(x) list_rbind(x, names_to = "sensor_port")) |> 
    # collapse list of data frames to a single data frame
    list_rbind(names_to = "device_sn") |> 
    # some initial data wrangling
    separate_wider_delim(sensor_port, delim = "_", names = c("sensor", "port")) |> 
    mutate(
      port = str_remove(port, "port") |> as.numeric(),
      datetime = parse_date_time(datetime, orders = "%Y-%m-%d %H:%M:%S%z", exact = TRUE) |> 
        with_tz("America/Phoenix")
    ) |> 
    filter(!is.na(sensor)) |> #There are some NAs for `sensor` in some versions of the wrangled data.  This removes them.
    select(-timestamp_utc, -tz_offset) #redundant columns
  
  #return
  all_df
}