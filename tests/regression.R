library(explovis)

expect_error <- function(expr, pattern) {
  result <- tryCatch({force(expr); NULL}, error = identity)
  stopifnot(inherits(result, "error"), grepl(pattern, conditionMessage(result)))
}
capture_warnings <- function(expr) {
  messages <- character()
  value <- withCallingHandlers(expr, warning = function(w) {
    messages <<- c(messages, conditionMessage(w))
    invokeRestart("muffleWarning")
  })
  list(value = value, warnings = messages)
}
build <- function(p) ggplot2::ggplot_build(p)$data[[1]]

# Missingness semantics and empty inputs.
d <- data.frame(x = c(NA, NaN, Inf, -999), label = c("", NA, "NA", "ok"))
stopifnot(identical(count_missing(d)$Missing, c(2L, 1L)))
stopifnot(nrow(count_missing(data.frame())) == 0L)
stopifnot(identical(count_missing(data.frame(x = numeric()))$Missing, 0L))
expect_error(count_missing(1:3), "data frame")
bad <- data.frame(x = 1, y = 2); names(bad) <- c("x", "x")
expect_error(count_missing(bad), "unique")

# Mixed columns and a source column named row must all be retained.
d <- data.frame(row = c(NA, 10), x = c(1, NA), label = c("a", NA),
                group = factor(c(NA, "b")), day = as.Date(c("2026-01-01", NA)))
original <- d
p <- plot_missing_heatmap(d)
stopifnot(identical(d, original), nrow(p$data) == nrow(d) * ncol(d))
stopifnot(identical(levels(p$data$variable), names(d)))
stopifnot(identical(p$data$missing, as.vector(is.na(d))))
stopifnot(identical(build(p)$fill, ifelse(as.vector(is.na(d)), "red", "#FFFFEC")))
stopifnot(all(build(plot_missing_heatmap(data.frame(x = c(NA, NA))))$fill == "red"))
stopifnot(all(build(plot_missing_heatmap(data.frame(x = 1:2)))$fill == "#FFFFEC"))
stopifnot(nrow(build(plot_missing_heatmap(data.frame(x = NA, y = "a")))) == 2L)
expect_error(plot_missing_heatmap(data.frame(x = numeric())), "at least one")
expect_error(plot_missing_heatmap(data.frame()), "at least one")

# Coefficients and pair counts must match independent stats calculations.
d <- data.frame(x = c(1, 2, NA, 3, 4), y = c(2, 4, 5, NA, 6),
                z = c(3, 1, 2, 4, 5), label = letters[1:5])
numeric_data <- d[1:3]
for (method in c("pearson", "spearman", "kendall")) {
  p <- correlation_matrix_plot(d, method)
  expected <- stats::cor(numeric_data, use = "pairwise.complete.obs", method = method)
  stopifnot(isTRUE(all.equal(p$data$value, as.vector(expected))))
  stopifnot(identical(p$data$n, as.vector(crossprod(!is.na(numeric_data)))))
  stopifnot(nrow(build(p)) == 9L)
}
stopifnot(correlation_matrix_plot(data.frame(x = 1:3))$data$value == 1)
low <- capture_warnings(correlation_matrix_plot(data.frame(x = c(1, 2, NA), y = 1:3)))
stopifnot(any(grepl("fewer than three", low$warnings)))
stopifnot(low$value$data$n[2] == 2)
undefined <- capture_warnings(correlation_matrix_plot(data.frame(x = 1:3, constant = 1,
                                                                absent = NA_real_)))
stopifnot(any(grepl("undefined", undefined$warnings)))
stopifnot(all(is.na(undefined$value$data$value[-1])))
stopifnot(all(build(undefined$value)$fill[-1] == "grey50"))
empty <- capture_warnings(correlation_matrix_plot(data.frame(x = rep(NA_real_, 3))))
stopifnot(is.na(empty$value$data$value), empty$value$data$n == 0)
expect_error(correlation_matrix_plot(data.frame(label = letters[1:3])), "numeric column")
expect_error(correlation_matrix_plot(data.frame(x = numeric())), "two rows")
expect_error(correlation_matrix_plot(data.frame(x = 1)), "two rows")
expect_error(correlation_matrix_plot(data.frame(x = c(1, Inf))), "infinite")
expect_error(correlation_matrix_plot(mtcars, "bogus"), "arg")

# String column names are literal, including spaces, and errors occur at the API.
d <- data.frame("surface score" = 1:3, y = 3:1, group = c(1, 2, 1),
                check.names = FALSE)
original <- d
p <- create_scatter_plot(d, "surface score", "y", color_var = "group", shape_var = "group")
b <- build(p)
stopifnot(identical(b$x, as.numeric(d[[1]])), is.factor(p$data$group), identical(d, original))
expect_error(create_scatter_plot(d, "missing", "y"), "x_param")
expect_error(create_scatter_plot(d, "y", "missing"), "y_param")
expect_error(create_scatter_plot(d, "y", "y", shape_var = "missing"), "shape_var")
expect_error(create_scatter_plot(d, "y", "y", color_var = "missing"), "color_var")
expect_error(create_scatter_plot(d, c("y", "group"), "y"), "x_param")

# HTML is standalone, includes embedded styling, and escapes cell contents.
d <- data.frame(label = c("<script>alert(1)</script>", "Megi & R"), value = 1:2)
html <- tempfile(fileext = ".html")
md <- tempfile(fileext = ".md")
export_pretty_table(d, html)
contents <- paste(readLines(html, encoding = "UTF-8"), collapse = "\n")
stopifnot(grepl("<!DOCTYPE html>", contents, fixed = TRUE))
stopifnot(grepl("<style>", contents, fixed = TRUE), grepl("</html>", contents, fixed = TRUE))
stopifnot(grepl("&lt;script&gt;", contents, fixed = TRUE))
stopifnot(!grepl("<script>", contents, fixed = TRUE))
export_pretty_table(mtcars[1:2, ], md, "markdown")
stopifnot(grepl("Mazda RX4", paste(readLines(md), collapse = "\n"), fixed = TRUE))
expect_error(export_pretty_table(d, html, "csv"), "Format must")
expect_error(export_pretty_table(d, html, NA_character_), "Format must")
expect_error(export_pretty_table(d, html, c("html", "markdown")), "Format must")
expect_error(export_pretty_table(d, ""), "file must")
unlink(c(html, md))
