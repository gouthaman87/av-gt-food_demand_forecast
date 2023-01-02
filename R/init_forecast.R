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
init_forecast <-
  function(
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
    df_train <- splt[["train_data"]]
    df_test <- splt[["test_data"]]

    # Create Workflow ----
    wflw_set <- model_workflow(df_train, model_name = model_name)

    # Fit Workflow Sets ----
    fitted_wflw_set <-
      wflw_set |>
      model_fit(df_train)

    # Forecast for Test ----
    df_fcast_values <-
      fitted_wflw_set |>
      forecast_values(DF = df_test)

    df_vip_dt <- create_vip_dt(fitted_wflw_set)

    list(
      variable_importance = df_vip_dt,
      test_results = df_fcast_values
    )
  }
