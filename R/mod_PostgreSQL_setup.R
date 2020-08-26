# UI ----
#' PostgreSQL Setup UI
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
                            # textInput(inputId = ns('schema'), label = 'Schema:'),
                            textInput(inputId = ns('host'), label = 'Hostname:', placeholder = 'ec2-54-83-201-96.compute-1.amazonaws.com'),
                            textInput(inputId = ns('port'), label = 'Port:', value = 5432),
                            textInput(inputId = ns('username'), label = 'Username:'),
                            passwordInput(inputId = ns('password'), label = 'Password:'),
                            uiOutput(ns('setup_connect_btn')),
                            uiOutput(ns('setup_connect_error'))
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
#' @importFrom magrittr %>% 
#' @importFrom glue glue
#' @importFrom magrittr extract
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
        # schema = NULL,
        host = NULL,
        port = NULL,
        user = NULL,
        password = NULL
        )
      ## Schema TBD (Ideally, we want this as part of the connection object)
      # https://stackoverflow.com/questions/42139964/setting-the-schema-name-in-postgres-using-r
      # https://github.com/r-dbi/DBI/issues/24
      # https://github.com/tomoakin/RPostgreSQL/issues/102
      
      ## Reactive UI Elements ----
      pg_connect_btn <- reactive({
        # Must enter SOMETHING in order to connect. Hide the connect button until "something" is added. 
        # I'm not your mother, use a password or don't. 
        req(input$dbname, 
            input$host,
            # input$schema,
            input$port, 
            input$username
            )
        # Add schema to conditions after testing
        if(input$dbname == '' | input$host == '' | input$port == '' | input$username == '') {
          return(NULL)
        } else {
          actionButton(inputId = ns('connect'), label = 'Connect', icon = icon(name = 'database') )
          }
        })
      
      pg_connect_error <- eventReactive(postgresql_setup$db_con_class, {
        req(postgresql_setup$db_con_class == 'character')
        if(postgresql_setup$db_con == 'connection_error' | postgresql_setup$db_con == 'connection_warning') {
          return(HTML("<font color='#e83a2f'>Please verify your PostgreSQL settings. For assistance with parameters, contact your database administrator.</font>"))
        } else {
          return(NULL)
          }
        })
      
      ## Observe Connect Button ----
      observeEvent(input$connect,{
        # browser()
        # Depending on PostgreSQL config, this tryCatch will be insufficient. Eg, my local PostgreSQL install will accept totally blank
        # connection info as valid, forming a temporary connection. Ideally, this would be combined with dbListTables() to verify that 
        # tables exist before storing a connection object.
        postgresql_setup$db_con <- tryCatch({
          DBI::dbConnect(RPostgres::Postgres(),
                         dbname = input$dbname, 
                         host = input$host, # i.e. 'ec2-54-83-201-96.compute-1.amazonaws.com'
                         port = input$port, # or any other port specified by your DBA
                         user = input$user,
                         password = input$password
                         # options = glue::glue('-c search_path={input$schema}') ## ensure this works with tbl(con, 'table_name') convention
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
      # If the conditions are sorted out appropriately in the previous chunk, this work flow should continue to function.
      observeEvent(postgresql_setup$db_con, {
        postgresql_setup$db_con_class <- postgresql_setup$db_con %>% class() %>% magrittr::extract(1)
        if(postgresql_setup$db_con_class == 'PqConnection') {
          message('DB Connection Established')
          postgresql_setup$is_connected <- 'yes'
          postgresql_setup$dbname <- input$dbname
          postgresql_setup$host <- input$host
          postgresql_setup$port <- input$port
          postgresql_setup$user <- input$user
        }
      })
      
      ## PostgreSQL Connection UI Outputs ----
      output$setup_connect_btn <- renderUI({ pg_connect_btn() })
      output$setup_connect_error <- renderUI({ pg_connect_error() })
      
      ## Return ----
      return(postgresql_setup)
      }
    )
}
