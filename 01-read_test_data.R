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

# collapse list of lists to list of data frames
all_df <- 
  readings_all |> 
  map(\(x) list_rbind(x, names_to = "sensor_port")) |> 
  #collapse list of data frames to a single data frame
  list_rbind(names_to = "device_sn") |> 
  #same wrangling as above
  separate_wider_delim(sensor_port, "_", names = c("sensor", "port")) |> 
  mutate(
    port = str_remove(port, "port"),
    datetime = str_remove(datetime, "-07:00$") |> ymd_hms(tz = "America/Phoenix")
  ) |> 
  select(-timestamp_utc, -tz_offset)

# Get file size by # weeks of data ----------------------------------------

ends <- seq(ymd("2023-08-01"), ymd("2023-10-01"), "weeks")[-1]
ends

size <- map2_vec(ends, seq_along(ends), \(end, id) {
  outpath <- withr::local_tempfile()
  all_df |>
    filter(between(datetime, ymd("2023-08-01"), end)) |> 
    write_csv(outpath)
  
  fs::file_size(outpath)
  
})

size

size_df <- tibble(weeks = seq_along(ends), size = size) 

size_df |> 
  ggplot(aes(x = weeks, y = size)) +
  geom_point() +
  geom_line()
# Sure looks linear!

m <- lm(size ~ weeks, data = size_df)
coef(m)

size_fun <- function(weeks) {
  fs::as_fs_bytes(7992.071) + fs::as_fs_bytes(1029945.345)*weeks
}

#1 year
size_fun(weeks = 52)
#51.1M as .csv without joined metadata
