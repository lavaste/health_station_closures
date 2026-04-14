

# Make sure packages are loaded in shiny server:
library(ggplot2)
library(ggiraph)
library(sf)
library(ggthemes)
library(here)

# Loading exits and areas2 data so shiny server can access them:
load(here::here("data", "final", tag, "exits_coordinates.RData"))
load(here::here("data", "final", tag, "areas2.Rdata"))


# Define options 
hover_css <- "stroke:red;stroke-width:1px;"

tools_css <- "background-color: #FC5F67;
color: #ECF0F1;
padding: 5px;
border-radius: 5px;
font-family: 'Arial', sans-serif;
font-size: 12px;
box-shadow: 0px 0px 10px rgba(0,0,0,0.5);"

make_interactive_map <- function(show_fill = TRUE) {
  
  p <- ggplot(data = areas2)
  
  if (show_fill) {
    p <- p +
      geom_sf(aes(fill = tiheys), color = "transparent")
  } else {
    p <- p +
      geom_sf(fill = NA, color = "grey60", linewidth = 0.2)
  }
  
  p <- p +
    geom_point_interactive(
      data = exits,
      aes(
        y = northing,
        x = easting,
        tooltip = paste(station, "<br>Closed in", closure_year),
        data_id = station
      ),
      size = 2, color = "red", stroke = 0.5, shape = 22
    ) +
    labs(title = "Interactive map of health station closures in Finland") +
    theme_map() +
    theme(
      plot.title = element_text(hjust = 0.5, size = 12, face = "bold"),
      axis.line = element_blank(),
      axis.text.x = element_blank(),
      axis.text.y = element_blank(),
      axis.ticks.x = element_blank(),
      axis.ticks.y = element_blank(),
      axis.title.x = element_blank(),
      axis.title.y = element_blank(),
      plot.background = element_blank(),
      plot.tag.position = c(0, 1),
      legend.position = if (show_fill) "right" else "none",
      legend.justification = "center"
    )
  
  if (show_fill) {
    p <- p +
      scale_fill_distiller(
        name = "Population/km²",
        palette = "PuBu",
        direction = 1
      )
  }
  
  widget <- girafe(ggobj = p)
  
  girafe_options(
    widget,
    opts_tooltip(css = tools_css),
    opts_hover(css = hover_css),
    opts_hover_inv(css = "stroke:grey"),
    opts_zoom(max = 8, default_on = TRUE)
  )
}

