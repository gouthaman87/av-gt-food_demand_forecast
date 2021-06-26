## code to prepare `DATASET` dataset goes here

usethis::use_data(DATASET, overwrite = TRUE)

test_train <- readr::read_csv("inst/extdata/train.csv", n_max = 10)
readr::write_csv(test_train, "tests/test-train.csv")

test_test <- readr::read_csv("inst/extdata/test_QoiMO9B.csv", n_max = 10)
readr::write_csv(test_test, "tests/test-test.csv")

test_meal <- readr::read_csv("inst/extdata/meal_info.csv", n_max = 10)
readr::write_csv(test_meal, "tests/test-meal.csv")

