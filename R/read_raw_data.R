#' Read data
#'
#' Read raw Training & test data of food demand provided
#' by AnalyticsVidhya.
#'
#' @param train_raw_path The location of train .csv file.
#' @param test_raw_path The location of test .csv file.
#' @param meal_info_path The location of meal master csv file.
#'
#' @returns
#' @return List of data.
#' @return train_data: The data.table of training data.
#' @return test_data: The data.table of test data.
#' @export
read_raw_data <- function(
  train_raw_path = is.character(),
  test_raw_path = is.character(),
  meal_info_path = is.character()
) {
  # Read Master data
  master_data <- data.table::fread(train_raw_path)

  # Read Future data
  future_data <- data.table::fread(test_raw_path)

  # Read meal info data
  meal_data <- data.table::fread(meal_info_path)

  # Join meal info to data
  list(
    "master_data" = master_data,
    "future_data" = future_data
  ) |>
    purrr::map(~dplyr::left_join(.x, meal_data, by = "meal_id"))
}
