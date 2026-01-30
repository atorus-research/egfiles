# Helper functions for mocking httr2 responses in tests
#
# These helpers create mock response objects that mimic httr2 responses
# without making actual HTTP requests to the Egnyte API.

#' Create a mock httr2 response object
#'
#' @param status HTTP status code
#' @param body Response body (raw or list for JSON)
#' @param headers Named list of headers
#' @return A mock response object compatible with httr2 resp_* functions
mock_response <- function(status = 200, body = raw(0), headers = list()) {
  # httr2 responses need a cache environment for resp_body_json() to work
  cache <- new.env(parent = emptyenv())

  body_raw <- if (is.raw(body)) body else charToRaw(jsonlite::toJSON(body, auto_unbox = TRUE))

  # Create headers structure that httr2 expects
  # httr2 uses a simple named character vector for headers
  headers_vec <- unlist(headers)
  if (is.null(headers_vec)) headers_vec <- character(0)

  structure(
    list(
      status_code = status,
      headers = structure(headers_vec, class = "httr2_headers"),
      body = body_raw,
      cache = cache
    ),
    class = "httr2_response"
  )
}

#' Create a mock JSON response
#'
#' @param data List to be converted to JSON
#' @param status HTTP status code
#' @return Mock response with JSON body
mock_json_response <- function(data, status = 200) {
  mock_response(
    status = status,
    body = charToRaw(jsonlite::toJSON(data, auto_unbox = TRUE)),
    headers = list(`Content-Type` = "application/json")
  )
}

#' Create a mock file download response
#'
#' @param content File content as character or raw
#' @param status HTTP status code
#' @return Mock response for file download
mock_file_response <- function(content = "test content", status = 200) {
  body <- if (is.raw(content)) content else charToRaw(content)
  mock_response(
    status = status,
    body = body,
    headers = list(`Content-Type` = "application/octet-stream")
  )
}

#' Create a mock OAuth token response
#'
#' @param access_token Access token string
#' @param refresh_token Refresh token string (optional)
#' @param expires_in Token expiration in seconds
#' @return Mock response with OAuth tokens
mock_token_response <- function(access_token = "mock_access_token",
                                 refresh_token = NULL,
                                 expires_in = 2592000) {
  data <- list(
    access_token = access_token,
    token_type = "bearer",
    expires_in = expires_in
  )
  if (!is.null(refresh_token)) {
    data$refresh_token <- refresh_token
  }
  mock_json_response(data)
}

#' Create a mock error response
#'
#' @param status HTTP error status code
#' @param error Error type
#' @param error_description Detailed error message
#' @return Mock error response
mock_error_response <- function(status, error = "error", error_description = "An error occurred") {
  mock_json_response(
    list(error = error, error_description = error_description),
    status = status
  )
}

#' Set up standard test authentication
#'
#' Sets up mock credentials for testing without hitting real API
#' @param domain Test domain name
#' @param api_key Test API key
setup_mock_auth <- function(domain = "testcompany", api_key = "test_api_key") {
  withr::local_options(list(
    egfiles.domain = domain,
    egfiles.api_key = api_key,
    egfiles.oauth_app = NULL,
    egfiles.refresh_token = NULL,
    egfiles.token_expires = NULL
  ), .local_envir = parent.frame())

  withr::local_envvar(list(
    EGNYTE_DOMAIN = "",
    EGNYTE_API_KEY = ""
  ), .local_envir = parent.frame())
}

#' Set up OAuth test configuration
#'
#' @param domain Test domain
#' @param client_id Test client ID
#' @param client_secret Test client secret
#' @param refresh_token Optional refresh token
#' @param token_expires Optional token expiration time
setup_mock_oauth <- function(domain = "testcompany",
                              client_id = "test_client_id",
                              client_secret = "test_client_secret",
                              refresh_token = NULL,
                              token_expires = NULL) {
  withr::local_options(list(
    egfiles.domain = domain,
    egfiles.api_key = "test_access_token",
    egfiles.oauth_app = list(
      domain = domain,
      client_id = client_id,
      client_secret = client_secret,
      redirect_uri = "https://localhost/callback"
    ),
    egfiles.refresh_token = refresh_token,
    egfiles.token_expires = token_expires
  ), .local_envir = parent.frame())

  withr::local_envvar(list(
    EGNYTE_DOMAIN = "",
    EGNYTE_API_KEY = "",
    EGNYTE_USERNAME = "",
    EGNYTE_PASSWORD = ""
  ), .local_envir = parent.frame())
}

#' Create a mock request that captures parameters for inspection
#'
#' Returns a function that records calls and can return mock responses
#' @param responses List of responses to return in sequence, or single response
#' @return A list with `fn` (the mock function) and `calls` (recorded calls)
mock_request_performer <- function(responses = list(mock_response())) {
  if (!is.list(responses) || inherits(responses, "httr2_response")) {
    responses <- list(responses)
  }

  env <- new.env()
  env$calls <- list()
  env$call_count <- 0

  fn <- function(req, path = NULL, ...) {
    env$call_count <- env$call_count + 1
    env$calls[[env$call_count]] <- list(req = req, path = path, extra = list(...))

    # Get the response for this call (cycle if more calls than responses)
    idx <- ((env$call_count - 1) %% length(responses)) + 1
    resp <- responses[[idx]]

    # If path is provided, write mock content to that file (simulating download)
    if (!is.null(path) && resp$status_code < 400) {
      writeBin(resp$body, path)
    }

    resp
  }

  list(fn = fn, calls = env$calls, env = env)
}
