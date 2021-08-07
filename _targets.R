library(targets)

r_functions <- list.files(path = "R", full.names = TRUE)

sapply(r_functions, source)

options(tidyverse.quiet = TRUE)

tar_option_set(
  packages = c("tidyverse", "tidymodels")
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
    read_raw_data(
      train_raw_path = train_raw_path,
      test_raw_path = test_raw_path,
      meal_info_path = meal_info_path
    )
  ),

  # 3.0 Separate data into long/short ----
  targets::tar_target(
    long_short_data_list,
    separate_long_short(data_list = data_list)
  ),

  # 4.0 Create Time Series features ----
  targets::tar_target(
    features_data,
    create_ts_features(data = long_short_data_list[["long_ts"]])
  )
)
