data_list <- read_raw_data(train_raw_path = "test-train.csv",
                           test_raw_path = "test-test.csv",
                           meal_info_path = "test-meal.csv")

transformed_data_list <- separate_long_short(data_list = data_list)

long_data <- transformed_data_list[[1]] %>%
  dplyr::filter(center_id == 10, meal_id == 1062)

short_data <- transformed_data_list[[2]] %>%
  dplyr::filter(center_id == 61, meal_id == 2956)

test_that("Check whether long/short data returned", {
  expect_equal(length(transformed_data_list), 2)
  expect_true(nrow(long_data) >= 20)
  expect_true(nrow(short_data) < 20)
})


