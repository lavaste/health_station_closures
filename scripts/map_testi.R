

# Make sure packages are loaded in shiny server:
library(ggplot2)
library(ggiraph)
library(sf)
library(ggthemes)
library(here)

# Resolve the data folder when the script is sourced from a Shiny context.
data_tag <- if (exists("tag", inherits = TRUE)) {
  get("tag", inherits = TRUE)
} else {
  paste0(format(Sys.Date(), "%Y-%m-%d"), "-", Sys.info()[["user"]])
}

load_map_data <- function(data_tag) {
  data_paths <- c(
    exits = here::here("data", "final", data_tag, "exits_coordinates.RData"),
    entries = here::here("data", "final", data_tag, "entries_coordinates.RData"),
    other_stations = here::here("data", "final", data_tag, "other_station_coordinates.Rdata"),
    areas2 = here::here("data", "final", data_tag, "areas2.RData")
  )
  
  missing_paths <- data_paths[!file.exists(data_paths)]
  if (length(missing_paths) > 0) {
    stop(
      paste(
        "Map data files are missing for tag", shQuote(data_tag), ":\n",
        paste(missing_paths, collapse = "\n")
      ),
      call. = FALSE
    )
  }
  
  map_env <- new.env(parent = emptyenv())
  load(data_paths[["exits"]], envir = map_env)
  load(data_paths[["entries"]], envir = map_env)
  load(data_paths[["other_stations"]], envir = map_env)
  load(data_paths[["areas2"]], envir = map_env)
  
  list(
    exits = map_env$exits,
    entries = map_env$entries,
    other_stations = map_env$other_stations,
    areas2 = map_env$areas2
  )
}


# Define options 
hover_css <- "stroke-width:0.75px;"

tools_css <- "color: #ECF0F1;
padding: 5px;
border-radius: 5px;
font-family: 'Arial', sans-serif;
font-size: 12px;
box-shadow: 0px 0px 10px rgba(0,0,0,0.5);"

make_interactive_map <- function(
  show_fill = TRUE,
  show_other_stations = TRUE,
  show_new_stations = TRUE,
  show_closed_stations = TRUE
) {
  map_data <- load_map_data(data_tag)
  
  p <- ggplot(data = map_data$areas2)
  
  if (show_fill) {
    p <- p +
      geom_sf(aes(fill = tiheys), color = "transparent")
  } else {
    p <- p +
      geom_sf(fill = NA, color = "grey60", linewidth = 0.2)
  }
  
  if (show_other_stations) {
    p <- p +
      geom_point_interactive(
        data = map_data$other_stations,
        aes(
          y = northing,
          x = easting,
          tooltip = paste(station),
          data_id = station
        ),
        tooltip_fill = "#5B8DB8",
        size = 0.5, color = "#3F6F9D", stroke = 0.25, shape = 22
      )
  }
  
  if (show_new_stations) {
    p <- p +
      geom_point_interactive(
        data = map_data$entries,
        aes(
          y = northing,
          x = easting,
          tooltip = paste(station, "<br>Opened in", min),
          data_id = station
        ),
        tooltip_fill = "#2E8B57",
        size = 0.5, color = "#008080", stroke = 0.25, shape = 22
      )
  }
  
  if (show_closed_stations) {
    p <- p +
      geom_point_interactive(
        data = map_data$exits,
        aes(
          y = northing,
          x = easting,
          tooltip = paste(station, "<br>Closed in", closure_year),
          data_id = station
        ),
        tooltip_fill = "#FC5F67",
        size = 0.5, color = "red", stroke = 0.25, shape = 22
      )
  }
  
  p <- p +
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
        palette = "YlOrBr",
        direction = 1
      )
  }
  
  widget <- girafe(ggobj = p)
  
  girafe_options(
    widget,
    opts_tooltip(css = tools_css, use_fill = TRUE),
    opts_hover(css = hover_css),
    opts_hover_inv(css = "stroke:grey"),
    opts_zoom(max = 8, default_on = TRUE)
  )
}
