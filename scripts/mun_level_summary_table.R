

#-----------------------------------------------------------
#SUMMARY TABLES: Data
#-----------------------------------------------------------


# Demographics & expenditure data from Sotkanet and Statistics Finland

# Get Sotkanet indicator data

data_sotkanet <- get_sotkanet(indicators = c(1068, 127, 2331, 2332, 243, 3177, 181, 761, 3099, 178), 
                              genders = "total", years = 2013, region.category = "KUNTA")

# Pivot table
data_sotkanet <- data_sotkanet %>%
  select(region.title, indicator.title, primary.value) %>%
  distinct() %>%
  pivot_wider(
    names_from = indicator.title,
    values_from = primary.value)


#Adding column treated
data_sotkanet$treated <- ifelse(data_sotkanet$region.title%in%exits$municipality,"Treatment","Control")

#Modifying urbanization variable values
data_sotkanet <- data_sotkanet %>% 
  mutate("kuntaryhmitys" = fct_recode(as.factor(`Tilastokeskuksen kuntaryhmitys`),
                                      Urban ="1",Semiurban ="2",Rural ="3"))


#------------------------------------------------

# Income data from Statistics Finland

# Query
# pxweb_query_income <- 
#  list("Kunta"=c("*"),
#       "Asuntokunnat"=c("SSS"),
#       "Tiedot"=c("kturaha_summa", "asuntokunta_lkm"),
 #      "Vuosi"=c("2013", "2019"))

# Get
# Tässä jostain syystä joku ongelma, ei läydy tk sivuilta
#px_raw_income <- 
#  pxweb_get(url = "https://pxdata.stat.fi:443/PxWeb/api/v1/fi/StatFin/velk/statfin_velk_pxt_13kw.px",
#           query = pxweb_query_income)

# Clean
#px_data_income <- as_tibble(
#  as.data.frame(px_raw_income, 
#                column.name.type = "text", 
#                variable.value.type = "text")
# ) %>% setNames(janitor::make_clean_names(names(.)))%>%
#  rename("municipality"=kunta, "year"=vuosi)
#px_data_income <- px_data_income[3:588,]%>%
#  select(-asuntokunnat)

# Disposable income / household
#px_data_income$käyt_tulot_asuntokunta <- 
#  px_data_income$kaytettavissa_oleva_rahatulo_euroa/px_data_income$asuntokuntien_lukumaara
#px_data_income <- select(px_data_income, -kaytettavissa_oleva_rahatulo_euroa, -asuntokuntien_lukumaara)

#Merge
#data_sotkanet <- right_join(data_sotkanet, px_data_income, by=c("municipality","year"))
#rm(px_raw_income, pxweb_query_income)


#------------------------------------------------

#Number of stations in municipality

stations_2013 <- read_excel("data/raw/health_stations_Finland_13-19.xlsx",
                            "2013",col_names =TRUE,na="",range = cell_cols("A:V"))

#Count stations in municipality in 2013
num_stations <- stations_2013 %>% count(municipality)
num_stations <- num_stations %>%
  rename("clinics"="n")
#Add variable
data_sotkanet <- left_join(data_sotkanet, num_stations, by= c("region.title" = "municipality")) 

rm(num_stations)

#---------------------------------------------------------------
# Summary statistics
# Mean, sd, and smd 
# Ei ole nyt lisätty tk lukuja mukaan koska ei toiminut!

#---------------------------------------

# Organizing data
# Renaming variables 
data_sotkanet <- rename(data_sotkanet, 
                        huoltosuhde=`Huoltosuhde, demografinen`,
                        väestö=`Väestö 31.12.`,
                        yli_65_osuus=`65 vuotta täyttäneet, % väestöstä`,
                        tiheys=`Väestöntiheys, asukkaita/km²`,
                        sairastavuus=`THL:n sairastavuusindeksi, ikävakioitu (-2019)`,
                        pienituloisuusaste=`Kunnan yleinen pienituloisuusaste`,
                        työttömyysaste=`Työttömät, % työvoimasta`,
                        nettomuutto_1000as=`Kuntien välinen nettomuutto / 1 000 asukasta`,
                        verotulot=`Verotulot, euroa / asukas (-2022)`)

data_balance <- as.data.table(data_sotkanet)

# Function to compute balance statistics
create_balance_table <- function(data) {
  
  # Statistics table as data.table
  df <- data[, mget(colnames(data))]
  # Variables to be included in the table:
  vars.table <- c("clinics","väestö", "tiheys","sairastavuus","yli_65_osuus",
                  "verotulot","huoltosuhde","työttömyysaste","pienituloisuusaste","nettomuutto_1000as")
  
  # Compute group-specific means:
  dt.mean <- df[, lapply(.SD, mean, na.rm = TRUE), .SDcols=vars.table, 
                by='treated'][order(treated)]
  
  # Compute group-specific SD:
  dt.sd <- df[, lapply(.SD, sd, na.rm = TRUE), .SDcols=vars.table, 
              by='treated'][order(treated)]
  
  # Initiate a table. Tidy.
  dt.mean <- t(as.matrix(dt.mean))
  dt.mean <- data.table(row = 1:nrow(dt.mean),
                        covariate = rownames(dt.mean),
                        mean.control = dt.mean[, 1],
                        mean.treat = dt.mean[, 2])
  
  dt.sd <- t(as.matrix(dt.sd))
  dt.sd <- data.table(row = 1:nrow(dt.sd),
                      covariate = rownames(dt.sd),
                      sd.control = dt.sd[, 1],
                      sd.treat = dt.sd[, 2])
  
  table <- merge(dt.mean, dt.sd, by='row', all.x = TRUE)
  table <- table[2:nrow(table)]
  covariates <- table[, covariate.x]
  
  # As numeric:
  vars <- c('mean.treat', 'sd.treat', 'mean.control', 'sd.control')
  table <- table[, lapply(.SD, as.numeric), .SDcols=vars]
  
  # Relative (%) differences in means:
  table[, relative.diff := 
          100*(mean.treat - mean.control) / mean.control]
  
  # Round and format:
  vars <- c(vars, 'relative.diff')
  table <- table[, lapply(.SD, round, digits=3), .SDcols=vars
  ][, lapply(.SD, format, nsmall=3), .SDcols=vars]
  
  table[, variable := covariates]
  
  # Standardized mean differences. 
  smd <- lapply(vars.table, function(var) {
    
    smd <- smd::smd(x=df[, mget(var)], 
                    g=df[, treated], na.rm = TRUE, gref = 2)$estimate
    smd <- format(round(smd, digits=3), nsmall=3)
    smd <- data.table(variable = var, smd = smd)
    
  })
  smd <- rbindlist(smd)
  smd[, row := c(1:length(vars.table))]
  table <- merge(table, smd, by='variable', all.x=TRUE)[order(row)]
  table[, row := NULL]
  
  # Tidy special columns
  
  table[, sd.treat := gsub(' ', '', paste('[', sd.treat, ']', sep=''))]
  table[, sd.control := gsub(' ', '', paste('[', sd.control, ']', sep=''))]
  table[, relative.diff := as.numeric(relative.diff)]
  table[, relative.diff := format(round(relative.diff, digits = 1), nsmall=1)]
  table[!grepl('-', relative.diff), 
        relative.diff := gsub(' ', '', paste('+', relative.diff, sep = ''))]
  table[!grepl('-', smd), smd := gsub(' ', '', paste('+', smd, sep = ''))]
  
  
  # Sample sizes: municipalities
  
  N.hs <- df[, .(N=uniqueN(region.title)), by='treated']
  row.N.hs <- data.table(
    variable = 'Municipalities', 
    mean.treat = as.character(N.hs[treated=='Treatment', N]),
    mean.control = as.character(N.hs[treated=='Control', N]),
    sd.treat = NA_character_, sd.control = NA_character_, 
    smd = NA_character_, relative.diff = NA_character_)
  
  table <- rbind(table, row.N.hs)
  
  # Tidy variable names
  
  table[variable == 'clinics', variable.ena := 'Health stations (N)']
  table[variable == 'väestö', variable.ena := 'Population (ppl)']
  table[variable == 'tiheys', variable.ena := 'Population density (ppl/km2']
  table[variable == 'sairastavuus', variable.ena := 'Morbidity index']
  table[variable == 'yli_65_osuus', variable.ena := 'Aged >64 (%)']
  table[variable == 'verotulot', variable.ena := 'Tax revenue (€/capita)']
  table[variable == 'huoltosuhde', variable.ena := 'Demographic dependency ratio']
  table[variable == 'työttömyysaste', variable.ena := 'Unemployment rate (%)']
  table[variable == 'pienituloisuusaste', variable.ena := 'At-risk-of-poverty rate (%)']
  table[variable == 'käyt_tulot_asuntokunta', variable.ena := 'Disposable income (per hh)']
  table[variable == 'nettomuutto_1000as', variable.ena := 'Net migration'] #per 1000 inhabitants
  table[variable == 'Municipalities', variable.ena := 'Municipalities']
  
  table[variable == 'clinics', variable.fi := 'Terveysasemat (N)']
  table[variable == 'väestö', variable.fi := 'Väestö']
  table[variable == 'tiheys', variable.fi := 'Väestöntiheys']
  table[variable == 'sairastavuus', variable.fi := 'Sairastavuus']
  table[variable == 'yli_65_osuus', variable.fi := 'Yli 65 vuotiaiden osuus']
  table[variable == 'verotulot', variable.fi := 'Verotulot (€/asukas)']
  table[variable == 'huoltosuhde', variable.fi := 'Demografinen huoltosuhde']
  table[variable == 'työttömyysaste', variable.fi := 'Työttömyysaste']
  table[variable == 'pienituloisuusaste', variable.fi := 'Pienituloisuusaste']
  table[variable == 'käyt_tulot_asuntokunta', variable.fi := 'Käytettävissä olevat tulot'] #Per asuntokunta
  table[variable == 'nettomuutto_1000as', variable.fi := 'Nettomuutto'] #per 1000 inhabitants
  table[variable == 'Municipalities', variable.fi := 'Kunnat']
  
  return(table)
}

# Apply function
balance_table <- create_balance_table(data=data_balance)

table.ena <- balance_table[, .(variable.ena, mean.treat, sd.treat, mean.control, 
                               sd.control, relative.diff, smd)]
table.fin <- balance_table[, .(variable.fi, mean.treat, sd.treat, mean.control, 
                               sd.control, relative.diff, smd)]

# Save as LaTex
stargazer::stargazer(
  table.ena, out = paste0(file = here::here("output", tag, "mun_level_summary_table.tex")),
  type='text', summary=FALSE, rownames = F, header = F)



#stargazer::stargazer(
#  table.fin, out = paste0('datat/taulukot/summary_statistics_fi.tex'),
#  type='text', summary=FALSE, rownames = F, header = F)

# Save as image
# library(magick)
# library(pdftools)

# image <- image_read_pdf('datat/Taulukot/summary_statistics_fi.tex', density = 300)
# image_write(image, path = 'kartat/kuvat/exits_by_urbanity.png', format = 'png')

