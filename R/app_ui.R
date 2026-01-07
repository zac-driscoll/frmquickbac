#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_ui <- function(request) {
  shiny::tagList(
    golem_add_external_resources(),

    tags$head(
        tags$style(HTML("
    body {
      cursor: url('boat.png') 16 16, auto !important;
    }
  ")),
      tags$script(src = "d3.v7.min.js"),
      tags$script(src = "d3_bar_module.js")
    ),

    fresh::use_theme(bs4DashTheme),

    bs4Dash::bs4DashPage(
      title = 'Quick Bacteria Report',
      header = bs4Dash::bs4DashNavbar(
        title = "Quick Bacteria Report",
        skin = "light"
      ),
      sidebar = bs4Dash::bs4DashSidebar(
        skin = "dark",
        status = "primary",
        mod_sidebar_menu_ui("sidebar_menu_1")
      ),
      body = bs4Dash::bs4DashBody(
        mod_dashboard_body_ui("dashboard_body_1")
      ),
      footer = bs4Dash::bs4DashFooter(left = "Quick Bacteria Report © 2025")
    )
  )
}
