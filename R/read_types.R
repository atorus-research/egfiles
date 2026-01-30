#' Read Data Files from Egnyte
#'
#' These functions download data files from Egnyte and read them into R using
#' the appropriate package. Each function is a thin wrapper that handles the
#' file transfer, then delegates to the underlying reader.
#'
#' @param path The Egnyte path to the file (e.g., "/Shared/Data/myfile.csv").
#' @param delim The field delimiter. Defaults to tab (`"\t"`).
#' @param sheet Sheet to read. Either a string (sheet name) or an integer
#'   (sheet position). Defaults to the first sheet.
#' @param ... Additional arguments passed to the underlying read function.
#'
#' @return
#' - For tabular data: A tibble (or data frame for RDS files containing
#'   data frames).
#' - For RDS files: The R object stored in the file.
#'
#' Haven-based readers (`eg_read_sas()`, `eg_read_xpt()`, `eg_read_stata()`,
#' `eg_read_spss()`) return tibbles with labelled columns preserving variable
#' labels and formats from the source file.
#'
#' @details
#' Each function requires an optional package to be installed:
#'
#' | Function | Package | Underlying Function |
#' |----------|---------|---------------------|
#' | `eg_read_csv()` | readr | [readr::read_csv()] |
#' | `eg_read_delim()` | readr | [readr::read_delim()] |
#' | `eg_read_excel()` | readxl | [readxl::read_excel()] |
#' | `eg_read_sas()` | haven | [haven::read_sas()] |
#' | `eg_read_xpt()` | haven | [haven::read_xpt()] |
#' | `eg_read_stata()` | haven | [haven::read_dta()] |
#' | `eg_read_spss()` | haven | [haven::read_sav()] |
#' | `eg_read_rds()` | (base R) | [readRDS()] |
#'
#' All arguments passed through `...` are forwarded to the underlying function,
#' so you can use any options those functions support (e.g., `col_types` for
#' readr functions, `encoding` for haven functions).
#'
#' @examples
#' \dontrun{
#' # CSV files
#' df <- eg_read_csv("/Shared/Data/mydata.csv")
#' df <- eg_read_csv("/Shared/Data/mydata.csv", col_types = "ccn")
#'
#' # Delimited files
#' df <- eg_read_delim("/Shared/Data/mydata.txt")
#' df <- eg_read_delim("/Shared/Data/mydata.txt", delim = "|")
#'
#' # Excel files
#' df <- eg_read_excel("/Shared/Data/workbook.xlsx")
#' df <- eg_read_excel("/Shared/Data/workbook.xlsx", sheet = "Summary")
#'
#' # SAS files
#' df <- eg_read_sas("/Shared/Data/mydata.sas7bdat")
#' df <- eg_read_xpt("/Shared/Data/mydata.xpt")
#'
#' # Stata files
#' df <- eg_read_stata("/Shared/Data/mydata.dta")
#'
#' # SPSS files
#' df <- eg_read_spss("/Shared/Data/mydata.sav")
#'
#' # RDS files (any R object)
#' obj <- eg_read_rds("/Shared/Data/model.rds")
#' }
#'
#' @seealso
#' - [eg_read()] for downloading raw files without parsing
#' - [eg_write_file] for writing data files to Egnyte
#'
#' @name eg_read_file
NULL

#' @rdname eg_read_file
#' @export
eg_read_csv <- function(path, ...) {
  check_installed("readr")
  local_file <- eg_read(path)
  readr::read_csv(local_file, ...)
}

#' @rdname eg_read_file
#' @export
eg_read_delim <- function(path, delim = "\t", ...) {
  check_installed("readr")
  local_file <- eg_read(path)
  readr::read_delim(local_file, delim = delim, ...)
}

#' @rdname eg_read_file
#' @export
eg_read_sas <- function(path, ...) {
  check_installed("haven")
  local_file <- eg_read(path)
  haven::read_sas(local_file, ...)
}

#' @rdname eg_read_file
#' @export
eg_read_xpt <- function(path, ...) {
  check_installed("haven")
  local_file <- eg_read(path)
  haven::read_xpt(local_file, ...)
}

#' @rdname eg_read_file
#' @export
eg_read_stata <- function(path, ...) {
  check_installed("haven")
  local_file <- eg_read(path)
  haven::read_dta(local_file, ...)
}

#' @rdname eg_read_file
#' @export
eg_read_spss <- function(path, ...) {
  check_installed("haven")
  local_file <- eg_read(path)
  haven::read_sav(local_file, ...)
}

#' @rdname eg_read_file
#' @export
eg_read_excel <- function(path, sheet = NULL, ...) {
  check_installed("readxl")
  local_file <- eg_read(path)
  readxl::read_excel(local_file, sheet = sheet, ...)
}

#' @rdname eg_read_file
#' @export
eg_read_rds <- function(path) {
  local_file <- eg_read(path)
  readRDS(local_file)
}

#' Check if a Package is Installed
#'
#' @param pkg Package name
#' @noRd
check_installed <- function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    cli::cli_abort(c(
      "The {.pkg {pkg}} package is required for this function.",
      "i" = "Install it with: {.code install.packages(\"{pkg}\")}"
    ))
  }
}
