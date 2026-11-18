#' Plot a Heatmap of Missing Data
#'
#' Visualizes missingness across columns of different types. Missing values
#' are identified with [is.na()]; values are not imputed.
#'
#' @param df A data frame with at least one row and one column.
#' @return A ggplot object showing a heatmap of missingness.
#' @examples
#' plot_missing_heatmap(airquality)
#' @import ggplot2
#' @importFrom rlang .data
#' @export
plot_missing_heatmap <- function(df) {
  .validate_data_frame(df)
  if (nrow(df) == 0L || ncol(df) == 0L) {
    stop("df must contain at least one row and one column.", call. = FALSE)
  }
  # Reshape logical indicators rather than incompatible source values.
  missing <- vapply(df, is.na, logical(nrow(df)))
  long <- data.frame(
    variable = factor(rep(names(df), each = nrow(df)), levels = names(df)),
    row = rep(seq_len(nrow(df)), times = ncol(df)),
    missing = as.vector(missing)
  )
  ggplot(long, aes(x = .data$variable, y = .data$row, fill = .data$missing)) +
    geom_raster() +
    scale_fill_manual(
      values = c("FALSE" = "#FFFFEC", "TRUE" = "red"),
      limits = c(FALSE, TRUE), breaks = c(FALSE, TRUE),
      labels = c("Present", "Missing"), drop = FALSE
    ) +
    labs(x = "Variable", y = "Row", fill = "Missing data?",
         title = "Missing Data Heatmap") +
    theme_minimal() +
    theme(axis.text.y = element_blank(), axis.ticks.y = element_blank())
}
