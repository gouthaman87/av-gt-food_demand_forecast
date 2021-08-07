#' Separate Train data
#'
#' Ingest raw train data and separate the data into long (> 20 transactions)
#' & short (<= 20 time series) time series data.
#'
#' @param data_list The raw data list from function `read_raw_data`
#'
#' @returns
#' @return List of data list.
#' @return long_ts: The data with greater than 20 transactions.
#' @return short_ts: The data with shorter than 20 transactions.
#' @export
#'
#' @examples
#' \dontrun{
#' data_list = separate_long_short(data_list = train_data_list)
#' }
separate_long_short <- function(data_list = as.list()) {
  logger::log_info("Running separate_long_short()")

  # Extract data from list
  train_data <- data_list[["train_data"]]

  # Create week date table
  max_week_number = max(train_data$week)

  week_table <- timetk::tk_make_timeseries(start_date = as.Date("2016-01-04"),
                                           by = "week",
                                           length_out = max_week_number)

  week_table <- tibble::tibble(week = seq(1, max_week_number, by = 1),
                               date = week_table)

  train_data <- dplyr::left_join(train_data, week_table, by = "week")

  # Make complete data
  train_data <- train_data %>%
    tsibble::as_tsibble(key = c(center_id, meal_id), index = date) %>%
    tsibble::fill_gaps(num_orders = 0, .full = end()) %>%
    tsibble::group_by_key() %>%
    tidyr::fill_(fill_cols = c("checkout_price",
                               "base_price",
                               "emailer_for_promotion",
                               "homepage_featured",
                               "category",
                               "cuisine"),
                 .direction = "down") %>%
    tibble::as_tibble() %>%
    dplyr::select(id, week, date, num_orders, dplyr::everything())

  # Separate data
  short_ts <- train_data %>%
    dplyr::group_by(center_id, meal_id) %>%
    dplyr::filter(dplyr::n() <= 20) %>%
    dplyr::ungroup()

  long_ts <- train_data %>%
    dplyr::group_by(center_id, meal_id) %>%
    dplyr::filter(dplyr::n() > 20) %>%
    dplyr::ungroup()

  list("long_ts" = long_ts, "short_ts" = short_ts)
}
