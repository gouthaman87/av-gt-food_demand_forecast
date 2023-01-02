#' Create workflow sets
#'
#' @param DF The training Data Frame
#' @param model_name The model names
#'
#' @return Workflow Set object
#' @export
model_workflow <-
  function(
    DF = is.data.frame(),
    model_name = is.character()
  ) {

    # Call Recipe ----
    ml_rec <-
      create_recipe(DF = DF) |>
      recipes::step_rm(ts_id, date)

    xgb_rec <- ml_rec |>
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
        preproc = list(recipe = ml_rec),
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
model_fit <-
  function(model_set, DF) {

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
forecast_values <-
  function(model_fit, DF) {

    model_fit |>
      modeltime::modeltime_forecast(
        new_data = DF,
        keep_data = TRUE
      ) |>
      dplyr::mutate(.value = ifelse(.value < 0, 0, .value)) |>
      dplyr::select(
        id,
        week,
        date,
        center_id,
        meal_id,
        cuisine,
        .model_desc,
        num_orders,
        .value
      )
  }


#' Create Accuracy Metric Set
#'
#' @param DF The Predicted Data Frame
#'
#' @return The Accuracy metric set
#' @export
accuracy_metric <-
  function(DF) {

    DF |>
      dplyr::group_by(.model_desc, center_id, meal_id) |>
      dplyr::summarise(
        accuracy_rmsle = Metrics::rmsle(num_orders, .value),
        .groups = "drop"
      )
  }


#' The function to create Variable Importance Data
#'
#' @param modeltime_table The fitted modeltime workflowset
#'
#' @return The Data Frame of Variable Importance
#' @export
create_vip_dt <-
  function(modeltime_table) {

    modeltime_table$.model_desc |>
      purrr::map2_dfr(
        .y = modeltime_table$.model_id,
        ~{
          mdl <- modeltime_table |>
            modeltime::pull_modeltime_model(.y)

          safe_vi <- purrr::possibly(
            vip::vi,
            otherwise = dplyr::tribble(~"Variable", ~"Importance")
          )

          safe_vi(mdl$fit$fit, scale = TRUE) |>
            dplyr::mutate(Model = stringr::str_replace(.x, "RECIPE_", ""))
        }
      )
}


