
#####################################


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
areas2 <- left_join(areas,px_data,by="posti_alue")

# Fix scale
areas2$tiheys <- areas2$inhabitants_total_he/(areas2$pinta_ala/1000000)
areas2$tiheys <- ifelse(areas2$tiheys>100,100,areas2$tiheys)



#####################################


#----------------------------------------------------------
# DRAW
#----------------------------------------------------------

# Health station exits

pdf("kartat/kuvat/exits_updated.pdf")
p <- ggplot(data=areas2) + 
  geom_sf(aes(fill=tiheys),color="transparent") + 
  #geom_sf(fill="transparent",color="transparent",size=1,linewidth=.8, data=. %>% group_by(all) %>% summarise()) + 
  geom_point(data=exit_2013, aes(y=northing, x=easting), size=3, fill = "red", color="black", stroke=0.5, shape=22) +
  geom_point(data=exit_2014, aes(y=northing, x=easting), size=3, fill = "red", color="black", stroke=0.5, shape=22) +
  geom_point(data=exit_2015, aes(y=northing, x=easting), size=3, fill = "red", color="black", stroke=0.5, shape=22) +
  geom_point(data=exit_2016, aes(y=northing, x=easting), size=3, fill = "red", color="black", stroke=0.5, shape=22) +
  geom_point(data=exit_2017, aes(y=northing, x=easting), size=3, fill = "red", color="black", stroke=0.5, shape=22) +
  geom_point(data=exit_2018, aes(y=northing, x=easting), size=3, fill = "red", color="black", stroke=0.5, shape=22)
p + theme_map() +
  theme(
    axis.line=element_blank(),
    axis.text.x=element_blank(),
    axis.text.y=element_blank(),
    axis.ticks.x=element_blank(),
    axis.ticks.y=element_blank(),
    axis.title.x=element_blank(),
    axis.title.y=element_blank(),
    plot.background=element_blank(),
    plot.tag.position=c(0,1),
    legend.position = "right",
    legend.justification = "center"
  ) +
  scale_fill_viridis(name = "Population/km²", option = "mako", direction=-1)
dev.off()



#####################################


