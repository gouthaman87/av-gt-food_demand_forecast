#' Title
#'
#' @param fcast_df
#' @param actual_df
#'
#' @return
#' @export
#'
#' @examples
plot_forecast <- function(
  fcast_df,
  actual_df
) {
  fcast_results <- fcast_df |>
    dplyr::select(-num_orders) |>
    dplyr::rename(num_orders = .value) |>

    dplyr::bind_rows(
      actual_df |>
        dplyr::select(
          dplyr::any_of(colnames(fcast_df)),
          num_orders
        ) |>
        dplyr::mutate(.model_desc = "ACTUAL")
    )

  p <- fcast_results |>
    dplyr::distinct(meal_id, center_id) |>
    dplyr::sample_n(9) |>
    dplyr::inner_join(fcast_results, by = c("center_id", "meal_id")) |>
    dplyr::mutate(facet_id = paste0(center_id, "_", meal_id)) |>

    ggplot2::ggplot(ggplot2::aes(date, num_orders)) +
    ggplot2::geom_line(ggplot2::aes(col = .model_desc)) +
    ggplot2::theme_minimal() +
    viridis::scale_color_viridis(discrete = TRUE) +
    ggplot2::facet_wrap(~facet_id, ncol = 3, scales = "free")

  plotly::ggplotly(p)
}


#' Title
#'
#' @param ...
#'
#' @return
#' @export
#'
#' @examples
ggplot_imp <- function(...) {
  obj <- list(...)
  metric_name <- attr(obj[[1]], "loss_name")
  metric_lab <- paste(metric_name,
                      "after permutations\n(higher indicates more important)")

  full_vip <- dplyr::bind_rows(obj) |>
    dplyr::filter(variable != "_baseline_")

  perm_vals <- full_vip %>%
    dplyr::filter(variable == "_full_model_") |>
    dplyr::group_by(label) |>
    dplyr::summarise(
      dropout_loss = mean(dropout_loss),
      .groups = "drop"
    )

  p <- full_vip %>%
    dplyr::filter(variable != "_full_model_") %>%
    dplyr::mutate(variable = forcats::fct_reorder(variable, dropout_loss)) %>%
    ggplot2::ggplot(ggplot2::aes(dropout_loss, variable))

  if(length(obj) > 1) {
    p <- p +
      ggplot2::facet_wrap(dplyr::vars(label)) +
      ggplot2::geom_vline(
        data = perm_vals,
        ggplot2::aes(xintercept = dropout_loss, color = label),
        size = 1.4,
        lty = 2,
        alpha = 0.7
      ) +
      ggplot2::geom_boxplot(
        ggplot2::aes(color = label, fill = label), alpha = 0.2
      )
  } else {
    p <- p +
      ggplot2::geom_vline(
        data = perm_vals,
        ggplot2::aes(xintercept = dropout_loss),
        size = 1.4,
        lty = 2,
        alpha = 0.7
      ) +
      ggplot2::geom_boxplot(fill = "#91CBD765", alpha = 0.4)

  }
  p +
    ggplot2::theme_minimal() +
    viridis::scale_fill_viridis() +
    ggplot2::theme(legend.position = "none") +
    ggplot2::labs(
      x = metric_lab,
      y = NULL,
      fill = NULL,
      color = NULL
    )
}


create_report <- function(DF = is.data.frame()) {

  DF <- DF |>
    dplyr::distinct(ts_id, .model_desc, idx = 1) |>
    tidyr::pivot_wider(ts_id, names_from = .model_desc, values_from = idx)

  # * Total Item ----
  N = nrow(DF)

  # * Statistics Item ----
  S = sum(DF$Statistics, na.rm = TRUE)

  # * ML Item ----
  M = DF |>
    dplyr::filter_at(dplyr::vars(dplyr::matches("recipe")), ~.x == 1) |>
    nrow()

  common_item <- DF |>
    dplyr::filter_at(
      dplyr::vars(dplyr::matches("Statistics|recipe")), ~.x == 1
    ) |>
    dplyr::select(-dplyr::matches("Statistics|recipe"))

  list(
    N = N,
    S = S,
    M = M,
    common_item = common_item
  )
}
