% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/model_workflow.R
\name{create_forecast}
\alias{create_forecast}
\title{Creates forecast values}
\usage{
create_forecast(DF, new_df = NULL, model_name)
}
\arguments{
\item{DF}{The training Data Frame}

\item{new_df}{The Data to predict future values}

\item{model_name}{The model names}
}
\value{
Fitted Modeltime Table

Test Data Frame's Forecast Values

Accuracy Table
}
\description{
This function join all the model workflow functions
}
