#' Title
#'
#' @param ts_splits
#' @param ts_recipe
#'
#' @return
#' @importFrom parsnip boost_tree
#' @import mlflow
#' @export
#'
#' @examples
fit_xgboost <- function(ts_splits,
                        ts_recipe) {

  # 1.0 Create Hyperparameter grid
  xgb_grid <- tidyr::expand_grid(mtry = 5, trees = seq(500, 1000, by = 500))

  # 2.0 Create model grid table
  xgb_tbl <- xgb_grid %>%
    modeltime::create_model_grid(f_model_spec = "boost_tree",
                                 engine_name = "xgboost",
                                 mode = "regression")

  # 3.0 Create Workflow sets
  xgb_workflow <- workflowsets::workflow_set(
    preproc = list(ts_recipe),
    models = xgb_tbl$.models,
    cross = TRUE
  )

  # 4.0 Train XGBoost with
  xgb_parallel_tbl <- xgb_workflow %>%
    modeltime::modeltime_fit_workflowset(
      data    = rsample::training(ts_splits),
      control = modeltime::control_fit_workflowset(
        verbose   = TRUE,
        allow_par = FALSE
      )
    )

  # 5.0 Accuracy calculation
  xgb_best_model <- xgb_parallel_tbl %>%
    modeltime::modeltime_calibrate(rsample::testing(ts_splits)) %>%
    modeltime::modeltime_accuracy() %>%
    dplyr::filter(rmse == min(rmse))

  model_id <- dplyr::pull(xgb_best_model, .model_id)

  rmse <- dplyr::pull(xgb_best_model, rmse)

  # 6.0 Log Hyperparameters & RMSE metric in MLFlow
  logger::log_info("Tracking in MLFlow")

  mlflow::mlflow_create_experiment("food_forecast")

  spec <- workflows::pull_workflow_spec(xgb_parallel_tbl$.model[[model_id]])
  parameter_names <- names(spec$args)
  parameter_values <- lapply(spec$args, rlang::get_expr)

  with(mlflow::mlflow_start_run(experiment_id = 1), {
    for (j in seq_along(spec$args)) {
      parameter_name <- parameter_names[[j]]
      parameter_value <- parameter_values[[j]]
      if (!is.null(parameter_value)) {
        mlflow::mlflow_log_param(parameter_name, parameter_value)
      }
    }

    mlflow::mlflow_log_metric("rmse", rmse)
  })
}
