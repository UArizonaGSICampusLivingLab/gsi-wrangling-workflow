library(boxr)
library(tidyverse)
library(units)

source("R/calc_hi.R")
source("R/calc_wind_chill.R")
# get data to test with ---------------------------------------------------
box_auth_service(token_text = Sys.getenv("BOX_TOKEN_TEXT"))
# box_auth() ## If you want to run locally use this instead of box_auth_service()
dir_id <- "250527085917"
box_setwd(dir_id)
#list current files
files <- box_ls() |> as_tibble()

data <- files |> 
  filter(name == "gsi_living_lab_data.csv") |> 
  pull(id) |> 
  box_read(read_fun = readr::read_csv)

site_info <- files |> 
  filter(name == "site_info.csv") |>
  pull(id) |>
  box_read(read_fun = readr::read_csv)

data_full <- left_join(data, site_info)

# Add adjusted temp column to hourly data
df_adj <- data_full |> 
  mutate(
    feels_like.value = calc_hi(air_temperature.value, relative_humidity.value) |> 
      calc_wind_chill(wind_speed.value) |>
      round(digits = 1) #same number of digits as input temp
  )

#how many dates have adjusted temps that don't match the real temp?
df_adj |> 
  select(datetime, air_temperature.value, feels_like.value) |> 
  filter(air_temperature.value != feels_like.value) |> 
  count(date(datetime)) |> nrow()
#63

#plot it!
df_adj |> 
  filter(air_temperature.value != feels_like.value) |> 
  ggplot(aes(x = air_temperature.value, y = feels_like.value, color = site)) +
  geom_point(alpha = 0.6) +
  geom_abline()

df_adj |> count(site)

#Which sites get wind chill the most?
df_adj |> 
  filter(feels_like.value < air_temperature.value) |> 
  count(site)
#mostly Gould Simpson that gets the wind chill!

#Which sites feel hotter than they are?
df_adj |> 
  filter(feels_like.value > air_temperature.value) |> 
  count(site)
#mostly Old Main that feels hotter than it is
