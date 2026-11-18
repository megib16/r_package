#' Plot a Correlation Matrix Heatmap
#'
#' Computes and visualizes numeric-variable correlations using [stats::cor()]
#' with pairwise-complete observations. Non-numeric columns are excluded.
#' Infinite numeric values are rejected.
#'
#' @param data A data frame with at least two rows and one numeric column.
#' @param method Correlation coefficient method: one of "pearson" (default),
#'   "spearman", or "kendall".
#' @param title The title for the plot.
#' @return A ggplot heatmap. Its `data` contains `Var1`, `Var2`, the correlation
#'   `value`, and `n`, the number of complete observations for that pair.
#' @details Undefined correlations are shown in grey and cause a warning.
#'   A warning also identifies pairs of distinct variables with fewer than
#'   three complete observations. Pairwise deletion uses different rows for
#'   different pairs and need not produce a positive-semidefinite matrix.
#'   No imputation, significance testing or confidence intervals are performed.
#' @examples
#' correlation_matrix_plot(mtcars, method = "pearson")
#' @import ggplot2
#' @importFrom rlang .data
#' @importFrom reshape2 melt
#' @export
correlation_matrix_plot <- function(data, method = "pearson",
                                    title = "Correlation Matrix") {
  .validate_data_frame(data)
  method <- match.arg(method, c("pearson", "spearman", "kendall"))
  num_data <- data[vapply(data, is.numeric, logical(1))]
  if (ncol(num_data) == 0L || nrow(num_data) < 2L) {
    stop("data must contain at least two rows and one numeric column.", call. = FALSE)
  }
  if (any(vapply(num_data, function(x) any(is.infinite(x)), logical(1)))) {
    stop("Numeric columns must not contain infinite values.", call. = FALSE)
  }

  n <- crossprod(!is.na(as.matrix(num_data)))
  usable <- vapply(num_data, function(x) length(unique(x[!is.na(x)])) >= 2L,
                   logical(1))
  corr_mat <- matrix(NA_real_, ncol(num_data), ncol(num_data),
                     dimnames = list(names(num_data), names(num_data)))
  if (any(usable)) {
    # A pair can be constant on its overlap even when both full columns vary.
    # Replace cor's zero-variance warning with a single explicit warning below.
    corr_mat[usable, usable] <- suppressWarnings(stats::cor(
      num_data[usable], use = "pairwise.complete.obs", method = method
    ))
  }
  if (anyNA(corr_mat)) {
    warning("Some correlations are undefined (constant columns or insufficient complete pairs).",
            call. = FALSE)
  }
  if (any(n[upper.tri(n)] < 3L)) {
    warning("Some variable pairs have fewer than three complete observations; inspect plot$data$n.",
            call. = FALSE)
  }

  corr_melt <- reshape2::melt(corr_mat)
  corr_melt$n <- as.vector(n)
  ggplot(corr_melt, aes(.data$Var1, .data$Var2, fill = .data$value)) +
    geom_tile(color = "white") +
    scale_fill_gradient2(low = "#00A1DE", high = "#FF4563", mid = "beige",
                         midpoint = 0, limits = c(-1, 1), na.value = "grey50",
                         space = "Lab", name = "Correlation") +
    theme_minimal() +
    ggtitle(title) +
    theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1))
}
