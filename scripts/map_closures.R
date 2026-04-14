
#####################################

# Data in exits_coordinates, entries_coordinates and all_coordinates

#----------------------------------------------------------
# GET POPULATION DENSITY
#----------------------------------------------------------


# Query
pxweb_query_list <- 
  list("Postinumeroalue"=c("*"),
       "Tiedot"=c("he_vakiy"),
       "Vuosi"=c("2018"))

# Get
px_raw <- 
  pxweb_get(url = "https://statfin.stat.fi/PXWeb/api/v1/en/Postinumeroalueittainen_avoin_tieto/uusin/paavo_pxt_12ey.px",
            query = pxweb_query_list)

# Tidy
px_data <- as_tibble(
  as.data.frame(px_raw, 
                column.name.type = "text", 
                variable.value.type = "text")
) %>% setNames(janitor::make_clean_names(names(.)))
px_data %>%
  filter(postal_code_area != "Finland")
px_data$posti_alue <- sub(" .+$", "", px_data$postal_code_area)
px_data <- px_data %>%
  subset(posti_alue!="WHOLE") %>%
  select(-postal_code_area,-year)


# Join
areas2 <- left_join(areas_zip,px_data,by="posti_alue")

# Fix scale
areas2$tiheys <- areas2$inhabitants_total_he/(areas2$pinta_ala/1000000)
areas2$tiheys <- ifelse(areas2$tiheys>30,30,areas2$tiheys)


rm(px_raw, pxweb_query_list)

# Save for the interactive map 
save(areas2, file = here::here("data/final", tag, "areas2.RData"))


#####################################


#----------------------------------------------------------
# DRAW
#----------------------------------------------------------

# Health station exits

exits_graph <- ggplot(data=areas2) + 
  geom_sf(aes(fill=tiheys),color="transparent") + 
  geom_point(data=exits, aes(y=northing, x=easting), size=2.5, color="red", stroke=0.75, shape=22) +
  
  theme_map() +
  theme(
    axis.line=element_blank(),
    axis.text.x=element_blank(),
    axis.text.y=element_blank(),
    axis.ticks.x=element_blank(),
    axis.ticks.y=element_blank(),
    axis.title.x=element_blank(),
    axis.title.y=element_blank(),
    plot.background=element_blank(),
    plot.tag.position=c(0,1), legend.position = "right", legend.justification = "center") +
  scale_fill_distiller(name = "Population/km²", palette = "PuBu", direction= 1)

# Save the graph
ggsave(here::here("output", tag, "exits_graph.pdf"), exits_graph, width = 110, height = 130, units = "mm", device="pdf", dpi=300)


####################################################



