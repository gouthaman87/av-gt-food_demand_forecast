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
  modeltime::parallel_start(2)

  xgb_parallel_tbl <- xgb_workflow %>%
    modeltime::modeltime_fit_workflowset(
      data    = rsample::training(ts_splits),
      control = modeltime::control_fit_workflowset(
        verbose   = TRUE,
        allow_par = FALSE
      )
    )

  return(xgb_parallel_tbl)

  modeltime::parallel_stop()

  # 5.0 Log Hyperparameters & RMSE metric in MLFlow
  mlflow::mlflow_set_experiment(experiment_name = "food_forecast")

  with(mlflow::mlflow_start_run(), {
    for(i in seq_along(xgb_parallel_tbl$.model)) {
      spec <- workflows::pull_workflow_spec(xgb_parallel_tbl$.model[[i]])
      parameter_names <- names(spec$args)
      parameter_values <- lapply(spec$args, rlang::get_expr)

      for (j in seq_along(spec$args)) {
        parameter_name <- parameter_names[[j]]
        parameter_value <- parameter_values[[j]]
        if (!is.null(parameter_value)) {
          mlflow::mlflow_log_param(parameter_name, parameter_value)
        }
      }
    }
  })
}
