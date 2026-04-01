# The Effects of Primary Care Clinic Closures: How Older People’s
Geographical Distance to Care Affects Their Health and Service Use?
–

# The effects of primary care clinic closures: How older people’s geographical distance to care affects their health and service use?

## Setup

``` r
# Load 'here' package for relative file paths
  library(here)

# Run setup script
  source(here::here("scripts", "setup.R"), echo = FALSE)
```

## Identifying closed stations

Running data to identify health station closures and new station
entries. The data is collected from public sources using Internet
Archive WayBack Machine (DOI will be added).

``` r
# Run script
  source(here::here("scripts", "identifying_closed_stations.R"), echo = FALSE)
```

## Maps

Drawing a map of closed clinics with population density.

Closed health stations are marked with red squares. Population density
is calculated by dividing the population of the postal code area by the
area of the postal code region (km2). To improve map readability,
population density values are truncated at 100 people per square
kilometre—all areas exceeding this threshold are capped at 100,
regardless of their actual density.

``` r
# Running script to draw the maps
  source(here::here("scripts", "map_closures.R"), echo = FALSE)
```

<img src="master_report_files/figure-commonmark/map-1.png"
data-fig-align="center" />

Drawing map of stations closed and opened during the study period
relative to other stations that did not close.

All closed stations are marked with yellow squares, new clinics marked
with purple squares, and others that remain (mostly) in the same
location are marked with green squares.

``` r
# Running script to draw the maps
  source(here::here("scripts", "map_all_stations.R"), echo = FALSE)
```

<img src="master_report_files/figure-commonmark/map2-1.png"
data-fig-align="center" />

<img src="master_report_files/figure-commonmark/map2-2.png"
data-fig-align="center" />

## Municipality level descriptive statistics

Descriptive statistics at municipality level. Treatment (\>1 closure in
municipality) and control (no closures) group mean, standard deviation,
and relative difference.

Source: THL (<https://sotkanet.fi/sotkanet/fi/index>)

``` r
# Running script to make table
  source(here::here("scripts", "mun_level_summary_table.R"), echo = FALSE)
```

## Finnish healthcare system chart: patient pathways

The system chart visualizing the patient pathways, structure and
distribution of visits among the elderly population. Primary care is
provided independently by nurses, GPs, and specialists. Specialised care
is typically provided by specialists assisted by nurses. Shares of the
service use of different subsystems among people aged over 64 years are
from THL (2025):
<https://sampo.thl.fi/pivot/prod/fi/hilmokokonaisuus/kuutio01/fact_hilmokok_kuutio01?row=palvelu-49937&row=palvelusektori-918725&column=ikaluokka-109987&filter=measure-87578&filter=aika-660839>.

``` r
source(here::here("scripts", "system_chart.R"), echo = FALSE)
```
