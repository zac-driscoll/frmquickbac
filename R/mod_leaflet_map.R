#' leaflet_map Server Functions
#'
#' @noRd 
#' leaflet_map UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_leaflet_map_ui <- function(id) {
  ns <- shiny::NS(id)
  bs4Dash::bs4Card(
    title = "Map of Survey Results",
    status = "primary",
    solidHeader = TRUE,
    width = 12,
    closable = FALSE,
    collapsible = TRUE,
    collapsed = FALSE,
    div(
      style = "height: 79vh; min-height: 400px;",
      leaflet::leafletOutput(ns("map"), height = "100%")
    )
  )
}
    
#' leaflet_map Server Functions
#'
#' @noRd 
mod_leaflet_map_server <- function(id, dat_filt, map_inputs, map_selection) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns


    mke_basin_sf_filt <- reactive({
      watershed <- unique(dat_filt()$Watershed) 
      bas  <- mke_basin_sf
      if (is.null(watershed) || !("HUC10_NAME" %in% names(bas))) {
        return(bas[0, , drop = FALSE])
      }
      idx <- bas$HUC10_NAME %in% watershed
      out <- bas[idx, , drop = FALSE]
      if (nrow(out) == 0) bas[0, , drop = FALSE] else out
    })

mke_rivers_sf_filt <- reactive({
  watershed <- unique(dat_filt()$Watershed) 
  riv <- mke_rivers_sf
  if (is.null(watershed)) return(riv[0, , drop = FALSE])
  riv[riv$HUC10_NAME %in% watershed, , drop = FALSE]
}) 
    
ws_lookup_sf_filt <- reactive({
  ws_in_dat <- unique(dat_filt()$WeatherStation) 
  ws_lookup_sf <- ws_lookup_sf
  if (is.null(ws_in_dat)) return(ws_lookup_sf[0, , drop = FALSE])
  ws_lookup_sf[ws_lookup_sf$WeatherStation %in% ws_in_dat, , drop = FALSE]
}) 
  
    # render map --------------------------------------------------------------
    output$map <- leaflet::renderLeaflet({
        leaflet::leaflet() |>
          leaflet::addProviderTiles(leaflet::providers$CartoDB.Positron, group = "Simple") |>
          leaflet::addProviderTiles(leaflet::providers$Esri.WorldStreetMap, group = "Street Map") |>
          leaflet::addProviderTiles(leaflet::providers$Esri.WorldImagery, group = "Satellite") |>
          leaflet::addProviderTiles(leaflet::providers$Stadia.StamenWatercolor, group = "WaterColor") |>
          leaflet::setView(lng = -87.99, lat = 43.15, zoom = 10) |>
          leaflet::addLayersControl(
            baseGroups = c("Simple", "Street Map", "Satellite", "WaterColor"),
            overlayGroups = c("WeatherStations")
      ) 
    }) 
#circle markers
observe({
observe({
  proxy <- leaflet::leafletProxy(ns("map"))

  # Always clear dynamic layers/controls first so stale stuff never persists
  proxy |>
    leaflet::clearGroup("basins") |>
    leaflet::clearGroup("rivers") |>
    leaflet::clearGroup("sites") |>
    leaflet::clearGroup("weather_stations") |>
    leaflet::clearControls()

  # ---- Basins (polygons) ----
  watershed_levels <- c("Cedar Creek", "Menomonee River", "Kinnickinnic River", "Lower Milwaukee River")
  pal2 <- leaflet::colorFactor(palette = "viridis", domain = watershed_levels)

  bas <- mke_basin_sf_filt()
  if (inherits(bas, "sf") && nrow(bas) > 0) {
    proxy |>
      leaflet::addPolygons(
        data = bas,
        group = "basins",
        options = leaflet::pathOptions(zIndex = 200),
        color = "gray50",
        opacity = 0.8,
        fillOpacity = 0.36,
        weight = 1,
        fillColor = ~pal2(HUC10_NAME)
      )
  }

  # ---- Rivers ----
  riv <- mke_rivers_sf_filt()
  if (inherits(riv, "sf") && nrow(riv) > 0) {
    proxy |>
      leaflet::addPolylines(
        data = riv,
        color = "blue",
        weight = 2,
        group = "rivers",
        options = leaflet::pathOptions(zIndex = 400)
      )
  }

  # ---- Rivers ----
  ws <- ws_lookup_sf_filt()
  if (inherits(riv, "sf") && nrow(riv) > 0) {
    proxy |>
      leaflet::addCircleMarkers(
        data = ws,
        color = "black",
        fillColor = "gray80",
        fillOpacity = 0.5,
        weight = 2,
        radius = 5,
        group = "WeatherStations",
        popup = ~render_template(
        "ws_popup",
        WeatherStation = WeatherStation,
        Description = Description
              ),
        options = leaflet::pathOptions(zIndex = 9999)
      )
  }

  # ---- Sites (points) ----
  df <- dat_filt()

  # If no records, show message and stop (map is already cleared)
  if (is.null(df) || nrow(df) == 0) {
    proxy |>
      leaflet::addControl(
        html = "<b style='color:red;font-size:1.2rem;'>No data available for this selection — please change filters.</b>",
        position = "topright"
      )
    return()
  }

  proxy |>
    leaflet::addCircleMarkers(
      data = df,
      lng = ~Longitude, 
      lat = ~Latitude,
      color = "black", 
      weight = 1,
      fillColor = ~Color,
      radius = 7,
      fillOpacity = 1,
      group = "sites",
      options = leaflet::pathOptions(zIndex = 600),
      popup = ~render_template(
        "leaflet_popup",
        Result = Result,
        Site = Site,
        WaterBody = WaterBody,
        SiteDescription = SiteDescription,
        Time = Time,
        Precip72Hr = Precip72Hr,
        HoursDry = HoursDry,
        Color = Color,
        WeatherStation = WeatherStation
      )
    )

  # Legends (only when df has rows)
  proxy |>
    leaflet::addControl(
      html = htmltools::HTML(
        build_leaflet_legend(watersheds = 1)
      ),
      position = "bottomleft"
  )
})
})
  })
}
## To be copied in the UI
# mod_leaflet_map_ui("leaflet_map_1")
    
## To be copied in the server
# mod_leaflet_map_server("leaflet_map_1")
