# UI ----
#' BigQuery Setup UI
#'
#' This module is designed to guide a user through the process of authenticating with a PostgreSQL database. It is responsible for creating a DBI connection object to a PostgreSQL database.
#' @param id The Module namespace
#'
#' @return The PostgreSQL Setup UI
#' @export
#' 
#' @importFrom shiny NS tagList 
postgresql_setup_ui <- function(id){
  ns <- NS(id)
  tagList(
    golem_add_external_resources()
 
  )
}


# Server ----    
#' mod_PostgreSQL_setup Server Function
#'
#' @param id The PostgreSQL Setup UI
#'
#' @return PostgreSQL connection variables and DBI connection object.
#' @export
#' 
postgresql_setup_server <- function(id) {
  moduleServer(
    id,
    function(input, output, session) {
      ns <- session$ns
      ## PostgreSQL Setup Values ----
      postgresql_setup <- reactiveValues(
        ### Module Info
        moduleName = 'PostgreSQL',
        moduleType = 'database',
        ui = shinyPostgreSQL::postgresql_setup_ui(id),
        ### Connection Variables
        )
      }
    )
  }
