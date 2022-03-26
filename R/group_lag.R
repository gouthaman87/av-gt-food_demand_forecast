#' Create Lag values by group
#'
#' `step_group_lag` creates a *specification* of a recipe
#'  step that will creates 1:4 & 10 lag values by group of user specified
#'
#' @param recipe A recipe object. The step will be added to the
#'  sequence of operations for this recipe.
#' @param ... One or more selector functions to choose variables
#'  for this step. See [selections()] for more details.
#' @param role Not used by this step since no new variables are
#'  created.
#' @param trained A logical to indicate if the quantities for
#'  preprocessing have been estimated.
#' @param lag_table Group Lag table with lag values. This is
#'  `NULL` until computed by [prep()].
#' @param skip A logical. Should the step be skipped when the
#'  recipe is baked by [bake()]? While all operations are baked
#'  when [prep()] is run, some operations may not be able to be
#'  conducted on new data (e.g. processing the outcome variable(s)).
#'  Care should be taken when using `skip = TRUE` as it may affect
#'  the computations for subsequent operations.
#' @param id A character string that is unique to this step to identify it.
#'
#' @export
step_group_lag <- function(
  recipe,
  ...,
  role = "predictor",
  trained = FALSE,
  lag_table = NULL,
  skip = FALSE,
  id = recipes::rand_id("group_lag")
) {

  terms <- recipes::ellipse_check(...)

  recipes::add_step(
    recipe,
    step_group_lag_new(
      terms = terms,
      trained = trained,
      lag_table = lag_table,
      role = role,
      skip = skip,
      id = id
    )
  )
}

## Initializes a new object
step_group_lag_new <-
  function(terms, role, trained, lag_table, skip, id) {
    recipes::step(
      subclass = "group_lag",
      terms = terms,
      role = role,
      trained = trained,
      lag_table = lag_table,
      skip = skip,
      id = id
    )
  }

#' @export
#' @importFrom recipes prep bake
prep.step_group_lag <- function(x, training, info = NULL, ...) {
  col_names <- recipes::recipes_eval_select(x$terms, training, info)

  lag_table <- training |>
    dplyr::group_by_at(.vars = dplyr::all_of(c(col_names, "date"))) |>
    dplyr::summarise(
      num_orders = sum(num_orders, na.rm = TRUE),
      .groups = "drop_last"
    ) |>

    # Extend the train data by forecast horizon
    timetk::future_frame(
      .date_var = "date",
      .length_out = 10,
      .bind_data = TRUE
    ) |>

    timetk::tk_augment_lags(.value = num_orders, .lags = c(1:4, 10)) |>
    dplyr::ungroup() |>
    dplyr::select(-num_orders)

  step_group_lag_new(
    terms = x$terms,
    trained = TRUE,
    role = x$role,
    lag_table = lag_table,
    skip = x$skip,
    id = x$id
  )
}

#' @export
bake.step_group_lag <- function(object, new_data, ...) {
  vars <- colnames(object$lag_table)
  ind <- !stringr::str_detect(vars, "num_orders_")
  vars <- vars[ind]

  new_data <- new_data |>
    dplyr::left_join(object$lag_table, by = vars)
}
