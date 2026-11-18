.validate_data_frame <- function(data) {
  if (!is.data.frame(data)) stop("data must be a data frame.", call. = FALSE)
  if (anyNA(names(data)) || any(!nzchar(names(data))) || anyDuplicated(names(data))) {
    stop("Column names must be non-missing, non-empty and unique.", call. = FALSE)
  }
}

.validate_column <- function(data, column, argument) {
  if (!is.character(column) || length(column) != 1L || is.na(column) ||
      !column %in% names(data)) {
    stop(argument, " must name an existing column.", call. = FALSE)
  }
}
