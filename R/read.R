#' Download a File from Egnyte
#'
#' Downloads a file from Egnyte cloud storage to a local path.
#'
#' @param path The Egnyte path to the file (e.g., "/Shared/Documents/file.txt").
#' @param destfile Local file path where the file will be saved. If NULL
#'   (default), the file is downloaded to a temporary file.
#'
#' @return The local file path (invisibly).
#'
#' @examples
#' \dontrun{
#' # Download to a specific location
#' eg_read("/Shared/Documents/report.pdf", "local_report.pdf")
#'
#' # Download to a temp file
#' local_path <- eg_read("/Shared/Documents/data.csv")
#' read.csv(local_path)
#' }
#'
#' @export
eg_read <- function(path, destfile = NULL) {
  path <- eg_clean_path(path)

  if (is.null(destfile)) {
    ext <- tools::file_ext(path)
    destfile <- tempfile(fileext = if (ext != "") paste0(".", ext) else "")
  }

  endpoint <- paste0("fs-content", path)

  resp <- eg_request(endpoint) |>
    httr2::req_error(is_error = function(resp) FALSE) |>
    httr2::req_perform(path = destfile)

  eg_check_response(resp)

  cli::cli_alert_success("Downloaded {.path {path}} to {.file {destfile}}")

  invisible(destfile)
}
