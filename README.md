# The effecs of primary care clinic closures: How older people's geographical distance to care affects their health and service use?

**Authors**: Tuukka Holster, Mika Kortelainen, Marja-Lisa Laukkonen, Konsta Lavaste, Kaisa Palo, Markku Satokangas, Tiina Hetemaa & Vuokko Heikinheimo

**Description**: Scripts that produce supportive data and graphs for a paper studying the effects of health station closures in Finland. The analysis itself is not displayed in this repository because it is performed using confidential data in Statistics Finland's remote access system Fiona.

## Repository structure

```
health_station_closures/
├── scripts/
│   ├── setup.R
│   ├── identifying_closed_stations.R
│   ├── map_closures.R
│   ├── map_all_stations.R
│   └── mun_level_summary_table.R
├── data/
│   ├── raw
│      └── health_stations_Finland.xlsx
│   ├── final
│       └── timestamped folders
├── output/
│   └── timestamped folders
├── README.md
├── health_station_closures.Rproj
├── .here
├── LICENCE
├── master_report.qmd
├── master_report.md
└── .gitignore
```

## Output

TBA

### 1) Identify health station closures, openings and relocations from the health station data

**Script**: identifying_closed_stations.R

**Based on**: Dataset of all health stations in Finland in 2013–2019 (DOI will be added)

### 2) Draw a map of Finland with health station closures and population densities

**Script**: map_closures.R

**Based on**: Spatial data from [Statistics Finland](https://stat.fi/en/services/statistical-data-services/geographic-data), health station closures from the previous step, and health station coordinates from [OpenStreetMap](https://www.openstreetmap.org/).

### 3) Visualise Finnish healthcare system structure and patient pathways with a process chart

**Script**: system_chart.R

**Based on**: TBA

### 4) Create a table of municipality level descriptive characteristics

**Script**: mun_level_summary_table.R

**Based on**: Indicator data from [THL](https://sotkanet.fi/sotkanet/fi/index).

## Replication

TBA

## To do list

TBA.
