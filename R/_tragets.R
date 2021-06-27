training_plan <- function() {
  targets::tar_target(
    name = data_list,
    command = read_raw_data(train_raw_path = "inst/extdata/train.csv",
                            test_raw_path = "inst/extdata/test_QoiMO9B.csv",
                            meal_info_path = "inst/extdata/meal_info.csv")
  )

  targets::tar_target(
    name = long_short_data,
    separate_long_short(data_list = data_list)
  )

}
