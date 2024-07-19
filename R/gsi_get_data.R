# getReadings() errors when there is no data returned, but I'd rather it return an empty tibble, so I'll wrap it here.  See: https://gitlab.com/meter-group-inc/pubpackages/zentracloud/-/issues/44
my_getReadings <- function(...) {
  tryCatch(
    error = function(cnd) {
      if (stringr::str_detect(as.character(cnd), "The API does not return any data")) {
        warning(simpleWarning(conditionMessage(cnd)))
        return(NULL)
      } else {
        stop(cnd)
      }
    },
    zentracloud::getReadings(...)
  )
}

# Occasionally the API returns a "429 - Too Many Requests" error despite rate limiting being built into getReadings(), so we create a version that will retry on *that* error
insistent_getReadings <- 
  purrr::insistently(my_getReadings,
                     rate = rate_backoff(
                       pause_cap = 90,
                       max_times = 8,
                     ), 
                     quiet = FALSE)

gsi_get_data <- 
  function(start, end = NULL, devices = c("z6-19484", "z6-19485", "z6-20761", "z6-20764", "z6-20762", "z6-20763")) {

    if (is.null(end)) {
      end <- lubridate::now()
    } else {
      stopifnot(inherits(end, c("POSIXct", "Date")))
    }
    
  # Download data -----------------------------------------------------------
  
  readings_all <- 
    # provide an "anonymous function" to map() to iterate over `devices`
    purrr::map(devices, \(x) {
      insistent_getReadings(
        device_sn  = x,
        start_time = format(start, "%Y-%m-%d %H:%M:%S"), 
        end_time   = format(end, "%Y-%m-%d %H:%M:%S")
      )
    }) |> 
    purrr::set_names(devices) |> 
    purrr::compact() #get rid of NULLs for when some sensors return no data

  # and if all the sensors return no data, just return an empty tibble
  if (length(readings_all) == 0) {
    return(tibble())
  }
  # Wrangle data ------------------------------------------------------------
  all_df <- 
    readings_all |> 
    # collapse list of lists to list of data frames
    purrr::map(\(x) purrr::list_rbind(x, names_to = "sensor_port")) |> 
    # collapse list of data frames to a single data frame
    purrr::list_rbind(names_to = "device_sn") |> 
    # some initial data wrangling
    tidyr::separate_wider_delim(sensor_port, delim = "_", names = c("sensor", "port")) |> 
    mutate(
      port = stringr::str_remove(port, "port") |> as.numeric(),
      datetime = lubridate::parse_date_time(datetime, orders = "%Y-%m-%d %H:%M:%S%z", exact = TRUE) |> 
        with_tz("America/Phoenix")
    ) |> 
    dplyr::filter(!is.na(sensor)) |> #There are some NAs for `sensor` in some versions of the wrangled data.  This removes them.
    dplyr::select(-timestamp_utc, -tz_offset) #redundant columns
  
  #return
  all_df
}