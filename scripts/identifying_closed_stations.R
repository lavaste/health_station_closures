
#----------------------------------------------------------
# IMPORT DATA FROM EXCEL
#----------------------------------------------------------

#----------------------------------------------------------
# CHECK WHICH HEALTH STATIONS WERE CLOSED DOWN AND WHICH WERE OPENED
#----------------------------------------------------------

#Import the data from excel
stations_2013 <- read_excel("original_data/health_stations_Finland_13-19.xlsx","2013",col_names =TRUE,na="",range = cell_cols("A:V"))
stations_2014 <- read_excel("original_data/health_stations_Finland_13-19.xlsx","2014",col_names =TRUE,na="",range = cell_cols("A:V"))
stations_2015 <- read_excel("original_data/health_stations_Finland_13-19.xlsx","2015",col_names =TRUE,na="",range = cell_cols("A:V"))
stations_2016 <- read_excel("original_data/health_stations_Finland_13-19.xlsx","2016",col_names =TRUE,na="",range = cell_cols("A:V"))
stations_2017 <- read_excel("original_data/health_stations_Finland_13-19.xlsx","2017",col_names =TRUE,na="",range = cell_cols("A:V"))
stations_2018 <- read_excel("original_data/health_stations_Finland_13-19.xlsx","2018",col_names =TRUE,na="",range = cell_cols("A:V"))
stations_2019 <- read_excel("original_data/health_stations_Finland_13-19.xlsx","2019",col_names =TRUE,na="",range = cell_cols("A:V"))

#Select rows
stations_2013 <- select(stations_2013,station,address,postcode,municipality,municipality_num,outsourced)
stations_2014 <- select(stations_2014,station,address,postcode,municipality,municipality_num,outsourced)
stations_2015 <- select(stations_2015,station,address,postcode,municipality,municipality_num,outsourced)
stations_2016 <- select(stations_2016,station,address,postcode,municipality,municipality_num,outsourced)
stations_2017 <- select(stations_2017,station,address,postcode,municipality,municipality_num,outsourced)
stations_2018 <- select(stations_2018,station,address,postcode,municipality,municipality_num,outsourced)
stations_2019 <- select(stations_2019,station,address,postcode,municipality,municipality_num,outsourced)

#Add year
stations_2013$year <- 2013
stations_2014$year <- 2014
stations_2015$year <- 2015
stations_2016$year <- 2016
stations_2017$year <- 2017
stations_2018$year <- 2018
stations_2019$year <- 2019

#Append
stations <- rbind(stations_2013,stations_2014,stations_2015,stations_2016,stations_2017,stations_2018,stations_2019)
rm(stations_2013,stations_2014,stations_2015,stations_2016,stations_2017,stations_2018,stations_2019)

#Modifications
#Särkänkuja 5 in Länkipohja is nowadays Aallontie 5
stations$address <- ifelse(stations$address=="address 5","Aallontie 4",stations$address)
#Kauppakuja in Liperi is nowadays Kauppatie
stations$address <- ifelse(stations$address=="Kauppakuja 4", "Kauppatie 4", stations$address)
#Opinraitti is nowadays Koulutie
stations$address <- ifelse(stations$address=="Opinraitti 9", "Koulutie 9", stations$address)
#Juankoski is nowadays part of Kuopio
stations$municipality <- ifelse(stations$municipality=="Juankoski", "Kuopio", stations$municipality)
#Hämeenkoski merged to Hollola
stations$municipality <- ifelse(stations$municipality=="Hämeenkoski", "Hollola", stations$municipality)
#Lavia merged to Pori
stations$municipality <- ifelse(stations$municipality=="Lavia", "Pori", stations$municipality)
#Luvia merged to Eurajoki
stations$municipality <- ifelse(stations$municipality=="Luvia", "Eurajoki", stations$municipality)
#Maaninka merged to Kuopio
stations$municipality <- ifelse(stations$municipality=="Maaninka", "Kuopio", stations$municipality)
#Nastola merged to Lahti
stations$municipality <- ifelse(stations$municipality=="Nastola", "Lahti", stations$municipality)
#Tarvasjoki merged to Lieto
stations$municipality <- ifelse(stations$municipality=="Tarvasjoki", "Lieto", stations$municipality)
#Köyliö merged to Säkylä
stations$municipality <- ifelse(stations$municipality=="Köyliö", "Säkylä", stations$municipality)

#Mansikkalan hyvinvointiasema used to be Mansikkalan terveysasema 
stations$station <- ifelse(stations$station=="Mansikkalan terveysasema","Mansikkalan hyvinvointiasema", stations$station)
#Name changes in Tampere are due to outsourcing
stations$station <- ifelse(stations$station=="Ison Omenan terveysasema", "Oma Lääkärisi Iso Omena", stations$station)
stations$station <- ifelse(stations$station=="Puolarmetsän terveysasema", "Oma Lääkärisi Puolarmetsä", stations$station)
#Lahti: changing the names so closures/openings will be easier to identify later
stations$station <- ifelse(stations$station=="Keskustan terveysasema (Lahti)", "Keskustan lähiklinikka 1 (Lahti)", stations$station)
stations$station <- ifelse(stations$station=="Keskustan lähiklinikka (Lahti)", "Keskustan lähiklinikka 2 (Lahti)", stations$station)
#Kolpin ja Ähtävän terveysasemat yhdistyvät ja Kolpin terveysaseman nimi muuttuu Ähtävän-Kolpin terveysasemaksi, osoite ei muutu
stations$station <- ifelse(stations$station=="Kolpin terveysasema", "Ähtävän-Kolpin terveysasema", stations$station)

#Add complete address
stations$full_address <- paste0(stations$address,", ",stations$postcode," ",stations$municipality,", Finland")
stations <- select(stations,-address,-postcode)


#Calculate the number of observations per address
temp_add <- stations %>% 
  group_by(full_address) %>%
  summarise(n_add = n())

#Calculate the number of observations per station name
temp_stat <- stations %>% 
  group_by(station) %>%
  summarise(n_stat = n())

#Merge back
temp2 <- merge(stations,temp_add,by=c("full_address"),all.x=TRUE)
temp2 <- merge(temp2,temp_stat,by=c("station"),all.x=TRUE)
rm(temp_stat,temp_add)

#Subset
temp2 <- subset(temp2,n_add!=7)
temp2 <- subset(temp2,n_stat!=7)


#Check the rest manually-------------------------------

#NOTE: In some cases (e.g. Lahti) multiple stations in same address. 
#If one closes but there is still a station in the same address, it is not counted as a closure.
#NIMIMUUTOKSET
temp2 <- subset(temp2, station!="Kirkonkylän terveysasema" & station!="Kirkonkylän terveysasema (Nurmijärvi)")
temp2 <- subset(temp2, station!="Kirkonkylän terveysasema (Vesilahti)" & station!="Vesilahden terveysasema")
temp2 <- subset(temp2, station!="Omapihlaja Tampere" & station!="Omapihlaja Kehräsaari")
temp2 <- subset(temp2, station!="Tenholan terveysasema" & station!="Tenholan vastaanotto")

#ULKOISTUKSET
#Tampereen muutokset johtuneet ulkoistuksen vaihtumisesta
temp2 <- subset(temp2, municipality!="Tampere" | station=="Atalan terveysasema")
#Nimimuutos ulkoistus vaihtui Attendosta Pihlajalinnaan
temp2 <- subset(temp2, station!="Attendo Hervannan terveysasema" & station!="Omapihlaja Hervanta")

#MUUT
#Lahden keskustan lähiklinikat yhdistyivät 2017: 
#2014 uusi asema Harjukadulla 
#Lahden asemat (3) Kauppakadulla muuttuivat kahdeksi lähiklinikaksi 2014, mutta samassa osoitteessa jatkaa keskustan terveysasema -> ei lasketa suluksi
temp2 <- subset(temp2, station!="Jalkarannan-metsäkankaan terveysasema" & station!="Mukkulan terveysasema")
#2018 toinen keskustan lähiklinikka ja pääterveysasema siirtyneet Harjukadulle ja Kauppakadun asema suljettu
#Suoraman terveysasema suljettu, mutta samassa osoitteessa pääterveysasema jatkaa -> ei lasketa suluksi
temp2 <- subset(temp2, station!="Suoraman terveysasema")

#MUUTTO (asemia ei suljettu)
#Nimimuutos ja osoitemuutos
temp2 <- subset(temp2, station!="Kesälahden terveysasema" & station!="Kesälahden terveyskeskus")
#MUUTTO: Kuusankosken terveysasema siirtyi Katajaharjuun
temp2 <- subset(temp2, station!="Kuusankosken terveysasema" & station!="Katajaharjun terveysasema")
#Nimimuutos, ulkoistus ja muutto 2014
temp2 <- subset(temp2, station!="Korpilahden terveysasema" & station!="Oma Lääkärisi Korpilahti")
#Lopen terveysasema muutto + nimimuutos 2015 jälkeen
temp2 <- subset(temp2, station!="Lopen terveysasema" & station!="Lopen lähiasema")
#Virtasalmen terveysasema muutto 2015 jälkeen, muuttuu hoitajavastaanotoksi 2018
temp2 <- subset(temp2, station!="Virtasalmen terveysasema" & station!="Virtasalmen hoitajavastaanotto")
#Nimimuutos ja osoitemuutos
temp2 <- subset(temp2, station!="Purmon terveysasema" & station!="Purmon sivuvastaanotto")
#Nimimuutos 2015 ja muutto 2017
temp2 <- subset(temp2, station!="Palosaaren terveysasema" & station!="Tammikaivon terveysasema")
#Nimi ja osoite muuttuu
temp2 <- subset(temp2, station!="Kontinkankaan terveysasema" & station!="Kontinkankaan hyvinvointikeskus") #Tässä ns. sulku ja uusi suurempi asema vanhan vieressä
temp2 <- subset(temp2, station!="Rajakylän terveysasema" & station!="Rajakylän hyvinvointipiste")


#Check ends-----------------------------------------


#Identify openings and closing
#First and last year of each station
temp2 <- temp2 %>%
  group_by(station) %>%
  summarise(max=max(year),min=min(year),address=last(full_address), municipality=last(municipality))
#Add indicators
temp2$entry <- ifelse(temp2$min!=2013,1,0)
temp2$exit <- ifelse(temp2$max!=2019,1,0)
#Interactions
temp2$entry_2014 <- ifelse(temp2$min==2014 & temp2$entry==1,1,0)
temp2$entry_2015 <- ifelse(temp2$min==2015 & temp2$entry==1,1,0)
temp2$entry_2016 <- ifelse(temp2$min==2016 & temp2$entry==1,1,0)
temp2$entry_2017 <- ifelse(temp2$min==2017 & temp2$entry==1,1,0)
temp2$entry_2018 <- ifelse(temp2$min==2018 & temp2$entry==1,1,0)
temp2$entry_2019 <- ifelse(temp2$min==2019 & temp2$entry==1,1,0)
temp2$exit_2013 <- ifelse(temp2$max==2013 & temp2$exit==1,1,0)
temp2$exit_2014 <- ifelse(temp2$max==2014 & temp2$exit==1,1,0)
temp2$exit_2015 <- ifelse(temp2$max==2015 & temp2$exit==1,1,0)
temp2$exit_2016 <- ifelse(temp2$max==2016 & temp2$exit==1,1,0)
temp2$exit_2017 <- ifelse(temp2$max==2017 & temp2$exit==1,1,0)
temp2$exit_2018 <- ifelse(temp2$max==2018 & temp2$exit==1,1,0)
#All
temp2$all <- 1


###############################################

#Geocode
#Google Maps API
#temp3 <- ggmap::mutate_geocode(temp2, location=address)
#Open Street Map
temp3 <- tidygeocoder::geocode(temp2,address=address,method="osm")

#Check that all results fall sensibly within Finnish territory
check <- temp3[ which (temp3$long>19 & temp3$long<32 & temp3$lat>59 & temp3$lat<71), ]
rm(check)

# Transform coordinate values: ETRS-TM35FIN
temp4 <- temp3 %>% 
  mutate(N = lat, E = long)
coordinates(temp4) <- ~ E + N
proj4string(temp4) <- CRS("+proj=longlat")
temp4 <- spTransform(temp4, CRS("+init=epsg:3067"))
temp4 <- temp4 %>%
  as.data.frame() %>%
  rename(easting=coords.x1, northing=coords.x2)

rm(temp2, temp3)

#Get data on municipalities or zipcodes
areas_mun <- get_municipalities(year = 2013, scale = 1000)
areas_mun$all <- 1
areas_zip <- get_zipcodes(year = 2019, extend_to_sea_areas = FALSE)
areas_zip$all <- 1


#----------------------------------------------


#Separate exit samples by municipal categorization

exits <- subset(temp4, exit==1)

mun_category <- select(areas_mun, name, kuntaryhmitys_code)
mun_category <- mun_category %>%
  rename(municipality=name)
#Merge
exits <- left_join(exits, mun_category, by="municipality")

rm(mun_category)

# Fix values
exits <- exits %>% 
  mutate("Municipality_type" = fct_recode(as.factor(kuntaryhmitys_code),
                                          Urban = "1", Semiurban = "2", Rural = "3"))%>%
  select(-kuntaryhmitys_code)

# Save data
save(exits, file = here::here("data", tag, "exits_coordinates.RData"))

# Entries data
entries <- subset(temp4, entry==1)

# Save
save(entries, file = here::here("data", tag, "entries_coordinates.RData"))


#----------------------------------------------------------
# GEOCODING ALL STATION COORDINATES
#----------------------------------------------------------


#Removing columns
addresses <- select(stations, -municipality, -municipality_num, -outsourced)

#Removing duplicate addresses
temp5 <- addresses %>%
  distinct(full_address, .keep_all = TRUE)

#Geocode
#Open Street Map
temp5 <- tidygeocoder::geocode(temp5,address=full_address,method="osm")


#Check for empty values
empty <- subset(temp5, is.na(lat)==TRUE)
empty <- select(empty, -lat,-long)

#Modifications:
#closest address available in OSM
empty$full_address <- ifelse(empty$station=="Kontiolahden terveysasema",
                             "Vierevänniementie 3, 81100 Kontiolahti, Finland",empty$full_address)
empty$full_address <- ifelse(empty$station=="Virtasalmen terveysasema",
                             "Virtasalmentie 2, 77330 Pieksämäki, Finland", empty$full_address)
#Sairaalatie/Sairaalantie differences in GoogleMaps/OSM
empty$full_address <- ifelse(empty$station=="Joroisten terveysasema",
                             "Sairaalantie 1, 79600 Joroinen, Finland",empty$full_address)
empty$full_address <- ifelse(empty$station=="Heinäveden terveysasema",
                             "Sairaalatie 4, 79700 Heinävesi, Finland", empty$full_address)
# Viipurinkatu is nowadays viipurintie
empty$full_address <- ifelse(empty$station=="Rautjärven terveysasema",
                             "Viipurintie 6, 56800 Rautjärvi, Finland",empty$full_address)
#OSM addresses in Swedish only
empty$full_address <- ifelse(empty$station=="Teerijärven terveysasema",
                             "Hörbyvägen 8, 68700 Kruunupyy, Finland", empty$full_address)
empty$full_address <- ifelse(empty$station=="Nauvon terveysasema",
                             "Klockstapelgränd 2, 21660 Parainen, Finland",empty$full_address)

#Geocode missing coordinates and add to temp5
empty <- tidygeocoder::geocode(empty, address = full_address,method="osm")

# Add
temp5 <- temp5 %>%
  left_join(empty, by="station", suffix = c("", "_fix")) %>%
  mutate(
    full_address = coalesce(full_address_fix, full_address),
    lat = ifelse(!is.na(lat_fix), lat_fix, lat),  # Only update missing lat/long values
    long = ifelse(!is.na(long_fix), long_fix, long)) %>%
  select(-lat_fix, -long_fix, -full_address_fix, -year_fix)


#Check that all results fall sensibly within Finnish territory
check <- temp5[ which (temp5$long>19 & temp5$long<32 & temp5$lat>59 & temp5$lat<71), ]
rm(check, empty)

# Transform coordinates: ETRS-TM35FIN
all_coordinates <- temp5 %>% 
  mutate(N = lat, E = long)
coordinates(all_coordinates) <- ~ E + N
proj4string(all_coordinates) <- CRS("+proj=longlat")
all_coordinates <- spTransform(all_coordinates, CRS("+init=epsg:3067"))
all_coordinates <- all_coordinates %>%
  as.data.frame() %>%
  rename(easting=coords.x1, northing=coords.x2) %>%
  select(-full_address, -lat, -long)

rm(addresses, temp5)

# Save all coordinates data
# save(all_coordinates, file = here::here("data", tag, "raw", "all_coordinates.RData"))


#------------------------------------------------


# Separate data excluding new stations or closed stations
other_stations <- subset(all_coordinates, !(station %in% exits$station | station %in% entries$station))

# Save
save(other_stations, file = here::here("data", tag, "other_station_coordinates.Rdata"))



