#' The application User-Interface
#' 
#' @param request Internal parameter for `{shiny}`. 
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_ui <- function(request) {
  tagList(
    fluidPage(
      h1("shinyPostgreSQL"), 
      actionButton(inputId = 'debug', label = 'Debug!'),
      postgresql_setup_ui('postgresql-setup')
    )
  )
}
