#' highlight_map UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_highlight_map_ui <- function(id) {
  ns <- NS(id)
  tagList( 
  )
}
    
#' highlight_map Server Functions
#'
#' @noRd 
#' highlight_map Server Functions
#'
#' @noRd 
mod_highlight_map_server <- function(id, dat_filt, map_inputs, map_selection) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    # add select to map
    observeEvent(map_selection$sites, {
      df <- dat_filt()
      df <- df 
      req(df)
      params <- unique(dat_filt()$LabelName)
      leaflet::leafletProxy(ns("map")) |> leaflet::clearGroup("selected")
      if (is.null(map_selection$sites) || length(map_selection$sites) == 0) {
        return()
      }
      # otherwise plot the selection
      selected_df <- df[df$Site %in% map_selection$sites, , drop = FALSE] 
      if (nrow(selected_df) == 0) return()
      leaflet::leafletProxy(ns("map")) |>
        leaflet::clearGroup("selected") |>
        leaflet::addCircleMarkers(
          data = selected_df,
          lng = ~Longitude,
          lat = ~Latitude,
          color = "#0ce02fcc",
          fillColor = "#0ce02fcc",
          fillOpacity = 1,
          radius = 7,
          options = leaflet::pathOptions(className = "leaflet-selected-marker"),
          group = "selected",
          popup = 
            ~render_template(
              "leaflet_popup", 
              Result = Result,
              Site = Site,
              WaterBody = WaterBody,
              SiteDescription = SiteDescription,
              Precip72Hr = Precip72Hr,
              HoursDry = HoursDry,
              Color = Color,
              WeatherStation = WeatherStation
  )
        )
    }) 
}     
  )}
    
## To be copied in the UI
# mod_highlight_map_ui("highlight_map_1")
    
## To be copied in the server
# mod_highlight_map_server("highlight_map_1")
