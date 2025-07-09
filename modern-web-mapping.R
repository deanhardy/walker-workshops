rm(list=ls())
# install.packages("mapgl")
# 
# install.packages("pak")
# 
# pak::pak("walkerke/mapgl")
# 
# commercial products for both of those below; free accounts available also but these will work for two weeks
Sys.setenv(MAPBOX_PUBLIC_TOKEN="pk.eyJ1Ijoia3dhbGtlcnRjdSIsImEiOiJjbWN2NW14NzAwMjIxMnFweGFwbGx6cW43In0.j_CfFOdiRxHQX_TnoSMbtQ")

Sys.setenv(MAPTILER_API_KEY="jTewQ7lRuQvOmsFyYPbg")

library(mapgl)

## define data directory
datadir <- '/Users/dhardy/Dropbox/r_data/walker-workshops/'

mapboxgl()

maplibre() |> 
  set_projection("globe")

mapboxgl(style = mapbox_style("dark"))

maplibre(style = maptiler_style("winter"))

maplibre(style = maptiler_style("streets", variant = "light"))

mapboxgl(
  style = mapbox_style("standard"),
  center = c(2.3522, 48.8566),  # Paris
  zoom = 16,
  pitch = 60,
  bearing = -17.6
)

mapboxgl(
  style = mapbox_style("standard-satellite"),
  center = c(85.3148, 27.7437),
  zoom = 11,
  pitch = 75,
  bearing = 8
)

mapboxgl() |> 
  fly_to(
    center = c(2.3522, 48.8566),  
    zoom = 12,
    duration = 10000,  
    pitch = 45
  )

mapboxgl(
  style = mapbox_style("standard"),
  center = c(-74.0060, 40.7128),  # New York
  zoom = 11,
  config = list(
    basemap = list(
      lightPreset = "night"
    )
  )
) 

mapboxgl(
  config = list(
    basemap = list(
      theme = "monochrome"
    )
  )
) 

mapboxgl(
  center = c(-81.265182, 31.422515), # Sapelo Island
  zoom = 16,
  pitch = 45,
  hash = T
) |> 
  set_rain(
    density = 0.5,
    intensity = 1,
    color = "#a8adbc"
  )

# Add snow effect
mapboxgl(
  center = c(-105.94036, 35.6869),  # Santa Fe
  zoom = 16,
  pitch = 50,
  config = list(
    basemap = list(
      lightPreset = "dusk"
    )
  )
) |> 
  set_snow(
    density = 0.8,
    intensity = 0.5
  )

library(sf)

# Load European NUTS data (source: eurostat R package)
europe_nuts <- st_read(paste0(datadir, "data/europe_nuts2.geojson"))

# Load city points data (source: SimpleMaps)
europe_cities <- st_read(paste0(datadir, "data/europe_cities.geojson"))

maplibre_view(europe_nuts)

# Quick choropleth of GDP per capita
maplibre_view(
  europe_nuts, 
  column = "gdp_per_capita"
)

maplibre_view(
  europe_cities,
  color = "red"
)

maplibre_view(europe_nuts, column = "gdp_per_capita", n = 5) |> 
  add_view(europe_cities, color = "red")

mapboxgl(
  center = c(2.3522, 48.8566),
  zoom = 10
) |> 
  add_navigation_control(position = "top-right") |> 
  add_scale_control(position = "bottom-left", unit = "metric") |> 
  add_fullscreen_control(position = "top-right")

maplibre_view(europe_nuts, column = "gdp_per_capita") |> 
  add_geocoder_control(provider = "maptiler")

mapboxgl() |> 
  add_draw_control(
    position = "top-left",
    freehand = TRUE,  
    controls = list(
      combine_features = FALSE,
      uncombine_features = FALSE
    )
  )

mapboxgl(
  bounds = europe_nuts, 
  config = list(
    basemap = list(
      theme = "monochrome"
    )
  )
) |> 
  add_source(
    id = "europe", 
    data = europe_nuts
  ) |> 
  add_draw_control(
    source = "europe",
    fill_color = "darkgreen",
    active_color = "magenta"
  )

mapboxgl(
  bounds = europe_nuts, 
  config = list(
    basemap = list(
      theme = "monochrome"
    )
  )
) |> 
  add_source(
    id = "europe", 
    data = europe_nuts
  ) |> 
  add_draw_control(
    source = "europe",
    fill_color = "darkgreen",
    active_color = "magenta",
    download_button = TRUE
  )

map1 <- maplibre_view(europe_nuts, column = "gdp_per_capita")
map2 <- maplibre_view(europe_nuts, column = "unemp", palette = viridisLite::inferno, legend_position = "top-right")

compare(map1, map2, swiper_color = "black")

compare(map1, map2, mode = "sync")

# Start with a base map
map <- maplibre(
  style = maptiler_style("dataviz", variant = "light"),
  bounds = europe_nuts
)

# Build the color palette
palette <- interpolate_palette(
  data = europe_nuts,
  column = "unemp", 
  palette = viridisLite::mako
)

# Let's take a look at the palette
print(palette)

map |> 
  add_fill_layer(
    id = "unemployment",
    source = europe_nuts,
    fill_color = palette$expression,
    fill_opacity = 0.7
  ) |> 
  add_legend(
    "Unemployment in Europe",
    values = get_legend_labels(palette, digits = 0, suffix = "%"),
    colors = get_legend_colors(palette)
  )

quantile_expr <- step_quantile(
  data = europe_nuts,
  column = "gdp_per_capita",
  n = 6,
  palette = viridisLite::turbo
)

map |> 
  add_fill_layer(
    id = "gdp",
    source = europe_nuts,
    fill_color = quantile_expr$expression,
    fill_opacity = 0.7
  ) |> 
  add_categorical_legend(
    legend_title = "GDP per Capita (€)",
    values = get_legend_labels(quantile_expr, format = "compact", prefix = "€"),
    colors = get_legend_colors(quantile_expr)
  )

map |> 
  add_fill_layer(
    id = "gdp",
    source = europe_nuts,
    fill_color = quantile_expr$expression,
    fill_opacity = 0.7,
    popup = concat(
      "GDP per capita: ",
      number_format(
        get_column("gdp_per_capita"), 
        style = "currency",
        currency = "EUR",
        maximum_fraction_digits = 0
      )
    )
  ) |> 
  add_categorical_legend(
    legend_title = "GDP per Capita (€)",
    values = get_legend_labels(quantile_expr, format = "compact", prefix = "€"),
    colors = get_legend_colors(quantile_expr)
  )

map |> 
  add_fill_layer(
    id = "gdp",
    source = europe_nuts,
    fill_color = quantile_expr$expression,
    fill_opacity = 0.7,
    popup = concat(
  "<div style='font-family: -apple-system, BlinkMacSystemFont, \"Segoe UI\", Roboto, sans-serif; padding: 16px; min-width: 180px; max-width: 180px;'>",
  "<h3 style='margin: 0 0 12px 0; color: #003399; font-size: 18px; font-weight: 600; padding-bottom: 8px; border-bottom: 2px solid #FFCC00;'>",
  get_column("name"),
  "</h3>",
  "<div style='display: flex; flex-direction: column; gap: 10px;'>",
  "<div style='display: flex; justify-content: space-between; align-items: center; padding: 8px 12px; background-color: #f8f9fa; border-radius: 4px;'>",
  "<span style='color: #495057; font-weight: 500; font-size: 14px;'>GDP per capita</span>",
  "<span style='color: #003399; font-weight: 600; font-size: 16px;'>",
  number_format(
    get_column("gdp_per_capita"), 
    style = "currency",
    currency = "EUR",
    maximum_fraction_digits = 0
  ),
  "</span>",
  "</div>",
  "<div style='display: flex; justify-content: space-between; align-items: center; padding: 8px 12px; background-color: #f8f9fa; border-radius: 4px;'>",
  "<span style='color: #495057; font-weight: 500; font-size: 14px;'>Unemployment rate</span>",
  "<span style='color: #dc3545; font-weight: 600;'>",
  number_format(
    get_column("unemp"), 
    maximum_fraction_digits = 1
  ),
  "%",
  "</span>",
  "</div>",
  "<div style='margin-top: 8px; padding-top: 8px; border-top: 1px solid #e9ecef;'>",
  "<span style='color: #6c757d; font-size: 12px;'>Region ID: ", 
  get_column("id"),
  "</span>",
  "</div>",
  "</div>",
  "</div>"
)
) |> 
  add_categorical_legend(
    legend_title = "GDP per Capita (€)",
    values = get_legend_labels(quantile_expr, format = "compact", prefix = "€"),
    colors = get_legend_colors(quantile_expr)
  )

eu_legend_style <- legend_style(
  # Clean white background with subtle transparency
  background_color = "#ffffff",
  background_opacity = 0.95,
  
  # EU blue border matching the popup header
  border_color = "#003399",
  border_width = 2,
  border_radius = 8,
  
  # Professional typography matching the popup
  text_color = "#495057",
  text_size = 13,
  title_color = "#003399",
  title_size = 16,
  font_family = "-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif",
  title_font_weight = "600",
  font_weight = "500",
  
  # Yellow accent borders on elements (EU yellow)
  element_border_color = "#FFCC00",
  element_border_width = 2,
  
  # Subtle shadow for depth
  shadow = TRUE,
  shadow_color = "rgba(0, 51, 153, 0.15)",  # EU blue shadow
  shadow_size = 8,
  
  # Comfortable padding
  padding = 16
)

map |> 
  add_fill_layer(
    id = "gdp",
    source = europe_nuts,
    fill_color = quantile_expr$expression,
    fill_opacity = 0.7,
    popup = concat(
      "GDP per capita: ",
      number_format(
        get_column("gdp_per_capita"), 
        style = "currency",
        currency = "EUR",
        maximum_fraction_digits = 0
      )
    )
  ) |> 
  add_categorical_legend(
    legend_title = "GDP per Capita (€)",
    values = get_legend_labels(quantile_expr, format = "compact", prefix = "€"),
    colors = get_legend_colors(quantile_expr),
    style = eu_legend_style
  )

maplibre(style = maptiler_style("basic", variant = "dark")) |>
  set_projection("globe") |>
  add_pmtiles_source(
    id = "places-source",
    url = "https://overturemaps-tiles-us-west-2-beta.s3.amazonaws.com/2025-06-25/places.pmtiles"
  ) |>
  add_circle_layer(
    id = "places-layer",
    source = "places-source",
    source_layer = "place",
    circle_color = "cyan",
    circle_opacity = 0.7,
    circle_radius = 4,
    tooltip = concat(
      "Name: ",
      get_column("@name"),
      "<br>Confidence: ",
      number_format(get_column("confidence"), maximum_fraction_digits = 2)
    )
  )
