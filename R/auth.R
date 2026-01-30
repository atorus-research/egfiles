#' Set Egnyte Authentication Credentials
#'
#' Stores Egnyte domain and API key for use in subsequent API calls.
#' Credentials can also be set via environment variables `EGNYTE_DOMAIN`
#' and `EGNYTE_API_KEY`.
#'
#' @param domain Your Egnyte domain (the subdomain part of yourcompany.egnyte.com)
#' @param api_key Your Egnyte API key or OAuth access token
#'
#' @return Invisibly returns a list with the stored credentials.
#'
#' @examples
#' \dontrun{
#' eg_auth("mycompany", "my_api_key_here")
#' }
#'
#' @export
eg_auth <- function(domain, api_key) {
  if (missing(domain) || missing(api_key)) {
    cli::cli_abort("Both {.arg domain} and {.arg api_key} are required.")
  }

  options(
    egfiles.domain = domain,
    egfiles.api_key = api_key
  )

  cli::cli_alert_success("Egnyte credentials set for domain: {.val {domain}}")

  invisible(list(domain = domain, api_key = api_key))
}

#' Get Current Egnyte Credentials
#'
#' Retrieves stored Egnyte credentials from R options or environment variables.
#' Priority: R options > environment variables.
#'
#' If OAuth tokens are being used and the access token is expired, this
#' function will automatically attempt to refresh it.
#'
#' @return A list with `domain` and `api_key` components.
#'
#' @examples
#' \dontrun{
#' eg_get_auth()
#' }
#'
#' @noRd
eg_get_auth <- function() {
 # Check if OAuth token needs refresh
  token_expires <- getOption("egfiles.token_expires")
  if (!is.null(token_expires) && Sys.time() > token_expires) {
    refresh_token <- getOption("egfiles.refresh_token")
    if (!is.null(refresh_token)) {
      cli::cli_alert_info("Access token expired, refreshing...")
      tryCatch(
        eg_oauth_refresh(),
        error = function(e) {
          cli::cli_warn("Failed to refresh token: {e$message}")
        }
      )
    }
  }

  domain <- getOption("egfiles.domain", Sys.getenv("EGNYTE_DOMAIN", ""))
  api_key <- getOption("egfiles.api_key", Sys.getenv("EGNYTE_API_KEY", ""))

  if (domain == "" || api_key == "") {
    cli::cli_abort(c(
      "Egnyte credentials not found.",
      "i" = "Set credentials with {.fn eg_auth} or {.fn eg_oauth_authorize}.",
      "i" = "Or use environment variables: {.envvar EGNYTE_DOMAIN}, {.envvar EGNYTE_API_KEY}"
    ))
  }

  list(domain = domain, api_key = api_key)
}

#' Get Egnyte Domain
#'
#' @return The configured Egnyte domain.
#' @noRd
eg_get_domain <- function() {
  eg_get_auth()$domain
}
