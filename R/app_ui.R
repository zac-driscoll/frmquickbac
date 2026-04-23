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
      tags$script(src = "www/loc-map.js"),
      tags$script(src = "https://cdn.jsdelivr.net/npm/d3-textwrap@3/dist/d3-textwrap.min.js"),
      tags$link(rel = "stylesheet", type = "text/css", href = "www/custom.css"),
    ),

    fresh::use_theme(bs4DashTheme),

    bs4Dash::bs4DashPage(
      title = 'Best Bacteria Report',
      dark = NULL,
      help = NULL,
      fullscreen = TRUE,
      header = bs4Dash::bs4DashNavbar(
        title = "Best Bacteria Report",
        skin = "light"
      ),
      sidebar = bs4Dash::bs4DashSidebar(
        skin = "dark",
        status = "primary",
        minified = TRUE,
    br(),
    tags$a(
      href = "https://www.mmsd.com/",
      target = "_blank",
      tags$img(
        src = "www/mmsd_logo.jpg", 
        style = "display:block; margin: 0 auto; width: 186px;"
      )
    ),
  tags$div(
    style = "padding: 12px 0;",
  ),
        mod_sidebar_menu_ui("sidebar_menu_1")
      ),
      body = bs4Dash::bs4DashBody(
        mod_dashboard_body_ui("dashboard_body_1")
      ),
      footer = bs4Dash::bs4DashFooter(left = "Best Bacteria Report © 2026")
    )
  )
}
