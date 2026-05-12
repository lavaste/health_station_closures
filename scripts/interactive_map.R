
#####################################

# TÄLLÄ HETKELLÄ EI TULOSTU HTML FILEEN, SELVITÄ MIKSI!

# Data in exits_coordinates, entries_coordinates and all_coordinates
# Zip code level demographic data in areas2
# TEHTÄVIÄ: 
#       1. Testaa miten saa zoomaus mahdollisuuden -> sitten voisi myös lisätä muut 
#.          asemat ja zoomailun kanssa ei ole ehkä niin hankala löytää suljettuja asemia
#       2. Mahdollisuus valita haluaako taustalle väestöntiheyden/jonkin muun/ei mitään
# 

#----------------------------------------------------------
# INTERACTIVE MAP: ALL STATIONS, CLOSURES MARKED
#----------------------------------------------------------

# Areas2 
load(here::here("data", "final", tag, "areas2.Rdata"))
# Drawing the plot

test <- ggplot(data = areas2) +
  geom_sf(aes(fill=tiheys),color="transparent") +
  # Saisiko jotenkin mukaan myös muut asemat?
  geom_point_interactive(data = other_stations, aes(y=northing, x=easting,
                                          tooltip = paste(station),
                                          data_id = station),
                         tooltip_fill = "#5B8DB8",
                         size=0.5, color="#3F6F9D", stroke=0.25, shape=22) +
  geom_point_interactive(data = entries, aes(y=northing, x=easting,
                                             tooltip = paste(station, "<br>Opened in",min),
                                             data_id = station),
                         tooltip_fill = "#2E8B57",
                         size=0.5, color="#008080", stroke=0.25, shape=22) +
  geom_point_interactive(data = exits, aes(y=northing, x=easting, 
                                          tooltip = paste(station, "<br>Closed in",closure_year),
                                          data_id = station),
                                          tooltip_fill = "#FC5F67",
                                          size=0.5, color="red", stroke=0.25, shape=22) +
  
  labs(
    title = "Interactive map of healthstation closures in Finland") +
  theme_map() +
    theme(
      plot.title = element_text(hjust = 0.5, size = 12, face = "bold"),
      axis.line=element_blank(),
      axis.text.x=element_blank(),
      axis.text.y=element_blank(),
      axis.ticks.x=element_blank(),
      axis.ticks.y=element_blank(),
      axis.title.x=element_blank(),
      axis.title.y=element_blank(),
      plot.background=element_blank(),
      plot.tag.position=c(0,1), legend.position = "right", legend.justification = "center") +
    scale_fill_distiller(name = "Population/km²", palette = "YlOrBr", direction= 1)

# Creating interactive plot
interactive_plot <- girafe(ggobj = test)

# Plot options
hover_css <- "stroke-width:0.75px;"
  
tools_css <- "color: #ECF0F1;
                   padding: 5px;
                    border-radius: 5px;
                  font-family: 'Arial', sans-serif;
                 font-size: 12px;
                 box-shadow: 0px 0px 10px rgba(0,0,0,0.5);"

interactive_plot <- girafe_options(interactive_plot,
    opts_tooltip(css = tools_css, use_fill = TRUE),
    opts_hover(css = hover_css),
    opts_hover_inv(css = "stroke:grey"),
    opts_zoom(max = 8, default_on = TRUE)
  )

interactive_plot
htmltools::save_html(interactive_plot, here::here("output", tag, "interactive_map.html"))
