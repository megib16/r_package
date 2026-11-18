# explovis

Tools for inspecting missing values and visualizing data in R.

`explovis` is a small package for quick data exploration. It helps you count and visualize missing values, build customizable scatter plots, plot correlation matrices, and export data frames as clean HTML or Markdown tables.

## Installation

Install the development version from GitHub:

```r
# install.packages("remotes")
remotes::install_github("megib16/r_package")
```

The package imports `ggplot2`, `rlang`, `reshape2`, `knitr` and R's `stats` package. Required dependencies are installed automatically.

## Functions

| Function | Purpose |
|---|---|
| `count_missing()` | Count `NA` values in each column of a data frame |
| `plot_missing_heatmap()` | Heatmap showing where values are missing |
| `create_scatter_plot()` | Scatter plot with optional color and shape aesthetics |
| `export_pretty_table()` | Write a data frame to a styled HTML or Markdown table |
| `correlation_matrix_plot()` | Numeric correlation heatmap with pairwise observation counts in the plot data |

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

Counts `NA` and `NaN` using `is.na()`. Blank strings, infinity and sentinel
values such as `-999` are not classified as missing. No imputation is performed.

### Visualize missing data

```r
plot_missing_heatmap(airquality)
```

Returns a `ggplot` object with one tile per cell. Missing cells are red, including
when all cells are missing. Mixed numeric, text, factor and date columns are
supported. Original column order is preserved, including a column named `row`.
Empty data frames produce an explanatory error.

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

Variables are passed as column names (strings), including names containing spaces.
`shape_var` is converted to a factor automatically. Unknown columns produce an
explanatory error before plotting.

### Export a table

```r
export_pretty_table(mtcars, "mtcars.html", format = "html")      # standalone, styled HTML
export_pretty_table(mtcars, "mtcars.md",   format = "markdown")
```

Any other `format` raises an error. Example outputs are in [mtcars.html](mtcars.html) and [mtcars.md](mtcars.md).
HTML includes its own CSS for striped rows, hover highlighting and compact cells;
it requires no external stylesheets. Existing output files are overwritten.

### Correlation matrix

The correlation function is available directly after `library(explovis)`:

```r
p <- correlation_matrix_plot(mtcars, method = "spearman")
p
head(p$data)  # Var1, Var2, value (coefficient), n (complete-pair sample size)
```

It keeps only numeric columns and computes correlations with
`use = "pairwise.complete.obs"`. `method` can be `"pearson"` (default), `"spearman"`
or `"kendall"`. At least two rows and one numeric column are required; infinite
numeric values are rejected. Constant columns and insufficient overlap produce
undefined coefficients, shown in grey with a warning. Pairs of distinct
variables with fewer than three complete observations also produce a warning.

Different pairs may use different rows. Inspect `p$data$n` before interpreting
coefficients; pairwise deletion need not yield a positive-semidefinite matrix.
The plot does not perform significance testing or provide confidence intervals.

## Development

```r
devtools::document()   # regenerate man/ and NAMESPACE
devtools::load_all()   # load the package for interactive work
devtools::check()      # run R CMD check
```

The regression checks in `tests/regression.R` run during `R CMD check`. They cover
missingness, mixed-type heatmaps, correlation methods and pair counts, invalid
inputs, scatter column names, and HTML/Markdown exports.

## Author

Megi Bida (<Megi.Bida@campus.lmu.de>)

## License

MIT
