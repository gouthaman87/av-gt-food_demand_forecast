data_list <- read_raw_data(train_raw_path = "test-train.csv",
                           test_raw_path = "test-test.csv",
                           meal_info_path = "test-meal.csv")

train_column_names <- names(data_list[[1]])

test_column_names <- names(data_list[[2]])

test_that("read_raw_data check whether Test/Train data returned", {
  expect_equal(length(data_list), 2)
})

test_that("check Train data column names", {
  expect_equal(length(train_column_names), 11)
  expect_true("id" %in% train_column_names)
  expect_true("week" %in% train_column_names)
  expect_true("center_id" %in%train_column_names)
  expect_true("meal_id" %in% train_column_names)
  expect_true("checkout_price" %in% train_column_names)
  expect_true("base_price" %in% train_column_names)
  expect_true("emailer_for_promotion" %in% train_column_names)
  expect_true("homepage_featured" %in% train_column_names)
  expect_true("num_orders" %in% train_column_names)
  expect_true("category" %in% train_column_names)
  expect_true("cuisine" %in% train_column_names)
})

test_that("check Test data column names", {
  expect_equal(length(test_column_names), 10)
  expect_true("id" %in% test_column_names)
  expect_true("week" %in% test_column_names)
  expect_true("center_id" %in%test_column_names)
  expect_true("meal_id" %in% test_column_names)
  expect_true("checkout_price" %in% test_column_names)
  expect_true("base_price" %in% test_column_names)
  expect_true("emailer_for_promotion" %in% test_column_names)
  expect_true("homepage_featured" %in% test_column_names)
  expect_false("num_orders" %in% test_column_names)
  expect_true("category" %in% test_column_names)
  expect_true("cuisine" %in% test_column_names)
})

