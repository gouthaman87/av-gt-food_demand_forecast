#' Create Time Series features
#'
#' This function creates following features for given weekly data:
#' weekly seasonal features (month, year, week, etc.) and 10th lag feature.
#'
#' @param data The long transaction data from `separate_long_short` function.
#'
#' @return The features added transaction data.
#' @export
#'
#' @examples
#' \dontrun{
#' feature_data = create_ts_features(data = data_list[["long_ts"]])
#' }
create_ts_features <- function(data = tibble::as.tibble()) {
  logger::log_info("Running create_ts_feature()")

  # Split the data
  splits <- data %>%
    timetk::time_series_split(date_var = date,
                              assess = 10,
                              cumulative = TRUE)

  train_data <- rsample::training(splits) %>%
    dplyr::mutate(dummy_orders = num_orders)

  test_data <- rsample::testing(splits) %>%
    dplyr::mutate(dummy_orders = NA)

  data <- dplyr::bind_rows(train_data, test_data)

  # 1.0 Seasonal features
  data <- data %>%
    dplyr::rename("week_no" = "week") %>%
    timetk::tk_augment_timeseries_signature(date) %>%
    dplyr::select(-dplyr::matches("(.iso$)|(.xts$)|(day)|(hour)|(minute)|(second)|(am.pm)|(diff)"))

  # 2.0 Lag features
  data <- data %>%
    dplyr::group_by(meal_id, center_id) %>%
    timetk::tk_augment_lags(dummy_orders, .lags = 10, .names = "lag_10") %>%
    dplyr::ungroup()

  data %>%
    dplyr::select(-dummy_orders)
}
