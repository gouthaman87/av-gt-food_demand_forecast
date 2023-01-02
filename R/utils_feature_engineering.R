#' Creates Time Series Split for 10 weeks
#'
#' @param DF The Data Frame to split
#'
#' @return Train/Test split
#' @export
ts_split <-
  function(DF = is.data.frame()) {

    splt <-
      DF |>
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
create_recipe <-
  function(DF) {

    recipes::recipe(num_orders ~ ., data = DF) |>

      # Create Unique ID's for Each TS
      recipes::step_mutate(ts_id = paste0(center_id, "_", meal_id)) |>

      # Change Meal / Center ID / Emailer Promotion AS Factor
      recipes::step_mutate(
        dplyr::across(
          dplyr::matches("(center|meal)_id|(^emailer_)|(^homepage_)"),
          ~as.factor(.x)
        )
      ) |>

      # Transform Date
      timetk::step_timeseries_signature(dplyr::contains("date")) |>
      recipes::step_rm(
        dplyr::matches("(.iso$)|(.xts$)|(day)|(hour)|(minute)|(second)|(am.pm)|(diff)|(.lbl$)")
      ) |>
      # # Center ID
      # {
      #   \(x)
      #   if("center_id" %in% features)
      #     textrecipes::step_dummy_hash(x, center_id, signed = FALSE, num_terms = 16)
      #   else x
      # }() |>
      #
      # # Meal ID
      # {
      #   \(x)
    #   if("meal_id" %in% features)
    #     textrecipes::step_dummy_hash(x, meal_id, signed = FALSE, num_terms = 16)
    #   else x
    # }() |>
    recipes::step_zv()

    # recipes::step_rm(dplyr::all_of(remove_columns))

    #   # step_group_lag(dplyr::ends_with("_id"))
  }
