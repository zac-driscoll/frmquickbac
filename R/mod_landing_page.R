#' landing_page UI Function
#'
#' @noRd
mod_landing_page_ui <- function(id) {
  ns <- NS(id)
    # Top row: text left, image right
  shiny::tagList(
    shiny::fluidRow(
    shiny::column(
      width = 6,
      bs4Dash::bs4Card(
        title = "Background",
        width = 12,
        status = "primary",
        solidHeader = TRUE,
        tags$div(
          shiny::HTML(
          glue::glue(            
            "<span style='font-size:1.25rem;'>The Milwaukee Metropolitan Sewerage District (MMSD) monitors X stations for bacterial indicators (<i> E. coli </i> and fecal coliform). ",
            "Samples are collected bimonthly from April through October and monthly from November through March. ",
            "<i> E. coli </i> is the primary indicator, with fecal coliform collected at X stations as a supplemental measure. ",
            "Dissolved oxygen is also measured using a YSI sonde. </span>"
          )
        )
        )
      ),
     bs4Dash::bs4Card(
  title = "Water Quality Standards",
  width = 12,
  status = "primary",
  solidHeader = TRUE,

  tags$div(
    style = "font-size:1.25rem",
    "Wisconsin’s Consolidated Assessment and Listing Methodology (WisCALM) is updated every two years and provides guidance for ",
    "assessing water quality data against surface water quality standards and for Clean Water Act reporting. ",
    "Within this dashboard, WisCALM thresholds are used as reference points for interpretation."
  ),
  tags$br(),
  tags$div(
    style = "font-size:1.25rem;",
    tags$ul(
      tags$li("E. coli standard: x (samples exceeding this value are considered exceedances)"),
      tags$li("Fecal coliform standard: y (samples exceeding this value are considered exceedances)"),
      tags$li("Dissolved oxygen standard: z (samples below this value are considered exceedances)")
    )
  )
),      
bs4Dash::bs4Card(
        title = "Weather Stations",
        width = 12,
        status = "primary",
        solidHeader = TRUE,
tags$div(
  shiny::HTML(
    glue::glue(
      "<span style='font-size:1.25rem;'>",
      "MMSD also maintains <a href='https://www.mmsd.com/about-us/milwaukee-rain-facility-information' target='_blank' style='color:#0E67A0; font-weight:600;'>a network of weather stations</a> distributed throughout its service area to monitor precipitation. ",
      "For reporting purposes, each water quality monitoring site is paired with the geographically closest weather station. ",
      "Precipitation values shown in this report reflect data from that nearest station at the time the sample was collected. ",
      "The 72-hour precipitation metric represents the total inches of rainfall recorded during the 72 hours preceding the sampling time at the closest weather station. ",
      "</span>"
    )
  )
)
)
  ),
      shiny::column(
        width = 6,
        bs4Dash::bs4Card(
          title = "Monitoring",
          width = 12,
        status = "primary",
        solidHeader = TRUE,
        div(
            style = "margin: -1rem -1rem 0 -1rem;",
            tags$img(
              src = "www/pelagos.jpg",
              alt = "Bacteria report image",
              style = "
                width: 100%;
                height: auto;
                display: block;
              "
            )
          )
        )
      )
    )
  )
}

#' landing_page Server Functions
#'
#' @param sites data.frame with columns: lat, lon, site_name (customize if needed)
#' @noRd
mod_landing_page_server <- function(id, sites = NULL) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
  })
}
