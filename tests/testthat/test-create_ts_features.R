feature_data <- read_raw_data(train_raw_path = "test-train.csv",
                              test_raw_path = "test-test.csv",
                              meal_info_path = "test-meal.csv") %>%
  separate_long_short()

feature_data <- create_ts_features(data = feature_data[["long_ts"]])

test_that("Check whether time series features created", {
  expect_(ncol(feature_data) %in% "lag_10")
})
