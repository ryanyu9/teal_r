% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/landing_popup_module.R
\name{landing_popup_module}
\alias{landing_popup_module}
\title{Landing Popup Module}
\usage{
landing_popup_module(
  label = "Landing Popup",
  title = NULL,
  content = NULL,
  buttons = modalButton("Accept")
)
}
\arguments{
\item{label}{\code{character(1)} the label of the module.}

\item{title}{\code{character(1)} the text to be displayed as a title of the popup.}

\item{content}{The content of the popup. Passed to \code{...} of \code{shiny::modalDialog}. Can be a \code{character}
or a list of \code{shiny.tag}s. See examples.}

\item{buttons}{\code{shiny.tag} or a list of tags (\code{tagList}). Typically a \code{modalButton} or \code{actionButton}. See examples.}
}
\value{
A \code{teal_module} (extended with \code{teal_landing_module} class) to be used in \code{teal} applications.
}
\description{
Creates a landing welcome popup for \code{teal} applications.

This module is used to display a popup dialog when the application starts.
The dialog blocks the access to the application and must be closed with a button before the application is viewed.
}
\examples{
app1 <- teal::init(
  data = teal.data::dataset("iris", iris),
  modules = teal::modules(
    teal::landing_popup_module(
      content = "A place for the welcome message or a disclaimer statement.",
      buttons = modalButton("Proceed")
    ),
    example_module()
  )
)
if (interactive()) {
  shinyApp(app1$ui, app1$server)
}

app2 <- teal::init(
  data = teal.data::dataset("iris", iris),
  modules = teal::modules(
    teal::landing_popup_module(
      title = "Welcome",
      content = tags$b(
        "A place for the welcome message or a disclaimer statement.",
        style = "color: red;"
      ),
      buttons = tagList(
        modalButton("Proceed"),
        actionButton("read", "Read more",
          onclick = "window.open('http://google.com', '_blank')"
        ),
        actionButton("close", "Reject", onclick = "window.close()")
      )
    ),
    example_module()
  )
)

if (interactive()) {
  shinyApp(app2$ui, app2$server)
}

}
