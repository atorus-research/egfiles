#' Write Data Files to Egnyte
#'
#' These functions write R objects to data files and upload them to Egnyte.
#' Each function is a thin wrapper that writes to a temporary file using the
#' appropriate package, then handles the upload.
#'
#' @param x A data frame (or R object for `eg_write_rds()`) to write.
#'   For `eg_write_excel()`, can also be a named list of data frames to create
#'   multiple sheets.
#' @param path The Egnyte destination path (e.g., "/Shared/Data/results.csv").
#' @param overwrite If `FALSE` (default), fails if a file already exists at
#'   `path`. Set to `TRUE` to replace existing files.
#' @param delim The field delimiter. Defaults to tab (`"\t"`).
#' @param compress Compression type for RDS files. See [saveRDS()] for options.
#'   Defaults to `TRUE`.
#' @param ... Additional arguments passed to the underlying write function.
#'
#' @return The Egnyte path (invisibly).
#'
#' @details
#' Each function requires an optional package to be installed:
#'
#' | Function | Package | Underlying Function |
#' |----------|---------|---------------------|
#' | `eg_write_csv()` | readr | [readr::write_csv()] |
#' | `eg_write_delim()` | readr | [readr::write_delim()] |
#' | `eg_write_excel()` | writexl | [writexl::write_xlsx()] |
#' | `eg_write_xpt()` | haven | [haven::write_xpt()] |
#' | `eg_write_stata()` | haven | [haven::write_dta()] |
#' | `eg_write_spss()` | haven | [haven::write_sav()] |
#' | `eg_write_rds()` | (base R) | [saveRDS()] |
#'
#' All arguments passed through `...` are forwarded to the underlying function.
#'
#' **Note on SAS files:** Haven can only write SAS transport files (.xpt), not
#' native SAS data files (.sas7bdat). Transport files are compatible with SAS
#' and can be read back with [eg_read_xpt()] or [haven::read_xpt()].
#'
#' @examples
#' \dontrun{
#' # CSV files
#' eg_write_csv(mtcars, "/Shared/Data/mtcars.csv")
#' eg_write_csv(mtcars, "/Shared/Data/mtcars.csv", overwrite = TRUE)
#'
#' # Delimited files
#' eg_write_delim(mtcars, "/Shared/Data/mtcars.tsv")
#' eg_write_delim(mtcars, "/Shared/Data/mtcars.txt", delim = "|")
#'
#' # Excel files
#' eg_write_excel(mtcars, "/Shared/Data/mtcars.xlsx")
#'
#' # Multiple sheets
#' eg_write_excel(
#'   list(cars = mtcars, flowers = iris),
#'   "/Shared/Data/workbook.xlsx"
#' )
#'
#' # SAS transport files
#' eg_write_xpt(mtcars, "/Shared/Data/mtcars.xpt")
#'
#' # Stata files
#' eg_write_stata(mtcars, "/Shared/Data/mtcars.dta")
#'
#' # SPSS files
#' eg_write_spss(mtcars, "/Shared/Data/mtcars.sav")
#'
#' # RDS files (any R object)
#' eg_write_rds(my_model, "/Shared/Data/model.rds")
#' eg_write_rds(large_data, "/Shared/Data/data.rds", compress = "xz")
#' }
#'
#' @seealso
#' - [eg_write()] for uploading raw files without conversion
#' - [eg_read_file] for reading data files from Egnyte
#'
#' @name eg_write_file
NULL

#' @rdname eg_write_file
#' @export
eg_write_csv <- function(x, path, overwrite = FALSE, ...) {
  check_installed("readr")
  local_file <- tempfile(fileext = ".csv")
  on.exit(unlink(local_file), add = TRUE)
  readr::write_csv(x, local_file, ...)
  eg_write(local_file, path, overwrite = overwrite)
}

#' @rdname eg_write_file
#' @export
eg_write_delim <- function(x, path, delim = "\t", overwrite = FALSE, ...) {
  check_installed("readr")
  local_file <- tempfile(fileext = ".txt")
  on.exit(unlink(local_file), add = TRUE)
  readr::write_delim(x, local_file, delim = delim, ...)
  eg_write(local_file, path, overwrite = overwrite)
}

#' @rdname eg_write_file
#' @export
eg_write_xpt <- function(x, path, overwrite = FALSE, ...) {
  check_installed("haven")
  local_file <- tempfile(fileext = ".xpt")
  on.exit(unlink(local_file), add = TRUE)
  haven::write_xpt(x, local_file, ...)
  eg_write(local_file, path, overwrite = overwrite)
}

#' @rdname eg_write_file
#' @export
eg_write_stata <- function(x, path, overwrite = FALSE, ...) {
  check_installed("haven")
  local_file <- tempfile(fileext = ".dta")
  on.exit(unlink(local_file), add = TRUE)
  haven::write_dta(x, local_file, ...)
  eg_write(local_file, path, overwrite = overwrite)
}

#' @rdname eg_write_file
#' @export
eg_write_spss <- function(x, path, overwrite = FALSE, ...) {
  check_installed("haven")
  local_file <- tempfile(fileext = ".sav")
  on.exit(unlink(local_file), add = TRUE)
  haven::write_sav(x, local_file, ...)
  eg_write(local_file, path, overwrite = overwrite)
}

#' @rdname eg_write_file
#' @export
eg_write_excel <- function(x, path, overwrite = FALSE, ...) {
  check_installed("writexl")
  local_file <- tempfile(fileext = ".xlsx")
  on.exit(unlink(local_file), add = TRUE)
  writexl::write_xlsx(x, local_file, ...)
  eg_write(local_file, path, overwrite = overwrite)
}

#' @rdname eg_write_file
#' @export
eg_write_rds <- function(x, path, overwrite = FALSE, compress = TRUE) {
  local_file <- tempfile(fileext = ".rds")
  on.exit(unlink(local_file), add = TRUE)
  saveRDS(x, local_file, compress = compress)
  eg_write(local_file, path, overwrite = overwrite)
}
