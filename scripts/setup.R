
#----------------------------------------------------------
# SETUP
#----------------------------------------------------------


# Clear all
rm(list=ls())

# Packages

# Suomen kartat
  library(geofi)
# Tilastokeskuksen data
  library(pxweb)
# Sotkanetin data
  library(sotkanet)
# Paljon erilaista tavaraa
  library(tidyverse)
  library(dplyr)
  library(tidyr)
# Data table
  library(data.table)
# Koordinaattimuunnokset
  library(sp)
# Geocoding: Google Maps
  library(ggmap)
# Geocoding: All possible APIs
  library(tidygeocoder)
# Calculate distances: Google Maps
  library(gmapsdistance)
# Excel export/import
  library(readxl)
  library(writexl)
  library(readr)
# Stata/SAS export/import
  library(haven)
  library(foreign)
# Map themes
  library(ggthemes)
# Data cleaning
  library(janitor)
# Data tables
  library(modelsummary)
  library(kableExtra)
  library(tibble)
  library(smd)
  library(stargazer)    


# Set seed
set.seed(12345)

# Retrieve data and username for folder naming
tag <- paste0(format(Sys.Date(), "%Y-%m-%d"), "-", Sys.info()[["user"]])

# Create folders
# Data
dir.create(here::here("data", tag, "raw"), recursive = TRUE, showWarnings = FALSE)
dir.create(here::here("data", tag, "final"), recursive = TRUE, showWarnings = FALSE)
# Output
dir.create(here::here("output", tag), recursive = TRUE, showWarnings = FALSE)



