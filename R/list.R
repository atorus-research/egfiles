#' List Files in an Egnyte Directory
#'
#' Returns a character vector of full file paths within the specified
#' Egnyte directory.
#'
#' @param path The Egnyte path to the directory (e.g., "/Shared/Documents").
#' @param recursive If TRUE, recursively list files in subdirectories.
#'   Defaults to FALSE.
#'
#' @return A character vector of full file paths.
#'
#' @examples
#' \dontrun{
#' # List files in a directory
#' eg_list("/Shared/Documents")
#'
#' # Recursively list all files
#' eg_list("/Shared/Documents", recursive = TRUE)
#' }
#'
#' @export
eg_list <- function(path, recursive = FALSE) {
  path <- eg_clean_path(path)

  files <- eg_list_single(path)

  if (recursive) {
    folders <- eg_list_folders(path)
    for (folder in folders) {
      files <- c(files, eg_list(folder, recursive = TRUE))
    }
  }

  files
}

#' URL-encode path segments
#'
#' Encodes each segment of a path while preserving slashes.
#'
#' @param path Egnyte path
#' @return URL-encoded path
#' @noRd
eg_encode_path <- function(path) {
  segments <- strsplit(path, "/", fixed = TRUE)[[1]]
  encoded <- vapply(segments, utils::URLencode, character(1), reserved = TRUE)
  paste(encoded, collapse = "/")
}

#' List files in a single directory (non-recursive)
#'
#' @param path Cleaned Egnyte path
#' @return Character vector of file paths
#' @noRd
eg_list_single <- function(path) {
  endpoint <- paste0("fs", eg_encode_path(path))


  resp <- eg_request(endpoint) |>
    httr2::req_error(is_error = function(resp) FALSE) |>
    httr2::req_perform()

  eg_check_response(resp)

  body <- httr2::resp_body_json(resp)

  if (!identical(body$is_folder, TRUE)) {
    cli::cli_abort("{.path {path}} is not a directory.")
  }

  files <- body$files %||% list()
  vapply(files, function(f) f$path, character(1))
}

#' List folders in a single directory
#'
#' @param path Cleaned Egnyte path
#' @return Character vector of folder paths
#' @noRd
eg_list_folders <- function(path) {
  endpoint <- paste0("fs", eg_encode_path(path))

  resp <- eg_request(endpoint) |>
    httr2::req_error(is_error = function(resp) FALSE) |>
    httr2::req_perform()

  eg_check_response(resp)

  body <- httr2::resp_body_json(resp)

  folders <- body$folders %||% list()
  vapply(folders, function(f) f$path, character(1))
}
