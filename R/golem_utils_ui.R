#' Add external resources to the app
#'
#' This function is used internally by golem to add external
#' resources (CSS, JS, favicons, etc.)
#' @noRd
golem_add_external_resources <- function(){
  addResourcePath('www', app_sys('app/www'))

  tags$head(
    tags$meta(
      name = "viewport",
      content = "width=device-width, initial-scale=1, maximum-scale=1"
    ),
    golem::favicon(),
    golem::bundle_resources(
      path = app_sys('app/www'),
      app_title = "Quick Bacteria Report"
    )

  )
}