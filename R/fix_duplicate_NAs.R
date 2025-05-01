# Discovered there are duplicate entries in the data on box that occur when a value is initially NA and then was later updated on the zentracloud API.  Because new data was appended rather than joined, the NAs were not replaced.  This script is a one-time fix for these NAs.


# Load packages -----------------------------------------------------------

library(boxr)
library(jose)
# library(tidyverse)
library(dplyr)


# Authorize to box --------------------------------------------------------

box_auth_service(token_text = Sys.getenv("BOX_TOKEN_TEXT"))
# box_auth() ## If you want to run locally use this instead of box_auth_service()
dir_id <- "250527085917"
box_setwd(dir_id)
#list current files
files <- box_ls() |> as_tibble()


# Download existing data --------------------------------------------------

old_dat <- files |> 
  filter(name == "gsi_living_lab_data.csv") |> 
  pull(id) |> 
  box_read(read_fun = readr::read_csv)


# How many such duplicates are there? -------------------------------------

dupes <- old_dat |> 
  group_by(device_sn, sensor, port, datetime) |> 
  count() |> 
  filter(n > 1)
nrow(dupes)


# Filter old data ---------------------------------------------------------

fixed <- old_dat |> 
  distinct() |> 
  #how many rows for each sensor, port, datetime combination?
  mutate(n = n(), .by = c(device_sn, sensor, port, datetime)) |> 
  #keep entries where there is only one row or if there is more than one row and the entries aren't all NAs
  filter(n == 1 | (n == 2 & !if_all(y_axis_level.value:matric_potential.error_description, is.na))) |> 
  select(-n)

#The difference should be equal to the number of duplicate rows calculated above
nrow(old_dat) - nrow(fixed) == nrow(dupes)

# Write data to box -------------------------------------------------------

box_write(fixed, "gsi_living_lab_data.csv", write_fun = readr::write_csv)

