#' Create a scatter plot with optional color and shape aesthetics
#'
#' This function creates a customizable scatter plot using ggplot2.
#'
#' @param data A data frame containing the data to plot.
#' @param x_param Column name (string) for the x-axis.
#' @param y_param Column name (string) for the y-axis.
#' @param color_var An optional column name (string) to color the points.
#' @param shape_var An optional column name (string) to adjust point shapes.
#' @param title The title of the plot.
#' @param x_label A custom label for the x-axis.
#' @param y_label A custom label for the y-axis.
#'
#' @return A ggplot object representing the scatter plot.
#'
#' @examples
#' data(mtcars)
#' create_scatter_plot(mtcars, "mpg", "hp", color_var = "cyl", shape_var = "gear")
#'
#' @import ggplot2
#' @importFrom rlang .data
#' @export

create_scatter_plot <- function(data,
                                x_param,
                                y_param,
                                color_var = NULL,
                                shape_var = NULL,
                                title = "Scatter Plot",
                                x_label = NULL,
                                y_label = NULL)
{
  .validate_data_frame(data)
  .validate_column(data, x_param, "x_param")
  .validate_column(data, y_param, "y_param")
  if (!is.null(color_var)) .validate_column(data, color_var, "color_var")
  if (!is.null(shape_var)) .validate_column(data, shape_var, "shape_var")
  if (!is.null(shape_var) && !is.factor(data[[shape_var]])) {
    data[[shape_var]] <- as.factor(data[[shape_var]])
  }

  mapping <- aes(x = .data[[x_param]], y = .data[[y_param]])
  if (!is.null(color_var)) mapping$colour <- aes(colour = .data[[color_var]])$colour
  if (!is.null(shape_var)) mapping$shape <- aes(shape = .data[[shape_var]])$shape
  p <- ggplot(data, mapping) +
    geom_point(size = 3) +
    ggtitle(title) +
    theme_minimal() +
    theme(plot.title = element_text(hjust = 0.5))
  if (!is.null(x_label)) {
    p <- p + xlab(x_label)
  }

  if (!is.null(y_label)) {
    p <- p + ylab(y_label)
  }

  return(p)
}

