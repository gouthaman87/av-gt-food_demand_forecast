# H2O Models --------------------------------------------------------------

#' GLM (Lasso / Ridge ) Regression / h2o
#'
#' @return model
#' @export
ml_h2o_glmnet <- function(){
  parsnip::linear_reg(mode = "regression") |>
    parsnip::set_engine("h2o")
}

#' Random Forest / h2o
#'
#' @return model
#' @export
ml_h2o_rf <- function(){
  parsnip::rand_forest(mode = "regression") |>
    parsnip::set_engine(
      "h2o",
      # histogram_type = "Random"
      # stopping_metric = "RMSE",
      distribution = "tweedie",
      # tweedie_power = 1.99,
      categorical_encoding = "SortByResponse"
      # categorical_encoding = "OneHotExplicit"
    )
}

#' Deep Learning / h2o
#'
#' @return model
#' @export
ml_h2o_dl <- function(){
  parsnip::mlp(mode = "regression") |>
    parsnip::set_engine("h2o")
}

#' GBM / h2o
#'
#' @return model
#' @export
ml_h2o_gbm <- function(){
  parsnip::boost_tree(mode = "regression") |>
    parsnip::set_engine(
      "h2o",
      # stopping_metric = "RMSE",
      categorical_encoding = "SortByResponse",
      distribution = "tweedie",
      # histogram_type = "RoundRobin",
      tweedie_power = 1.99
    )
}

#' # Tidymodel Models --------------------------------------------------------
#'
#' #' Stan Regression
#' #'
#' #' @return model
#' #' @export
#' ml_stan <- function(){
#'   parsnip::linear_reg(mode = "regression") |>
#'     parsnip::set_engine("stan")
#' }
#'
#' #' Decision Tree
#' #'
#' #' @return model
#' #' @export
#' ml_dt <- function(){
#'   parsnip::decision_tree(mode = "regression") |>
#'     parsnip::set_engine("rpart")
#' }
#'
#'
# Boost Models ------------------------------------------------------------

#' LightGBM
#'
#' @return model
#' @export
ml_lgbm <- function(){
  parsnip::boost_tree(
    mode = "regression",
    # tree_depth = tune::tune(),
    # learn_rate = tune::tune(),
    # loss_reduction = tune::tune(),
    # min_n = tune::tune(),
    # sample_size = tune::tune(),
    # trees = tune::tune()
    # mtry = tune::tune()
  ) |>
    parsnip::set_engine(
      "lightgbm",
      objective = "tweedie"
    )
}

#' #' catBoost
#' #'
#' #' @return model
#' #' @export
#' ml_catboost <- function(){
#'   parsnip::boost_tree(
#'     mode = "regression"
#'     # mtry = tune::tune()
#'   ) |>
#'     parsnip::set_engine("catboost")
#' }
#'
#' #' LightGBM
#' #'
#' #' @return model
#' #' @export
#' ml_xgb <- function(){
#'   parsnip::boost_tree(
#'     mode = "regression",
#'     # tree_depth = tune::tune(),
#'     # learn_rate = tune::tune(),
#'     # loss_reduction = tune::tune(),
#'     # min_n = tune::tune(),
#'     # sample_size = tune::tune(),
#'     # trees = tune::tune()
#'     # mtry = tune::tune()
#'   ) |>
#'     parsnip::set_engine(
#'       "xgboost",
#'       objective = "reg:tweedie",
#'       tweedie_variance_power = 1.99
#'     )
#' }
#'
#'
#' # DeepLearning Models -----------------------------------------------------
#'
#' #' DeepAR
#' #'
#' #' @return model
#' #' @export
#' ml_deepar <- function(){
#'   modeltime.gluonts::deep_ar(
#'     id = "ts_id",
#'     freq = "W",
#'     prediction_length = 10
#'
#'     # # Hyper Parameters
#'     # epochs = 1,
#'     # num_batches_per_epoch = 4
#'   ) |>
#'     parsnip::set_engine("gluonts_deepar")
#' }
