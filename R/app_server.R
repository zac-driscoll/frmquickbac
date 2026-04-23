#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {
  mod_dashboard_body_server("dashboard_body_1")

  # data to be passed to widgets
  map_selections <- mod_selection_pane1_server("selection_pane1_1")
  filtered <- mod_filter_map_dat_server("filter_map_dat_1", map_selections)
  map_selection <- reactiveValues(sites = NULL)
    # widgets
  mod_leaflet_map_server(
      "leaflet_map_1", 
      filtered$survey_data,
      map_selections,
      map_selection
    )
  
  mod_map_server("map_1")
  mod_map_barplot_server("map_barplot_1", filtered$survey_data)
  mod_map_barplot_d3_server("map_barplot_d3_1", filtered$survey_data)
  mod_highlight_map_server("leaflet_map_1", filtered$survey_data, map_selections, map_selection)
  mod_map_dt_server("map_dt_1", filtered$survey_data, map_selections, map_selection)

  ### plot server
  selected_inputs <- mod_selection_panel_plot_server("plot_select1")
  plot_dat <- mod_plot_filter_plot_dat_server("plot_filter_plot_dat_1", selected_inputs)
  mod_plot_dat_d3_server("plot_dat_d3_1", plot_dat)
  mod_plot_dat_server("plot_dat_1", plot_dat)

  ecoli_dat <- mod_plot_filter_sum_tbl_server("plot_filter_sum_tbl_1", selected_inputs, "E. coli")
  do_dat <- mod_plot_filter_sum_tbl_server("plot_filter_sum_tbl_2", selected_inputs, "Dissolved Oxygen")
  fecal_dat <- mod_plot_filter_sum_tbl_server("plot_filter_sum_tbl_3", selected_inputs, "Fecal Coliform")
  mod_plot_sum_tbl_server("plot_sum_tbl_1", ecoli_dat, do_dat, fecal_dat)

### Download Table Server
  #selected_inputs_tbl <- mod_selection_pane_table_server("selection_pane_table_1")
  #tbl_dat <- mod_download_filter_tbl_dat_server("download_filter_tbl_dat_1", selected_inputs_tbl)
  tbl_dat <- mod_selection_pane_table_server("selection_pane_table_1")
  mod_download_table_dt_server("download_table_dt_1", tbl_dat)
}
