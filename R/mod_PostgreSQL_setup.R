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
    golem_add_external_resources(),
    div(id = ns('postgresql_connect_div'),
        shinydashboard::box(title = 'Connect to PostgreSQL Database',
                            width = '100%',
                            status = 'primary',
                            solidHeader = F,
                            HTML('To connect to a PostgreSQL Database, please provide your credentials.<br><br>'),
                            br(),
                            textInput(inputId = ns('dbname'), label = 'Database Name:'),
                            textInput(inputId = ns('host'), label = 'Hostname:', placeholder = 'ec2-54-83-201-96.compute-1.amazonaws.com'),
                            textInput(inputId = ns('port'), label = 'Port:', value = 5432),
                            textInput(inputId = ns('username'), label = 'Username:'),
                            passwordInput(inputId = ns('password'), label = 'Password:'),
                            actionButton(inputId = ns('connect'),
                                         label = 'Connect',
                                         icon = icon(name = 'database')
                            )
        )
    )
 
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
#' @importFrom DBI dbConnect
#' @importFrom RPostgres Postgres
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
        is_connected = 'no',
        db_con = NULL,
        dbname = NULL,
        host = NULL,
        port = NULL,
        user = NULL,
        password = NULL
        )
      
      ## Observe Connect Button ----
      observeEvent(input$connect,{
        postgresql_setup$db_con <- tryCatch({
          DBI::dbConnect(RPostgres::Postgres(),
                         dbname = input$dbname, 
                         host = input$host, # i.e. 'ec2-54-83-201-96.compute-1.amazonaws.com'
                         port = input$port, # or any other port specified by your DBA
                         user = input$user,
                         password = input$password
                         )
          }, warning = function(w) {
            message(glue::glue('{w}'))
            return('connection_warning')
          }, error = function(e) {
            message(glue::glue('{e}'))
            return('connection_error')
            }
          )
        })
      
      ## Monitor DBI Connection Object  ----
      ### Check for valid connection information
      observeEvent(postgresql_setup$db_con, {
        if(postgresql_setup$db_con %>% class() == 'PostgreSQLConnection') {
          postgresql_setup$is_connected <- 'yes'
          postgresql_setup$dbname <- input$dbname
          postgresql_setup$host <- input$host
          postgresql_setup$port <- input$port
          postgresql_setup$user <- input$user
        }
      })
      return(postgresql_setup)
      }
    )
}
