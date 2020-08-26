
<!-- README.md is generated from README.Rmd. Please edit that file -->

# shinyPostgreSQL

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
<!-- badges: end -->

The goal of shinyPostgreSQL is to allow a Shiny application to
authenticate with a PostgreSQL database by prompting a user for
appropriate credentials and forming a DBI connection object.

## Installation

You can install the released version of shinyPostgreSQL from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("thewileylab/shinyPostgreSQL")
```

## Example

To run a demo application:

``` r
shinyPostgreSQL::run_app()
```

## Usage

To integrate shinyPostgreSQL with your Shiny application place
`postgresql_setup_ui()` and `postgresql_setup_server()` functions into
your applications ui and server functions respectively.

``` r
library(shiny)
library(shinyPostgreSQL)
ui <- fluidPage(
  tags$h2('Connect to BigQuery UI'),
  postgresql_setup_ui(id = 'setup-namespace')
  )

server <- function(input, output, session) {
  postgresql_setup_vars <- postgresql_setup_server(id = 'setup-namespace')
}

if (interactive())
  shinyApp(ui = ui, server = server, options = list(port = 8100, launch.browser = T))
```

## Code of Conduct

Please note that the shinyPostgreSQL project is released with a
[Contributor Code of
Conduct](https://contributor-covenant.org/version/2/0/CODE_OF_CONDUCT.html).
By contributing to this project, you agree to abide by its terms.
