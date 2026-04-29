#' plot_create_html_tbl UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_plot_create_html_tbl_ui <- function(id) {
  ns <- NS(id)
  tagList(
 
  )
}
    
#' plot_create_html_tbl Server Functions
#'
#' @noRd 
mod_plot_create_html_tbl_server <- function(id, df, param_name, n_digits){
  moduleServer(id, function(input, output, session){
    ns <- session$ns
    generate_summary_table <- function(
      df, current_color = "#064789", other_color = "#219E63",  digits = n_digits) {

  # Build a compact frame we can glue safely
  if(nrow(df) == 0){
glue::glue("
  <div style='
    text-align:center; 
    background-color:#F1F9FF; 
    border:1px solid #A9CCE3; 
    border-radius:8px; 
    padding:8px; 
    font-size:1.1rem;
    margin-top:10px;'>
    No data available for this selection
  </div>")
  } else {
  current_year <-  colnames(df)[3]
  tbl <- df %>%
    dplyr::transmute(
      Metric  = .data$name,
      current = .[[colnames(df)[3]]],
      other   = .[["Other"]]
    )

fmt_num <- function(x) {
  ifelse(
    is.na(x),
    "-",
    formatC(x, format = "f", big.mark = ",", digits = digits)
  )
}

  # Build all rows FIRST (no nested glue in the outer template)
  rows_html <- glue::glue_data(
    tbl,
    "<tr>
       <td style='padding:10px 14px; text-align:left; font-weight:600; font-size:1.1em; border-bottom:1px solid #e7e7e7;'>{Metric}</td>
       <td style='padding:10px 14px; text-align:right; color:{current_color}; font-weight:700;  font-size:1.1em; border-bottom:1px solid #e7e7e7;'>{fmt_num(current)}</td>
       <td style='padding:10px 14px; text-align:right; color:{other_color};   font-weight:700; font-size:1.1em; border-bottom:1px solid #e7e7e7;'>{fmt_num(other)}</td>
     </tr>"
  ) |> glue::glue_collapse(sep = "\n")
      

  # Now inject the prebuilt rows string into the outer template
  render_template(
    "plot_table", 
    current_year = current_year,
    current_color = current_color, 
    other_color = other_color, 
    rows_html = rows_html
  )
}
    }

html_table <- generate_summary_table(df)

# ---- Example: print or return to Shiny ----
html_table

  })
}
    
## To be copied in the UI
# mod_plot_create_html_tbl_ui("plot_create_html_tbl_1")
    
## To be copied in the server
# mod_plot_create_html_tbl_server("plot_create_html_tbl_1")
