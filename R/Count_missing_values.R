#' Count Missing (NA) Values in Each Column
#'
#' @param df A data frame.
#' @return A data frame with the count of missing values per column.
#' @details Counts both `NA` and `NaN`, as determined by [is.na()]. Blank
#'   strings, infinite values and numeric sentinels are not treated as missing.
#' @examples
#' count_missing(mtcars)
#' count_missing(airquality)
#' @export
count_missing <- function(df) {
  .validate_data_frame(df)
  missing_counts <- vapply(df, function(x) sum(is.na(x)), numeric(1))
  data.frame(
    Variable = names(missing_counts),
    Missing = as.integer(missing_counts),
    row.names = NULL
  )
}
