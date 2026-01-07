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
  ns <- NS(id)
  tagList(
    bs4Dash::bs4Card(
      title = "",
      status = "primary",
      solidHeader = TRUE,
      width = 12,
      closable = FALSE,
      collapsible = TRUE,
      collapsed = FALSE,
    shiny::fluidRow(
      shiny::column(12,
    leaflet::leafletOutput(ns('map'), height = '998px')))
  ))
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

    # render map --------------------------------------------------------------
    output$map <- leaflet::renderLeaflet({
        leaflet::leaflet() |>
          leaflet::addProviderTiles(leaflet::providers$Esri.WorldStreetMap, group = "Street Map") |>
          leaflet::addProviderTiles(leaflet::providers$Esri.WorldImagery, group = "Satellite") |>
          leaflet::setView(lng = -87.99, lat = 43.15, zoom = 11) |>
          leaflet::addLayersControl(baseGroups = c("Street Map", "Satellite"))
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
        opacity = 0.7,
        fillOpacity = 0.4,
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

  # ---- Sites (points) ----
  df <- dat_filt()

  # If no records, show message and stop (map is already cleared)
  if (is.null(df) || nrow(df) == 0) {
    proxy |>
      leaflet::addControl(
        html = "<b style='color:red;font-size:16px;'>No data available for this selection — please change filters.</b>",
        position = "topright"
      )
    return()
  }

  params <- unique(df$LabelName)[1]
  color_pal <- if (grepl("Oxygen", params)) c("red", "orange", "blue") else rev(c("red", "orange", "blue"))
  pal <- leaflet::colorNumeric(palette = color_pal, domain = df$Result)

  df <- dplyr::mutate(df, Color = pal(Result))

  proxy |>
    leaflet::addCircleMarkers(
      data = df,
      lng = ~Longitude, lat = ~Latitude,
      color = "black", weight = 1,
      fillColor = ~pal(Result), fillOpacity = 1,
      group = "sites",
      options = leaflet::pathOptions(zIndex = 600),
      popup = ~render_template(
        "leaflet_popup",
        Result = Result,
        Site = Site,
        WaterBody = WaterBody,
        SiteDescription = SiteDescription,
        Precip72Hr = Precip72Hr,
        HoursDry = HoursDry,
        Color = Color
      )
    )

  # Legends (only when df has rows)
  proxy |>
    leaflegend::addLegendNumeric(pal = pal, values = df$Result, position = "bottomright", title = params) |>
    leaflegend::addLegendFactor(
      pal = pal2,
      values = unique(mke_basin_sf_filt()$HUC10_NAME),
      title = "Watersheds",
      position = "bottomright"
    )
})
 })

  })
}
## To be copied in the UI
# mod_leaflet_map_ui("leaflet_map_1")
    
## To be copied in the server
# mod_leaflet_map_server("leaflet_map_1")
