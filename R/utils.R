#' Build Egnyte API URL
#'
#' Constructs the full URL for an Egnyte API endpoint.
#'
#' @param endpoint The API endpoint path (e.g., "fs-content/Shared/file.txt")
#' @param domain Egnyte domain. If NULL, uses stored credentials.
#'
#' @return Full URL string
#' @noRd
eg_url <- function(endpoint, domain = NULL) {
  if (is.null(domain)) {
    domain <- eg_get_domain()
  }
  paste0("https://", domain, ".egnyte.com/pubapi/v1/", endpoint)
}

#' Create authenticated httr2 request
#'
#' @param endpoint API endpoint path
#' @return httr2 request object with authentication header
#' @noRd
eg_request <- function(endpoint) {
  auth <- eg_get_auth()

  httr2::request(eg_url(endpoint, auth$domain)) |>
    httr2::req_headers(Authorization = paste("Bearer", auth$api_key))
}

#' Handle Egnyte API errors
#'
#' Translates HTTP status codes to user-friendly error messages.
#'
#' @param resp httr2 response object
#' @noRd
eg_check_response <- function(resp) {
  status <- httr2::resp_status(resp)

  if (status >= 400) {
    msg <- switch(
      as.character(status),
      "401" = "Invalid API key or expired token.",
      "403" = "Access denied. Check your permissions for this path.",
      "404" = "File or folder not found.",
      "409" = "File already exists. Use overwrite = TRUE to replace.",
      paste0("Egnyte API error (HTTP ", status, ").")
    )
    cli::cli_abort(msg)
  }

  invisible(resp)
}

#' Clean Egnyte path
#'
#' Ensures path starts with "/" and removes trailing slashes.
#'
#' @param path Egnyte path
#' @return Cleaned path
#' @noRd
eg_clean_path <- function(path) {
  path <- sub("^/*", "/", path)
  sub("/$", "", path)
}
