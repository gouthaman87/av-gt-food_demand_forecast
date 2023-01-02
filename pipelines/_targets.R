library(targets)

r_functions <- list.files(path = "R", full.names = TRUE)

sapply(r_functions, source)

options(tidyverse.quiet = TRUE)

tar_option_set(
  packages = c("agua", "bonsai")
)

list(
  # 1.0 Specify data path ----
  targets::tar_target(
    train_raw_path,
    "inst/extdata/train.csv",
    format = "file"
  ),

  targets::tar_target(
    test_raw_path,
    "inst/extdata/test_QoiMO9B.csv",
    format = "file"
  ),

  targets::tar_target(
    meal_info_path,
    "inst/extdata/meal_info.csv",
    format = "file"
  ),

  # 2.0 Read raw data ----
  targets::tar_target(
    data_list,
    init_raw_data(
      train_raw_path = train_raw_path,
      test_raw_path = test_raw_path,
      meal_info_path = meal_info_path
    )
  ),

  # 3.0 Initialize Data ----
  targets::tar_target(
    complete_data,
    init_prepare(data_list = data_list)
  ),

  # 4.0 Run Test Data Forecast ----
  targets::tar_target(
    test_results,
    init_forecast(
      DF = complete_data[["master_data"]],
      # model_name = c("h2o_gbm", "h2o_rf", "lgbm")
      model_name = "h2o_rf"
    )
  )
)

# # Launch the app in a background process.
# # You may need to refresh the browser if the app is slow to start.
# # The graph automatically refreshes every 10 seconds
# tar_watch(seconds = 10, outdated = FALSE, targets_only = TRUE)
