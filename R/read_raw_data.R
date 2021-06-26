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
#' @importFrom magrittr %>%
#' @export
#'
#' @examples
#' data_list = read_raw_data(
#'      train_raw_path = "inst/extdata/train.csv",
#'      test_raw_path = "inst/extdata/test_QoiMO9B.csv",
#'      meal_info_path = "inst/extdata/meal_info.csv"
#' )
read_raw_data <- function(train_raw_path = as.character(),
                          test_raw_path = as.character(),
                          meal_info_path = as.character()) {
  tryCatch(
    {
      # Read training data
      train_data <- data.table::fread(train_raw_path)

      # Read test data
      test_data <- data.table::fread(test_raw_path)

      # Read meal info data
      meal_data <- data.table::fread(meal_info_path)

      # Join meal info to data
      list(
        "train_data" = train_data,
        "test_data" = test_data
      ) %>%
        purrr::map(~dplyr::left_join(.x, meal_data, by = "meal_id"))
    },
    error = function(e) {
      logger::log_error("Exception in read_raw_data()")
    }
  )
}
