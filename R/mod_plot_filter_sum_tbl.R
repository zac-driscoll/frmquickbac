#' plot_filter_sum_tbl UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_plot_filter_sum_tbl_ui <- function(id) {
  ns <- NS(id)
  tagList()
}
    
#' plot_filter_sum_tbl Server Functions
#'
#' @noRd 
mod_plot_filter_sum_tbl_server <- function(id, selected_inputs, param){
  moduleServer(id, function(input, output, session){
    ns <- session$ns
    dat <- load_survey_data()
    shiny::reactive({
    year <- selected_inputs()[["years"]] 
    site <- selected_inputs()[["site"]]
      dat |>
        dplyr::filter(SiteCode == site) |> 
        dplyr::filter(LabelName == param) |>
        dplyr::collect() |> 
        dplyr::mutate(CurrentYear = dplyr::if_else(Year == year, as.character(year), 'Other')) |>
        dplyr::group_by(CurrentYear, LabelName) |>
        dplyr::summarise(
          Maximum = max(ReadingNum, na.rm = TRUE),
          Mean= mean(ReadingNum, na.rm = TRUE),
          Median = median(ReadingNum, na.rm = TRUE),
          Minimum = min(ReadingNum, na.rm = TRUE)
        ) |>
        tidyr::pivot_longer(
          cols = c("Maximum", "Mean", "Median", "Minimum")
        )  |>
          tidyr::pivot_wider(names_from = CurrentYear, values_from = value)
    })
    })
}
    
## To be copied in the UI
# mod_plot_filter_sum_tbl_ui("plot_filter_sum_tbl_1")
    
## To be copied in the server
# mod_plot_filter_sum_tbl_server("plot_filter_sum_tbl_1")
