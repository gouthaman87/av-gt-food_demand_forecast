#' Title
#'
#' @param ts_splits
#'
#' @return
#' @export
#'
#' @examples
create_recipe <- function(ts_splits) {
  recipes::recipe(num_orders ~ ., data = rsample::training(ts_splits)) %>%
    recipes::update_role(id, week_no, date, new_role = "ID") %>%
    recipes::step_rm(center_id, meal_id) %>%
    recipes::step_dummy(recipes::all_nominal(), one_hot = TRUE)
}
