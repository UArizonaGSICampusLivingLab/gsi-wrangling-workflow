# Load packages and setup -------------------------------------------------
library(tidyverse)
library(zentracloud)

setZentracloudOptions(
  token = Sys.getenv("ZENTRACLOUD_TOKEN"),
  domain = "default"
)


# Read data from all devices ----------------------------------------------

devices <- c("z6-19484", "z6-20761", "z6-20764", "z6-20762", "z6-20763")

readings_all <- 
  # provide an "anonymous function" to map() to iterate over `devices`
  map(devices, \(x) {
    getReadings(
      device_sn = x,
      start_time = "2023-8-01 00:00:00",
      end_time = "2023-10-01 00:00:00"
    )
  }) |> set_names(devices)

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
    datetime = str_remove(datetime, "-07:00$") |>
      ymd_hms(tz = "America/Phoenix")
  ) |> 
  select(-timestamp_utc, -tz_offset) #redundant columns

# Get file size by # weeks of data ----------------------------------------

# This writes out .csv files containing 1, 2, 3, etc. weeks of data and gets the
# file size for each

ends <- seq(ymd("2023-08-01"), ymd("2023-10-01"), "weeks")[-1]
ends

# map2_vec is used here because fs::file_size() returns a special type of vector (class "fs_bytes") that automatically converts from bytes to KB, MB, GB, etc. and I want to keep that instead of making it numeric with map2() or map2_dbl()

size <- map2_vec(ends, seq_along(ends), \(end, id) {
  outpath <- withr::local_tempfile()
  all_df |>
    filter(between(datetime, ymd("2023-08-01"), end)) |> 
    write_csv(outpath)
  
  fs::file_size(outpath)
  
})

size

# put it in a data frame for plotting and modeling purposes

size_df <- tibble(weeks = seq_along(ends), size = size) 

size_df |> 
  ggplot(aes(x = weeks, y = size)) +
  geom_point() +
  geom_line()
# Sure looks linear!

m <- lm(size ~ weeks, data = size_df)
coef(m)

#estimate for a year
weeks <- 52
fs::as_fs_bytes(coef(m)[1]) + fs::as_fs_bytes(coef(m)[2]) * weeks

#51.1M as .csv without joined metadata
