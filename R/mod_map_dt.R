#' map_dt UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
#' map_dt UI Function
#'
#' @description A shiny Module.
#' @noRd
#' @importFrom shiny NS tagList 
#' map_dt UI Function
#'
#' @description A shiny Module.
#' @noRd
#' map_dt UI Function
#'
#' @description A shiny Module.
#' @noRd
mod_map_dt_ui <- function(id) {
  ns <- NS(id)

  bs4Dash::bs4Card(
    title = shiny::uiOutput(ns("table_title")),
    status = "primary",
    solidHeader = TRUE,
    width = 12,
    closable = FALSE,
    collapsible = TRUE,
    collapsed = FALSE,

    shiny::uiOutput(ns("text")),



    DT::DTOutput(ns("map_dt"))
  )
}


#' map_dt Server Function
#' @noRd 
#' map_dt Server Function
#' @noRd 
mod_map_dt_server <- function(id, dat_filt, map_inputs, map_selection) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
  shiny::observe({
survey_dat <- unique(dat_filt()$Date)
params <- unique(dat_filt()$LabelName)
output$text <- renderUI({
  shiny::HTML(
    glue::glue("
      <div style='background-color: #dee6f2;
                  border-left:4px solid  #0B85BD;
                  padding:10px;
                  border-radius:6px;
                  margin-bottom:10px;'>
        <div style = 'font-size:0.8rem;'>
          <b style='color:#d9534f;'>Tip:</b>
          Click a point(s) in the table to highlight a site on the map.
        </div>
      </div>
      <hr style='margin-top:10px; margin-bottom:10px;'>"
    )
  )
})
  })

      shiny::observe({
      df <- dat_filt()
      params <- unique(dat_filt()$LabelName)
      if (nrow(df) == 0) {
        output$map_dt <- DT::renderDataTable(
          DT::datatable(
            data.frame(Message = "No data available for this selection"),
            options = list(dom = 't')
          )
        )
      } else {
        # your color palette logic
        if (grepl("Oxygen", params)) {
          color_pal <- c("red", "orange", "blue")
        } else {
          color_pal <- rev(c("red", "orange", "blue"))
        }
        pal <- leaflet::colorNumeric(
          palette = color_pal,
          domain  = df$Result
        )

 output$table_title <- shiny::renderUI({
  df <- dat_filt()

  req(nrow(df) > 0)

  parameter <- unique(df$LabelName)
  units <- unique(df$Units)

  parameter <- parameter[1]
  units <- units[1]

  shiny::HTML(glue::glue(
    "Results: {parameter} ({units})"
  ))
})


output$map_dt <- DT::renderDataTable({
  rng <- range(df$Result, na.rm = TRUE)

  DT::datatable(
    dplyr::select(df, Time, Site, Result, SiteDescription, Color) |>
      dplyr::arrange(dplyr::desc(Result)),
    rownames = FALSE,
    selection = "multiple",
    extensions = "FixedHeader",
    options = list(
      scrollX = TRUE,

      # IMPORTANT: scrollY must be a CSS size string (not TRUE)
      scrollY = "17vh",  # tweak this number to taste
      scrollCollapse = TRUE,
      dom = "tip",

      # Fixed header config (offset helps in bs4Dash layouts)
      fixedHeader = list(header = TRUE, headerOffset = 80),

      pageLength = 50,
      paging = TRUE,
      autoWidth = TRUE,
      responsive = TRUE,

      columnDefs = list(
        list(visible = FALSE, targets = 4),  # hide Color column
        list(className = "dt-center", targets = "_all")  # 👈 center headers
      )
    )
  ) |>
    DT::formatStyle(
      columns = c("Time", "Site", "Result", "SiteDescription"),
      valueColumns = "Color",
      color = DT::styleValue()
    )
})

observeEvent(input$map_dt_rows_selected, 
  { df <- dat_filt() 
    df <-  df |> dplyr::arrange(desc(Result))
    selected_sites <- df$Site[input$map_dt_rows_selected] 
    selected_sites <- selected_sites
    map_selection$sites <- selected_sites },
        ignoreNULL = FALSE
  )
      }
      })
  })
}