#' Creates Time Series Split for 10 weeks
#'
#' @param DF The Data Frame to split
#'
#' @return Train/Test split
#' @export
ts_split <- function(DF = is.data.frame()) {
  splt <- DF |>
    timetk::time_series_split(
      date_var = date,
      assess = 10,
      cumulative = TRUE
    )

  list(
    train_data = rsample::training(splt),
    test_data = rsample::testing(splt)
  )
}


#' Create Recipe for Model
#'
#' This functions is a feature engineering recipe before model
#'
#' @param DF The Data Frame to create recipe
#'
#' @return Recipe object
#' @export
create_recipe <- function(DF) {
  recipes::recipe(num_orders ~ ., data = DF) |>

    recipes::step_mutate(ts_id = paste0(center_id, "_", meal_id)) |>
    # recipes::step_rm(week, checkout_price) |>

    # timetk::step_timeseries_signature(dplyr::contains("date")) |>
    # recipes::step_rm(
    #   dplyr::matches("(.iso$)|(.xts$)|(day)|(hour)|(minute)|(second)|(am.pm)|(diff)|(.lbl$)")
    # ) |>

    # recipes::update_role(id, center_id, meal_id, date, week, checkout_price, new_role = "ID")
    recipes::step_rm(id, center_id, meal_id, week, checkout_price) |>
    recipes::step_rm(emailer_for_promotion, homepage_featured, category, cuisine)
    # step_group_lag(dplyr::ends_with("_id"))
}
