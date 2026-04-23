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
    title = "Plot of Results",
    status = "primary",
    solidHeader = TRUE,
    width = 12,
    closable = FALSE,
    collapsible = TRUE,
    collapsed = FALSE,
    shiny::htmlOutput(ns("html_header"), height = "100%"),
    r2d3::d3Output(ns("bar_plotter"), height = '67vh')
  )
)
}
#' map_barplot Server Functions
#'
#' @noRd
mod_map_barplot_d3_server <- function(id, dat) {
  moduleServer(id, function(input, output, session) {
    output$html_header <- shiny::renderUI({
       # ---- D3 Options ----
      df <- dat()
      no_records <- nrow(df) == 0
      survey_dat <- if (!no_records) unique(df$Date)[1] else NA
      param <- if (!no_records) unique(df$LabelName)[1] else "No data"
      title <- if (!no_records) {
        glue::glue("Survey Results for {param}")
      } else {
        "Survey Results"
      }
      subtitle <- if (!no_records) {
        glue::glue("{survey_dat}")
      } else {
        "No records available for this selection"
      }
      min_precip <- min(df$Precip72Hr)
      max_precip <- max(df$Precip72Hr)
      precip_title <- glue::glue(
        "{min_precip} - {max_precip} Inches"
      )
      shiny::HTML(glue::glue(
        render_template("ts_info_icon",
        title = title,
        date_range = survey_dat,
        precip_range = precip_title
      )))
    })

    output$bar_plotter <- r2d3::renderD3({
      # ---- Load data ----
      df <- dat()
      no_records <- nrow(df) == 0
      # ---- D3 Options ----
      param <- if (!no_records) unique(df$LabelName)[1] else "No data"
      units <- if (!no_records) unique(df$Units)[1] else NA_character_
      is_do <- if (!no_records) grepl("Oxygen", param) else FALSE
      survey_dat <- if (!no_records) unique(df$Date)[1] else NA
      wq_std <- if (is_do) 5 else 126
      title <- if (!no_records) {
        glue::glue("Survey Results for {param}")
      } else {
        "Survey Results"
      }
      subtitle <- if (!no_records) {
        glue::glue("{survey_dat}")
      } else {
        "No records available for this selection"
      }
      min_precip <- min(df$Precip72Hr)
      max_precip <- max(df$Precip72Hr)
      precip_title <- glue::glue(
        "{min_precip} - {max_precip} Inches"
      )
      info_html <- readr::read_file(
        "inst/app/templates/precip_info_box.html"
      )
      # ---- Color + tooltip logic ----
      df <- df |>
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
      # ---- D3 Plot ----
      r2d3::r2d3(
        data = df,
        script = "inst/app/www/barplot.js",
        css= "inst/app/www/barplot.js",
        options = list(
          sort_desc    = is_do,
          units        = units,
          title        = title,
          subtitle     = subtitle,
          no_records   = no_records,
          precip_title = precip_title,
          info_html    = info_html,
          wq_std       = wq_std
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
