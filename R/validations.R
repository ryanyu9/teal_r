#' Validate that dataset has a minimum number of observations
#'
#' @description `r lifecycle::badge("stable")`
#' @param x a data.frame
#' @param min_nrow minimum number of rows in \code{x}
#' @param complete \code{logical} default \code{FALSE} when set to \code{TRUE} then complete cases are checked.
#' @param allow_inf \code{logical} default \code{TRUE} when set to \code{FALSE} then error thrown if any values are
#'   infinite.
#' @param msg (`character(1)`) additional message to display alongside the default message.
#'
#' @details This function is a wrapper for `shiny::validate`.
#'
#' @export
#'
#' @examples
#' library(teal)
#' ui <- fluidPage(
#'   sliderInput("len", "Max Length of Sepal",
#'     min = 4.3, max = 7.9, value = 5
#'   ),
#'   plotOutput("plot")
#' )
#'
#' server <- function(input, output) {
#'   output$plot <- renderPlot({
#'     df <- iris[iris$Sepal.Length <= input$len, ]
#'     validate_has_data(
#'       iris_f,
#'       min_nrow = 10,
#'       complete = FALSE,
#'       msg = "Please adjust Max Length of Sepal"
#'     )
#'
#'     hist(iris_f$Sepal.Length, breaks = 5)
#'   })
#' }
#' if (interactive()) {
#'   shinyApp(ui, server)
#' }
#'
validate_has_data <- function(x,
                              min_nrow = NULL,
                              complete = FALSE,
                              allow_inf = TRUE,
                              msg = NULL) {
  stopifnot(
    "Please provide a character vector in msg argument of validate_has_data." = is.character(msg) || is.null(msg)
  )
  validate(need(!is.null(x) && is.data.frame(x), "No data left."))
  if (!is.null(min_nrow)) {
    if (complete) {
      complete_index <- stats::complete.cases(x)
      validate(need(
        sum(complete_index) > 0 && nrow(x[complete_index, , drop = FALSE]) >= min_nrow,
        paste(c(paste("Number of complete cases is less than:", min_nrow), msg), collapse = "\n")
      ))
    } else {
      validate(need(
        nrow(x) >= min_nrow,
        paste(
          c(paste("Minimum number of records not met: >=", min_nrow, "records required."), msg),
          collapse = "\n"
        )
      ))
    }

    if (!allow_inf) {
      validate(need(
        all(vapply(x, function(col) !is.numeric(col) || !any(is.infinite(col)), logical(1))),
        "Dataframe contains Inf values which is not allowed."
      ))
    }
  }
}

#' Validate that dataset has unique rows for key variables
#'
#' @description `r lifecycle::badge("stable")`
#' @param x a data.frame
#' @param key a vector of ID variables from \code{x} that identify unique records
#'
#' @details This function is a wrapper for `shiny::validate`.
#'
#' @export
#'
#' @examples
#' iris$id <- rep(1:50, times = 3)
#' ui <- fluidPage(
#'   selectInput(
#'     inputId = "species",
#'     label = "Select species",
#'     choices = c("setosa", "versicolor", "virginica"),
#'     selected = "setosa",
#'     multiple = TRUE
#'   ),
#'   plotOutput("plot")
#' )
#' server <- function(input, output) {
#'   output$plot <- renderPlot({
#'     iris_f <- iris[iris$Species %in% input$species, ]
#'     validate_one_row_per_id(iris_f, key = c("id"))
#'
#'     hist(iris_f$Sepal.Length, breaks = 5)
#'   })
#' }
#' if (interactive()) {
#'   shinyApp(ui, server)
#' }
#'
validate_one_row_per_id <- function(x, key = c("USUBJID", "STUDYID")) {
  validate(need(!any(duplicated(x[key])), paste("Found more than one row per id.")))
}

#' Validates that vector includes all expected values
#'
#' @description `r lifecycle::badge("stable")`
#' @param x values to test. All must be in \code{choices}
#' @param choices a vector to test for values of \code{x}
#' @param msg warning message to display
#'
#' @details This function is a wrapper for `shiny::validate`.
#'
#' @export
#'
#' @examples
#' ui <- fluidPage(
#'   selectInput(
#'     "species",
#'     "Select species",
#'     choices = c("setosa", "versicolor", "virginica", "unknown species"),
#'     selected = "setosa",
#'     multiple = FALSE
#'   ),
#'   verbatimTextOutput("summary")
#' )
#'
#' server <- function(input, output) {
#'   output$summary <- renderPrint({
#'     validate_in(input$species, iris$Species, "Species does not exist.")
#'     nrow(iris[iris$Species == input$species, ])
#'   })
#' }
#' if (interactive()) {
#'   shinyApp(ui, server)
#' }
#'
validate_in <- function(x, choices, msg) {
  validate(need(length(x) > 0 && length(choices) > 0 && all(x %in% choices), msg))
}

#' Validates that vector has length greater than 0
#'
#' @description `r lifecycle::badge("stable")`
#' @param x vector
#' @param msg message to display
#'
#' @details This function is a wrapper for `shiny::validate`.
#'
#' @export
#'
#' @examples
#' data <- data.frame(
#'   id = c(1:10, 11:20, 1:10),
#'   strata = rep(c("A", "B"), each = 15)
#' )
#' ui <- fluidPage(
#'   selectInput("ref1", "Select strata1 to compare",
#'     choices = c("A", "B", "C"), selected = "A"
#'   ),
#'   selectInput("ref2", "Select strata2 to compare",
#'     choices = c("A", "B", "C"), selected = "B"
#'   ),
#'   verbatimTextOutput("arm_summary")
#' )
#'
#' server <- function(input, output) {
#'   output$arm_summary <- renderText({
#'     sample_1 <- data$id[data$strata == input$ref1]
#'     sample_2 <- data$id[data$strata == input$ref2]
#'
#'     validate_has_elements(sample_1, "No subjects in strata1.")
#'     validate_has_elements(sample_2, "No subjects in strata2.")
#'
#'     paste0(
#'       "Number of samples in: strata1=", length(sample_1),
#'       " comparions strata2=", length(sample_2)
#'     )
#'   })
#' }
#' if (interactive()) {
#'   shinyApp(ui, server)
#' }
validate_has_elements <- function(x, msg) {
  validate(need(length(x) > 0, msg))
}

#' Validates no intersection between two vectors
#'
#' @description `r lifecycle::badge("stable")`
#' @param x vector
#' @param y vector
#' @param msg message to display if \code{x} and \code{y} intersect
#'
#' @details This function is a wrapper for `shiny::validate`.
#'
#' @export
#'
#' @examples
#' data <- data.frame(
#'   id = c(1:10, 11:20, 1:10),
#'   strata = rep(c("A", "B", "C"), each = 10)
#' )
#'
#' ui <- fluidPage(
#'   selectInput("ref1", "Select strata1 to compare",
#'     choices = c("A", "B", "C"),
#'     selected = "A"
#'   ),
#'   selectInput("ref2", "Select strata2 to compare",
#'     choices = c("A", "B", "C"),
#'     selected = "B"
#'   ),
#'   verbatimTextOutput("summary")
#' )
#'
#' server <- function(input, output) {
#'   output$summary <- renderText({
#'     sample_1 <- data$id[data$strata == input$ref1]
#'     sample_2 <- data$id[data$strata == input$ref2]
#'
#'     validate_no_intersection(
#'       sample_1, sample_2,
#'       "subjects within strata1 and strata2 cannot overlap"
#'     )
#'     paste0(
#'       "Number of subject in: reference treatment=", length(sample_1),
#'       " comparions treatment=", length(sample_2)
#'     )
#'   })
#' }
#' if (interactive()) {
#'   shinyApp(ui, server)
#' }
#'
validate_no_intersection <- function(x, y, msg) {
  validate(need(length(intersect(x, y)) == 0, msg))
}


#' Validates that dataset contains specific variable
#'
#' @description `r lifecycle::badge("stable")`
#' @param data a data.frame
#' @param varname name of variable in \code{data}
#' @param msg message to display if \code{data} does not include \code{varname}
#'
#' @details This function is a wrapper for `shiny::validate`.
#'
#' @export
#'
#' @examples
#' data <- data.frame(
#'   one = rep("a", length.out = 20),
#'   two = rep(c("a", "b"), length.out = 20)
#' )
#' ui <- fluidPage(
#'   selectInput(
#'     "var",
#'     "Select variable",
#'     choices = c("one", "two", "three", "four"),
#'     selected = "one"
#'   ),
#'   verbatimTextOutput("summary")
#' )
#'
#' server <- function(input, output) {
#'   output$summary <- renderText({
#'     validate_has_variable(data, input$var)
#'     paste0("Selected treatment variables: ", paste(input$var, collapse = ", "))
#'   })
#' }
#' if (interactive()) {
#'   shinyApp(ui, server)
#' }
validate_has_variable <- function(data, varname, msg) {
  if (length(varname) != 0) {
    has_vars <- varname %in% names(data)

    if (!all(has_vars)) {
      if (missing(msg)) {
        msg <- sprintf(
          "%s does not have the required variables: %s.",
          deparse(substitute(data)),
          toString(varname[!has_vars])
        )
      }
      validate(need(FALSE, msg))
    }
  }
}

#' Validate that variables has expected number of levels
#'
#' @description `r lifecycle::badge("stable")`
#' @param x variable name. If \code{x} is not a factor, the unique values
#'   are treated as levels.
#' @param min_levels cutoff for minimum number of levels of \code{x}
#' @param max_levels cutoff for maximum number of levels of \code{x}
#' @param var_name name of variable being validated for use in
#'   validation message
#'
#' @details If the number of levels of \code{x} is less than \code{min_levels}
#'   or greater than \code{max_levels} the validation will fail.
#'   This function is a wrapper for `shiny::validate`.
#'
#' @export
#' @examples
#' data <- data.frame(
#'   one = rep("a", length.out = 20),
#'   two = rep(c("a", "b"), length.out = 20),
#'   three = rep(c("a", "b", "c"), length.out = 20),
#'   four = rep(c("a", "b", "c", "d"), length.out = 20),
#'   stringsAsFactors = TRUE
#' )
#' ui <- fluidPage(
#'   selectInput(
#'     "var",
#'     "Select variable",
#'     choices = c("one", "two", "three", "four"),
#'     selected = "one"
#'   ),
#'   verbatimTextOutput("summary")
#' )
#'
#' server <- function(input, output) {
#'   output$summary <- renderText({
#'     validate_n_levels(data[[input$var]], min_levels = 2, max_levels = 15, var_name = input$var)
#'     paste0(
#'       "Levels of selected treatment variable: ",
#'       paste(levels(data[[input$var]]),
#'         collapse = ", "
#'       )
#'     )
#'   })
#' }
#' if (interactive()) {
#'   shinyApp(ui, server)
#' }
validate_n_levels <- function(x, min_levels = 1, max_levels = 12, var_name) {
  x_levels <- if (is.factor(x)) {
    levels(x)
  } else {
    unique(x)
  }

  if (!is.null(min_levels) && !(is.null(max_levels))) {
    validate(need(
      length(x_levels) >= min_levels && length(x_levels) <= max_levels,
      sprintf(
        "%s variable needs minimum %s level(s) and maximum %s level(s).",
        var_name, min_levels, max_levels
      )
    ))
  } else if (!is.null(min_levels)) {
    validate(need(
      length(x_levels) >= min_levels,
      sprintf("%s variable needs minimum %s levels(s)", var_name, min_levels)
    ))
  } else if (!is.null(max_levels)) {
    validate(need(
      length(x_levels) <= max_levels,
      sprintf("%s variable needs maximum %s level(s)", var_name, max_levels)
    ))
  }
}
