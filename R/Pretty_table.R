#' Export a Pretty Table from a Data Frame
#'
#' Writes a standalone HTML document with embedded table styles or a Markdown
#' table. Existing files are overwritten. HTML requires no external stylesheet.
#'
#' @param df Data frame to export.
#' @param file Path to the output file.
#' @param format Output format: "html" or "markdown".
#' @return The file is written as a side effect.
#' @examples
#' export_pretty_table(mtcars, tempfile(fileext = ".html"), format = "html")
#' export_pretty_table(mtcars, tempfile(fileext = ".md"), format = "markdown")
#' @export
export_pretty_table <- function(df, file, format = "html") {
  .validate_data_frame(df)
  if (!is.character(format) || length(format) != 1L || is.na(format) ||
      !format %in% c("html", "markdown")) {
    stop('Format must be "html" or "markdown"', call. = FALSE)
  }
  if (!is.character(file) || length(file) != 1L || is.na(file) || !nzchar(file)) {
    stop("file must be a non-empty file path.", call. = FALSE)
  }

  tab <- knitr::kable(df, format = format, escape = TRUE)
  if (format == "html") {
    tab <- paste0(
      '<!DOCTYPE html>\n<html lang="en">\n<head>\n<meta charset="UTF-8">\n',
      '<meta name="viewport" content="width=device-width, initial-scale=1">\n',
      '<title>Data table</title>\n<style>\n',
      'body { font-family: sans-serif; margin: 1.5rem; overflow-x: auto; }\n',
      'table { border-collapse: collapse; width: 100%; }\n',
      'th, td { padding: .35rem .6rem; border-bottom: 1px solid #ddd; }\n',
      'tbody tr:nth-child(odd) { background-color: #f5f5f5; }\n',
      'tbody tr:hover { background-color: #e8f2fa; }\n',
      '</style>\n</head>\n<body>\n', as.character(tab),
      '\n</body>\n</html>'
    )
  }
  writeLines(enc2utf8(as.character(tab)), file, useBytes = TRUE)
}
