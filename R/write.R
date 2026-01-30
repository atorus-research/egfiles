#' Upload a File to Egnyte
#'
#' Uploads a local file to Egnyte cloud storage.
#'
#' @param file Local path to the file to upload.
#' @param path The Egnyte destination path (e.g., "/Shared/Documents/file.txt").
#' @param overwrite If FALSE (default), the upload will fail if a file already
#'   exists at the destination. Set to TRUE to replace existing files.
#'
#' @return The Egnyte path (invisibly).
#'
#' @examples
#' \dontrun{
#' # Upload a file
#' eg_write("local_report.pdf", "/Shared/Documents/report.pdf")
#'
#' # Overwrite an existing file
#' eg_write("updated_data.csv", "/Shared/Data/data.csv", overwrite = TRUE)
#' }
#'
#' @export
eg_write <- function(file, path, overwrite = FALSE) {
  if (!file.exists(file)) {
    cli::cli_abort("File not found: {.file {file}}")
  }

  path <- eg_clean_path(path)
  endpoint <- paste0("fs-content", path)

  resp <- eg_request(endpoint) |>
    httr2::req_headers(`Content-Type` = "application/octet-stream") |>
    httr2::req_body_file(file) |>
    httr2::req_error(is_error = function(resp) FALSE) |>
    httr2::req_perform()

  status <- httr2::resp_status(resp)

  if (status == 409 && !overwrite) {
    cli::cli_abort(c(
      "File already exists at {.path {path}}.",
      "i" = "Use {.code overwrite = TRUE} to replace the existing file."
    ))
  }

  eg_check_response(resp)

  cli::cli_alert_success("Uploaded {.file {file}} to {.path {path}}")

  invisible(path)
}
