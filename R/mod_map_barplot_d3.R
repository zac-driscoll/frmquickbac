#' map_barplot_d3 UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_map_barplot_d3_ui <- function(id) {
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

   #   shiny::uiOutput(ns("text")),
      r2d3::d3Output(ns("bar_plotter"), height = '1000px')
    )
  )
}
    

#' map_barplot Server Functions
#'
#' @noRd
mod_map_barplot_d3_server <- function(id, dat) {
  moduleServer(id, function(input, output, session) {

    # ------------------------------
    # Heading Text
    # ------------------------------
   

    # ------------------------------
    # D3 Plot
    # ------------------------------
    output$bar_plotter <- r2d3::renderD3({

df <- dat()

param <- unique(df$LabelName)[1]

color_pal <- if (grepl("Oxygen", param)) {
  c("red", "orange", "blue")
} else {
  rev(c("red", "orange", "blue"))
}

pal <- leaflet::colorNumeric(
  palette = color_pal,
  domain = df$Result
)

df <- df |>
  dplyr::mutate(
    Color = as.character(pal(Result))
  ) |>
  dplyr::rowwise() |>
  dplyr::mutate(
    TooltipHTML = render_template(
      "site_tooltip",
      Site            = Site,
      SiteDescription = SiteDescription,
      Result          = Result,
      Precip72Hr      = Precip72Hr,
      HoursDry        = HoursDry,
      Color           = Color
    )
  ) |>
  dplyr::ungroup()

no_records <- nrow(df) == 0

units <- if (!no_records) unique(df$Units) else NA_character_
is_do <- if (!no_records) grepl("Oxygen", unique(df$LabelName)[1]) else FALSE
survey_dat <- if (!no_records) unique(df$Date) else NA
param <- if (!no_records) unique(df$LabelName) else "No data"

title <- if (!no_records) {
  glue::glue("Survey Results for {param}")
} else {
  "Survey Results"
}

subtitle <- if (!no_records) {
  glue::glue("Date: {survey_dat}")
} else {
  "No records available for this selection"
}
min_precip <- min(df$Precip72Hr)      
max_precip <- max(df$Precip72Hr)      
precip_title <- glue::glue("Precipitation Range: {min_precip} - {max_precip} Inches")     
info_html <- readr::read_file("inst/app/templates/precip_info_box.html")

r2d3::r2d3(
  data = df,
  script = "inst/app/www/barplot.js",
  options = list(
    sort_desc  = is_do,
    units      = units,
    title      = title,
    subtitle   = subtitle,
    no_records = no_records,
    precip_title = precip_title,
    info_html = info_html  

  ),
  d3_version = "5"
)

    })
  })
}

## To be copied in the UI
# mod_map_barplot_ui("map_barplot_1")

## To be copied in the server
# mod_map_barplot_server("map_barplot_1")
