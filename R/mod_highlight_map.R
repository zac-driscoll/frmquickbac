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

      # color logic
      if (grepl("Oxygen", params)) {
        color_pal <- c("red", "orange", "blue")
      } else {
        color_pal <- rev(c("red", "orange", "blue"))
      }

      pal <- leaflet::colorNumeric(palette = color_pal, domain = df$Result)
      selected_df <- dplyr::bind_cols(selected_df ,data.frame(Color = pal(selected_df$Result))) 

      leaflet::leafletProxy(ns("map")) |>
        leaflet::clearGroup("selected") |>
        leaflet::addCircleMarkers(
          data = selected_df,
          lng = ~Longitude,
          lat = ~Latitude,
          color = "red",
          fillColor = "red",
          fillOpacity = 1,
          radius = 11,
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
              Color = Color
  )
        )
    }) 
}     
  )}
    
## To be copied in the UI
# mod_highlight_map_ui("highlight_map_1")
    
## To be copied in the server
# mod_highlight_map_server("highlight_map_1")
