# explovis

Tools for handling missing values and visualizing data in R.

`explovis` is a small package for quick data exploration. It helps you count and visualize missing values, build customizable scatter plots, plot correlation matrices, and export data frames as clean HTML or Markdown tables.

## Installation

Install the development version from GitHub:

```r
# install.packages("remotes")
remotes::install_github("megib16/r_package")
```

The package imports `ggplot2`, `dplyr`, `tidyr`, `reshape2`, `knitr`, `kableExtra` and `magrittr`. They are installed automatically.

## Functions

| Function | Purpose |
|---|---|
| `count_missing()` | Count `NA` values in each column of a data frame |
| `plot_missing_heatmap()` | Heatmap showing where values are missing |
| `create_scatter_plot()` | Scatter plot with optional color and shape aesthetics |
| `export_pretty_table()` | Write a data frame to a styled HTML or Markdown table |
| `correlation_matrix_plot()` | Heatmap of the correlation matrix of numeric columns (see note below) |

## Usage

```r
library(explovis)
```

### Count missing values

```r
count_missing(airquality)
#>   Variable Missing
#> 1    Ozone      37
#> 2  Solar.R       7
#> 3     Wind       0
#> ...
```

### Visualize missing data

```r
plot_missing_heatmap(airquality)
```

Returns a `ggplot` object with one tile per cell. Missing cells are red.

### Scatter plot

```r
create_scatter_plot(
  mtcars, "mpg", "hp",
  color_var = "cyl",
  shape_var = "gear",
  title     = "Fuel economy vs. horsepower",
  x_label   = "Miles per gallon",
  y_label   = "Horsepower"
)
```

Variables are passed as column names (strings). `shape_var` is converted to a factor automatically.

### Export a table

```r
export_pretty_table(mtcars, "mtcars.html", format = "html")      # striped, hoverable Bootstrap table
export_pretty_table(mtcars, "mtcars.md",   format = "markdown")
```

Any other `format` raises an error. Example outputs are in [mtcars.html](mtcars.html) and [mtcars.md](mtcars.md).

### Correlation matrix

`correlation_matrix_plot()` is documented but **not currently exported**, so call it with the `:::` operator:

```r
explovis:::correlation_matrix_plot(mtcars, method = "spearman")
```

It keeps only numeric columns and computes correlations with `use = "pairwise.complete.obs"`. `method` can be `"pearson"` (default), `"spearman"` or `"kendall"`. To make it available after `library(explovis)`, add `#' @export` to its roxygen block and re-run `devtools::document()`.

## Development

```r
devtools::document()   # regenerate man/ and NAMESPACE
devtools::load_all()   # load the package for interactive work
devtools::check()      # run R CMD check
```

## Author

Megi Bida (<Megi.Bida@campus.lmu.de>)

## License

MIT
