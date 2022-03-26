# data_list <- read_raw_data(train_raw_path = "/tests/testthat/test-train.csv",
#                            test_raw_path = "/tests/testthat/test-test.csv",
#                            meal_info_path = "/tests/testthat/test-meal.csv")
#
# train_column_names <- names(data_list[[1]])
#
# test_column_names <- names(data_list[[2]])
#
# test_that("read_raw_data check whether Test/Train data returned", {
#   expect_equal(length(data_list), 2)
#   expect_identical(names(data_list), c("train_data", "test_data"))
# })
#
# test_that("check Train data column names", {
#   expect_equal(length(train_column_names), 11)
#   expect_gt(nrow(data_list[[1]]), 5)
#   expect_identical(
#     train_column_names,
#     c(
#       "id", "week", "center_id", "meal_id", "checkout_price", "base_price", "emailer_for_promotion", "homepage_featured", "num_orders", "category", "cuisine"
#     )
#   )
# })
#
# test_that("check Test data column names", {
#   expect_equal(length(test_column_names), 10)
#   expect_gt(nrow(data_list[[2]]), 5)
#   expect_identical(
#     test_column_names,
#     c(
#       "id", "week", "center_id", "meal_id", "checkout_price", "base_price", "emailer_for_promotion", "homepage_featured", "category", "cuisine"
#     )
#   )
# })

