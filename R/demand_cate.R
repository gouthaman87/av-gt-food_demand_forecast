#' Create Demand Categorization
#'
#' `step_demand_cate` creates a *specification* of a recipe
#'  step that will creates demand categorization based on SBC method.
#'
#' @inheritParams step_demand_cate
#' @param demand_cate_table Demand categorization table. This is
#'  `NULL` until computed by [prep()].
#' @export
step_demand_cate <- function(
  recipe,
  ...,
  role = "predictor",
  trained = FALSE,
  demand_cate_table = NULL,
  skip = FALSE,
  id = recipes::rand_id("demand_cate")
) {

  terms <- recipes::ellipse_check(...)

  recipes::add_step(
    recipe,
    step_demand_cate_new(
      terms = terms,
      trained = trained,
      demand_cate_table = demand_cate_table,
      role = role,
      skip = skip,
      id = id
    )
  )
}

## Initializes a new object
step_demand_cate_new <-
  function(terms, role, trained, demand_cate_table, skip, id) {
    recipes::step(
      subclass = "demand_cate",
      terms = terms,
      role = role,
      trained = trained,
      demand_cate_table = demand_cate_table ,
      skip = skip,
      id = id
    )
  }

#' @export
#' @importFrom recipes prep bake
prep.step_demand_cate <- function(x, training, info = NULL, ...) {
  col_names <- recipes::recipes_eval_select(x$terms, training, info)

  tbl_lst <- training |>
    dplyr::group_by_at(.vars = dplyr::all_of(col_names)) |>
    dplyr::mutate(start_week = min(date)) |>
    dplyr::ungroup() |>
    dplyr::group_by(start_week) |>
    dplyr::group_split()

  demand_cate_tbl <- purrr::map_df(
    .x = tbl_lst,
    ~{
      # categorize low transaction files
      demand_tbl <- .x |>
        dplyr::group_by_at(dplyr::all_of(col_names)) |>
        dplyr::tally() |>
        dplyr::mutate(ts_cate = ifelse(n <= 40, "No Demand", "Demand"))

      # make each combo ts as column
      wide_dt <- .x |>
        dplyr::distinct_at(dplyr::all_of(c(col_names, "date", "num_orders"))) |>
        tidyr::unite(col = "id", dplyr::all_of(col_names)) |>

        tidyr::pivot_wider(
          names_from = id,
          values_from = num_orders,
          values_fill = 0
        ) |>
        # arrange by week date
        dplyr::arrange(date) |>
        dplyr::select(-date) |>
        data.frame()

      # demand categorize the combos
      ts_cate_obj <- tsintermittent::idclass(
        wide_dt,
        type = "SBC",
        outplot = "none"
      )

      ts_categorization <- data.frame(
        id = row.names(t(wide_dt)),
        cv2 = ts_cate_obj$cv2,
        p = ts_cate_obj$p
      ) |>
        tidyr::separate(id, into = col_names, sep = "_")
        dplyr::mutate(
          demand_cate = dplyr::case_when(p < 1.32 & cv2 < 0.49 ~ "Smooth",
                                         p >= 1.32 & cv2 < 0.49 ~ "Intermittent",
                                         p < 1.32 & cv2 >= 0.49 ~ "Erratic",
                                         p >= 1.32 & cv2 >= 0.49 ~ "Lumpy")
        ) |>
        dplyr::mutate(
          center_id = as.integer(as.character(center_id)),
          meal_id = as.integer(as.character(meal_id))
        )

      ts_categorization <- demand_tbl |>
        dplyr::select(-n) |>
        dplyr::left_join(ts_categorization, by = col_names) |>
        dplyr::mutate(
          demand_cate = ifelse(ts_cate == "No Demand", "No Demand", demand_cate)
        ) |>
        dplyr::select(-ts_cate)
    }
  )

  step_demand_cate_new(
    terms = x$terms,
    trained = TRUE,
    role = x$role,
    demand_cate_table = demand_cate_table,
    skip = x$skip,
    id = x$id
  )
}

#' @export
bake.step_demand_cate  <- function(object, new_data, ...) {
  vars <- colnames(object$demand_cate_table)
  ind <- !stringr::str_detect(vars, "num_orders_")
  vars <- vars[ind]

  new_data <- new_data |>
    dplyr::left_join(object$demand_cate_table , by = vars)
}
