#' plot_dat UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_plot_dat_d3_ui <- function(id) {
  ns <- NS(id)
  tagList(
    bs4Dash::bs4Card(
  title = "Site Map",
  status = "primary",       # 💙 keeps the header color
  solidHeader = TRUE,
  width = 12,
  collapsible = TRUE,
  closable = FALSE,
  collapsed = FALSE,
  div(

    #style = "background-color:#F1F9FF; border:1px solid #A9CCE3; border-radius:8px; padding:10px;",
    shiny::fluidRow(
      shiny::column(12,
        shiny::tags$span(
      id = ns("loc_map_ns"),
      `data-ns` = ns(""),
      style = "display:none;"
    ),    
      shiny::htmlOutput(ns("title"), height = '100%'))
    ),
    r2d3::d3Output(ns("ts_plot"), height = '68vh')

  )
)
)
}
#' plot_dat Server Functions
#'
#' @noRd 
mod_plot_dat_d3_server <- function(id, dat){
  moduleServer(id, function(input, output, session){
    ns <- session$ns
    observeEvent(input$open_loc_map, {

  showModal(modalDialog(
    title = "Survey Site & Weather Station Location",
    leaflet::leafletOutput(ns("loc_map"), height = 500),
    easyClose = TRUE,
    size = "l",
    footer = modalButton("Close")
  ))
})

output$loc_map <- leaflet::renderLeaflet({

  site_info <-
    dat () |>
    dplyr::filter(grepl("Results", type)) |>
    dplyr::slice(1)

  ws_info <-
    dat () |>
    dplyr::filter(grepl("Precip", type)) |>
    dplyr::slice(1)

#site label
  site_lon <- site_info$Longitude
  site_lat <- site_info$Latitude
  site_code <- site_info$SiteCode
  site_desc <- site_info$SiteDescription
  site_label <-
    render_template(
        "site_popup_simple",
        SiteCode = site_code,
        Description = site_desc
              )
#ws labels
  ws_lon   <- ws_info$Longitude
  ws_lat   <- ws_info$Latitude
  ws_code <- ws_info$station_id
  ws_desc <- ws_info$SiteDescription
  ws_label <-
    render_template(
        "ws_popup",
        WeatherStation = ws_code,
        Description = ws_desc
              )
  
  #legend

  leaflet::leaflet() |>
    leaflet::addProviderTiles("CartoDB.Positron") |>
    leaflet::addCircleMarkers(
      lng = site_lon,
      lat = site_lat, 
      color = "black",
      fillColor = "#2203E9",
      fillOpacity = 1,
      weight = 2,
      radius = 7, 
      popup = site_label) |>
    leaflet::addCircleMarkers(
      lng = ws_lon,
      lat = ws_lat,
      radius = 7,
      color = "black",
      fillColor = "gray80",
      fillOpacity = 0.5,
      weight = 2,
      popup = ws_label) |>
    leaflet::fitBounds(
      lng1 = min(site_lon, ws_lon),
      lat1 = min(site_lat, ws_lat),
      lng2 = max(site_lon, ws_lon),
      lat2 = max(site_lat, ws_lat)
    ) |>
        leaflet::addControl(
      html = htmltools::HTML(
        render_template("small_map_legend")
      ),
      position = "bottomleft"
  )
})

    # HTML Title
    output$title <- shiny::renderUI({
      site <- unique(dat()$SiteCode)
      year <- unique(stats::na.omit(dat()$Year))[1]
      SiteDescription <-   
        dat () |>
        dplyr::filter(grepl("Results", type)) |>
        dplyr::slice(1) |>
        dplyr::distinct(SiteDescription)

      shiny::HTML(glue::glue(
        readr::read_file("inst/app/templates/plot_title.html")
      ))
    })
    output$ts_plot <-  r2d3::renderD3({
      df <- 
        dat() |>
          dplyr::mutate(
            Color = dplyr::if_else(grepl("Historic", type), "#0e770eff", "#064789"),
            DatStr = format(as.Date(dat()$Date), "%Y-%m-%d")
          )
    r2d3::r2d3(
      data = df,
      script =  get_www_path("ts_plot.js"),
      d3_version = "5"
    )
    })
  })
}
