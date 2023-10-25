zentracloud::setZentracloudOptions(
  token = Sys.getenv("ZENTRACLOUD_TOKEN"),
  domain = "default"
)
library(zentracloud)
library(tidyverse)
library(fs)

# Read in already saved data ----------------------------------------------

if (file_exists("example_data.csv")) {
  old_dat <- read_csv("example_data.csv")
  prev_end <- max(old_dat$datetime) |> with_tz("America/Phoenix")
} else {
  #this should only have to run the first time or if the file goes missing
  # prev_end <- first_date_on_zentracloud
}


# Download new data -------------------------------------------------------

devices <- c("z6-19484", "z6-20761", "z6-20764", "z6-20762", "z6-20763")

readings_all <- 
  # provide an "anonymous function" to map() to iterate over `devices`
  map(devices, \(x) {
    getReadings(
      device_sn  = x,
      start_time = format(prev_end, "%Y-%m-%d %H:%M:%S"),
      end_time   = format(lubridate::now(), "%Y-%m-%d %H:%M:%S")
    )
  }) |> set_names(devices)

# Wrangling ---------------------------------------------------------------

all_df <- 
  readings_all |> 
  # collapse list of lists to list of data frames
  map(\(x) list_rbind(x, names_to = "sensor_port")) |> 
  # collapse list of data frames to a single data frame
  list_rbind(names_to = "device_sn") |> 
  # some initial data wrangling
  separate_wider_delim(sensor_port, delim = "_", names = c("sensor", "port")) |> 
  mutate(
    port = str_remove(port, "port"),
    datetime = parse_date_time(datetime, orders = "%Y-%m-%d %H:%M:%S%z", exact = TRUE) |> 
      with_tz("America/Phoenix")
  ) |> 
  select(-timestamp_utc, -tz_offset) #redundant columns



# Append saved data -------------------------------------------------------

bind_rows(old_dat, all_df) |> 
  distinct() |> 
  write_csv("example_data.csv")

