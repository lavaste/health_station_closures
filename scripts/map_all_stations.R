
############################################


# All clinics with closed clinics marked

all_clinics_graph <- ggplot(data = areas_mun) +
  geom_sf(color = "dimgrey", fill = NA) +
  geom_point(
    data = other_stations,
    aes(x = easting, y = northing, fill = "No change"),
    shape = 22, size = 1.8, stroke = 0.25, color = "dimgray") +
  geom_point(
    data = exits,
    aes(x = easting, y = northing, fill = "Closed"),
    shape = 22, size = 1.8, stroke = 0.25, color = "dimgrey") +
  scale_fill_manual(
    name = "Status:",
    values = c("No change" = "#21918c", "Closed" = "#fde725")) +
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
    plot.tag.position=c(0,1),
    legend.position = "right",
    legend.justification = "center") 

# Save the graph
ggsave(here::here("output", tag, "all_stations_graph.pdf"), all_clinics_graph, width = 110, height = 130, units = "mm", device="pdf", dpi=300)


###############################################


# All clinics with the new clinics marked

new_stations_graph <- ggplot(data = areas_mun) +
  geom_sf(color = "dimgrey", fill = NA) +
  geom_point(
    data = other_stations,
    aes(x = easting, y = northing, fill = "No change"),
    shape = 22, size = 1.8, stroke = 0.25, color = "dimgray") +
  geom_point(
    data = entries,
    aes(x = easting, y = northing, fill = "New clinic"),
    shape = 22, size = 1.8, stroke = 0.25, color = "dimgrey") +
  scale_fill_manual(
    name = "Status:",
    values = c("No change" = "#21918c", "New clinic" = "#440154")) +
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
    plot.tag.position=c(0,1),
    legend.position = "right",
    legend.justification = "center")


# Save the graph
ggsave(here::here("output", tag, "new_stations_graph.pdf"), new_stations_graph, width = 110, height = 130, units = "mm", device="pdf", dpi=300)


#####################################

