#' Create workflow sets
#'
#' @param DF The training Data Frame
#' @param model_name The model names
#'
#' @return Workflow Set object
#' @export
model_workflow <- function(DF = is.data.frame(),
                           model_name = is.character()) {

  # Call Recipe ----
  base_rec <- create_recipe(DF = DF)

  xgb_rec <- base_rec |>
    recipes::step_dummy(recipes::all_nominal(), one_hot = TRUE)

  # Read models ----
  mod <- purrr::map(
    .x = model_name,
    ~eval(call(glue::glue("ml_{.x}")))
  ) |>
    purrr::set_names(model_name)

  names_mod <- names(mod)

  ind_xgb <- stringr::str_detect(names_mod, "xgb")

  xgb_mod <- mod[ind_xgb]
  other_mod <- mod[!ind_xgb]

  if(length(xgb_mod) > 0) {
    xgb_wflw <- workflowsets::workflow_set(
      preproc = list(recipe = xgb_rec),
      models = xgb_mod
    )
  } else xgb_wflw = NULL

  if(length(other_mod) > 0) {
    other_wflw <- workflowsets::workflow_set(
      preproc = list(recipe = base_rec),
      models = other_mod
    )
  } else other_wflw = NULL

  dplyr::bind_rows(list(xgb_wflw, other_wflw))
}


#' Fit the workflow set
#'
#' @param DF The training Data Frame
#' @param model_set The workflow set which is output of `model_workflow`
#'
#' @return Workflow Set with fit column
#' @export
model_fit <- function(model_set, DF) {
  model_set |>
    modeltime::modeltime_fit_workflowset(data = DF)
}


#' Forecast the values
#'
#' @param model_fit The fitted model workflow sets is output of `model_fit`
#' @param DF The Testing / New Data Frame to predict.
#'
#' @return Predicted Data Frame
#' @export
forecast_values <- function(model_fit, DF) {

  model_fit |>
    modeltime::modeltime_forecast(
      new_data = DF,
      keep_data = TRUE
    ) |>
    dplyr::mutate(.value = ifelse(.value < 0, 0, .value)) |>
    dplyr::select(id, week, date, center_id, meal_id, cuisine, .model_desc, num_orders, .value)
}


#' Create Accuracy Metric Set
#'
#' @param DF The Predicted Data Frame
#'
#' @return The Accuracy metric set
#' @export
accuracy_metric <- function(DF) {

  DF |>
    dplyr::group_by(.model_desc, center_id, meal_id) |>
    dplyr::summarise(
      accuracy_rmsle = Metrics::rmsle(num_orders, .value),
      .groups = "drop"
    )
}


#' Creates forecast values
#'
#' This function join all the model workflow functions
#'
#' @inheritParams model_workflow
#' @param new_df The Data to predict future values
#'
#' @return Fitted Modeltime Table
#' @return Test Data Frame's Forecast Values
#' @return Accuracy Table
#' @export
meal_forecast <- function(
  DF = is.data.frame(),
  new_df = NULL,
  model_name = is.character()
) {

  # Initialize h2o engine ----
  ind <- stringr::str_detect(model_name, "h2o")
  ind <- sum(ind, na.rm = TRUE)
  if(ind > 0) {
    h2o::h2o.init()
    h2o::h2o.removeAll()
    withr::defer(h2o::h2o.shutdown(prompt = FALSE))
  }

  # Split the Data ----
  splt <- ts_split(DF = DF)

  # Create Workflow ----
  wflw_set <- model_workflow(splt[["train_data"]], model_name = model_name)

  # Fit Workflow Sets ----
  fitted_wflw_set <- wflw_set |>
    model_fit(splt[["train_data"]])

  # Forecast for Test ----
  fcast_values <- fitted_wflw_set |>
    forecast_values(DF = splt[["test_data"]])

  # accuracy_tbl <- accuracy_metric(DF = fcast_values)

  list(
    modeltime_table = fitted_wflw_set,
    test_results = fcast_values
    # accuracy_tbl = accuracy_tbl
  )
}



