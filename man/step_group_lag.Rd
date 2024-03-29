% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/group_lag.R
\name{step_group_lag}
\alias{step_group_lag}
\title{Create Lag values by group}
\usage{
step_group_lag(
  recipe,
  ...,
  role = "predictor",
  trained = FALSE,
  lag_table = NULL,
  skip = FALSE,
  id = recipes::rand_id("group_lag")
)
}
\arguments{
\item{recipe}{A recipe object. The step will be added to the
sequence of operations for this recipe.}

\item{...}{One or more selector functions to choose variables
for this step. See \code{\link[=selections]{selections()}} for more details.}

\item{role}{Not used by this step since no new variables are
created.}

\item{trained}{A logical to indicate if the quantities for
preprocessing have been estimated.}

\item{lag_table}{Group Lag table with lag values. This is
\code{NULL} until computed by \code{\link[=prep]{prep()}}.}

\item{skip}{A logical. Should the step be skipped when the
recipe is baked by \code{\link[=bake]{bake()}}? While all operations are baked
when \code{\link[=prep]{prep()}} is run, some operations may not be able to be
conducted on new data (e.g. processing the outcome variable(s)).
Care should be taken when using \code{skip = TRUE} as it may affect
the computations for subsequent operations.}

\item{id}{A character string that is unique to this step to identify it.}
}
\description{
\code{step_group_lag} creates a \emph{specification} of a recipe
step that will creates 1:4 & 10 lag values by group of user specified
}
