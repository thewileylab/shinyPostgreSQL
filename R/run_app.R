#' Run the Shiny Application
#'
#' @param ... A series of options to be used inside the app.
#'
#' @export
#' @importFrom shiny shinyApp
#' @importFrom golem with_golem_options
run_app <- function(
  ...
) {
  with_golem_options(
    app = shinyApp(
      ui = app_ui, 
      server = app_server
    ), 
    golem_opts = list(...)
  )
}
#' shinyPostgreSQL: Access PostgreSQL databases with R Shiny
#' 
#' A shiny module to authenticate your R Shiny Application with a PostgreSQL database.
#' 
#' 
#' @docType package
#' @name shinyPostgreSQL
NULL
#> NULL