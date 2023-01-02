#' Initialize Data
#'
#' @param data_list The raw data list from function `read_raw_data`
#'
#' @return Complete Data
#' @return Future Data with Features
#' @export
init_prepare <-
  function(data_list = is.list()) {

    # Extract data from list
    master_data <- data_list[["master_data"]]
    future_data <- data_list[["future_data"]]

    # Create week date table
    w1 = max(master_data$week)
    w2 = max(future_data$week)

    week_max <- pmax(w1, w2)

    week_table <-
      timetk::tk_make_timeseries(
        start_date = as.Date("2016-01-04"),
        by = "week",
        length_out = week_max
      )

    week_table <-
      tibble::tibble(
        week = seq(1, week_max, by = 1),
        date = week_table
      )

    logger::log_info("Convert Week Numbers to Date weeks")
    master_data <- dplyr::left_join(master_data, week_table, by = "week")
    future_data <- dplyr::left_join(future_data, week_table, by = "week")

    # Make complete data
    logger::log_info("Make complete data and impute sales")
    master_data <-
      master_data |>
      # tsibble::as_tsibble(key = c(center_id, meal_id), index = date) |>
      # tsibble::fill_gaps(num_orders = 0, .full = end()) |>
      # tsibble::group_by_key() |>
      # tidyr::fill(
      #   dplyr::all_of(
      #     c("checkout_price",
      #       "base_price",
      #       "emailer_for_promotion",
      #       "homepage_featured",
      #       "category",
      #       "cuisine")
    #   ),
    #   .direction = "down"
    # ) |>
    # tibble::as_tibble() |>
    dplyr::select(id, week, date, num_orders, dplyr::everything()) |>
      dplyr::with_groups(
        c(center_id, meal_id),
        ~dplyr::filter(.x, dplyr::n() > 1)
      )

    list(master_data = master_data, future_data = future_data)

  }



