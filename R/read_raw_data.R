read_raw_data <- function(train_raw_path = as.character()) {
  tryCatch(
    {
      train_data <- data.table::fread(train_raw_path)
    },
    error = function(e) {
      logger::log_error("Exception in read_raw_data()")
    }
  )
}
