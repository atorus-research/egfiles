#' Set Up OAuth Application Credentials
#'
#' Configures the OAuth 2.0 application credentials for Egnyte authentication.
#' These credentials are obtained by registering your application at
#' \url{https://developers.egnyte.com}.
#'
#' @param domain Your Egnyte domain (the subdomain of yourcompany.egnyte.com).
#' @param client_id The API key (client ID) from your registered application.
#' @param client_secret The client secret from your registered application.
#' @param redirect_uri The redirect URI configured for your app in the Egnyte
#'   developer portal. Must be HTTPS. Defaults to `https://localhost/callback`.
#'
#' @return Invisibly returns a list with the OAuth app configuration.
#'
#' @details
#' After registering at \url{https://developers.egnyte.com}, you will receive
#' a client_id and client_secret. Your application must be approved by Egnyte
#' before it becomes active.
#'
#' **Important:** You must configure the same redirect_uri in your Egnyte app
#' settings. Egnyte requires all redirect URIs to be HTTPS.
#'
#' During development, your API key only works with your registered Egnyte
#' domain. After certification, it works with all Egnyte domains.
#'
#' @examples
#' \dontrun{
#' eg_oauth_app(
#'   domain = "mycompany",
#'   client_id = "your_client_id",
#'   client_secret = "your_client_secret",
#'   redirect_uri = "https://your-registered-redirect.com/callback"
#' )
#' }
#'
#' @seealso [eg_oauth_authorize()] to complete the OAuth flow.
#' @export
eg_oauth_app <- function(domain,
                         client_id,
                         client_secret,
                         redirect_uri = "https://localhost/callback") {
  if (missing(domain) || missing(client_id) || missing(client_secret)) {
    cli::cli_abort(
      "{.arg domain}, {.arg client_id}, and {.arg client_secret} are all required."
    )
  }

  app <- list(
    domain = domain,
    client_id = client_id,
    client_secret = client_secret,
    redirect_uri = redirect_uri
  )

  options(egnyte.oauth_app = app)

  cli::cli_alert_success(
    "OAuth app configured for domain: {.val {domain}}"
  )

  invisible(app)
}

#' Authorize with Egnyte via OAuth 2.0
#'
#' Initiates the OAuth 2.0 Authorization Code flow. This opens a browser
#' window for the user to log in and authorize the application, then
#' prompts for the authorization code to exchange for access tokens.
#'
#' @param scope Character vector of OAuth scopes to request. Defaults to
#'   `"Egnyte.filesystem"` for file operations. Other scopes include
#'   `"Egnyte.link"`, `"Egnyte.user"`, and `"Egnyte.projectfolders"`.
#'
#' @return Invisibly returns a list containing `access_token`, `refresh_token`,
#'   `token_type`, and `expires_in`.
#'
#' @details
#' The OAuth flow:
#' 1. Opens a browser to Egnyte's authorization page
#' 2. User logs in (via SSO if configured) and approves access
#' 3. Egnyte redirects to your configured redirect_uri with `?code=...`
#' 4. Copy the code from the URL and paste it when prompted
#' 5. The code is exchanged for access and refresh tokens
#'
#' **Note:** Egnyte requires HTTPS redirect URIs. After authorization, you'll
#' be redirected to your configured URI. Copy the `code` parameter from the
#' URL (everything after `code=` and before any `&`).
#'
#' Access tokens expire after 30 days. Use [eg_oauth_refresh()] to obtain
#' a new token using the refresh token.
#'
#' @examples
#' \dontrun{
#' # First set up your OAuth app
#' eg_oauth_app("mycompany", "client_id", "client_secret",
#'              redirect_uri = "https://your-app.com/callback")
#'
#' # Then authorize (opens browser, prompts for code)
#' eg_oauth_authorize()
#'
#' # Now you can use eg_read() and eg_write()
#' eg_read("/Shared/Documents/file.txt", "local.txt")
#' }
#'
#' @seealso [eg_oauth_app()] to configure the OAuth application first.
#' @export
eg_oauth_authorize <- function(scope = "Egnyte.filesystem") {
  app <- getOption("egnyte.oauth_app")
  if (is.null(app)) {
    cli::cli_abort(c(
      "OAuth app not configured.",
      "i" = "Run {.fn eg_oauth_app} first to set up your OAuth credentials."
    ))
  }

  state <- paste0(sample(c(letters, 0:9), 20, replace = TRUE), collapse = "")
  scope_str <- paste(scope, collapse = " ")

  auth_url <- paste0(
    "https://", app$domain, ".egnyte.com/puboauth/token",
    "?client_id=", utils::URLencode(app$client_id, reserved = TRUE),
    "&redirect_uri=", utils::URLencode(app$redirect_uri, reserved = TRUE),
    "&scope=", utils::URLencode(scope_str, reserved = TRUE),
    "&state=", utils::URLencode(state, reserved = TRUE),
    "&response_type=code"
  )

  cli::cli_h2("Egnyte OAuth Authorization")
  cli::cli_alert_info("Opening browser for authorization...")
  cli::cli_text("")
  cli::cli_alert("If the browser doesn't open, visit this URL:")
  cli::cli_text("{.url {auth_url}}")
  cli::cli_text("")
  cli::cli_alert_info("After authorizing, you'll be redirected to: {.url {app$redirect_uri}}")
  cli::cli_alert_info("The URL will contain {.code ?code=XXXXX} - copy that code.")
  cli::cli_text("")

  utils::browseURL(auth_url)

  code <- readline("Paste the authorization code here: ")
  code <- trimws(code)

  # Handle if user pasted the full URL instead of just the code
  if (grepl("code=", code)) {
    code <- sub(".*code=([^&]+).*", "\\1", code)
  }

  if (code == "" || is.na(code)) {
    cli::cli_abort("No authorization code provided.")
  }

  cli::cli_alert_info("Exchanging authorization code for tokens...")

  tokens <- oauth_exchange_code(app, code)

  options(
    egnyte.domain = app$domain,
    egnyte.api_key = tokens$access_token,
    egnyte.refresh_token = tokens$refresh_token,
    egnyte.token_expires = Sys.time() + tokens$expires_in
  )

  cli::cli_alert_success("OAuth authorization complete!")
  cli::cli_alert_info(
    "Access token expires: {.val {format(getOption('egnyte.token_expires'))}}"
  )

  invisible(tokens)
}

#' Authenticate with Egnyte Using Username and Password
#'
#' Uses the OAuth 2.0 Resource Owner Password flow to obtain an access token
#' directly using Egnyte credentials. This is simpler than the Authorization
#' Code flow and doesn't require browser interaction.
#'
#' @param username Egnyte username. If NULL, checks the `EGNYTE_USERNAME`
#'   environment variable.
#' @param password Egnyte password. If NULL, checks the `EGNYTE_PASSWORD`
#'   environment variable.
#'
#' @return Invisibly returns a list containing `access_token` and `expires_in`.
#'
#' @details
#' This flow is intended for internal applications where the user trusts the
#' application with their credentials. The username and password are sent
#' directly to Egnyte's token endpoint.
#'
#' You must first configure the OAuth app with [eg_oauth_app()].
#'
#' Credentials can be provided via:
#' - Function arguments
#' - Environment variables: `EGNYTE_USERNAME`, `EGNYTE_PASSWORD`
#' - Interactive prompt (if running interactively and not provided)
#'
#' **Note:** This flow does not return a refresh token. When the access token
#' expires (after 30 days), you'll need to authenticate again.
#'
#' @examples
#' \dontrun{
#' # Set up your OAuth app first
#' eg_oauth_app("mycompany", "client_id", "client_secret")
#'
#' # Authenticate with username/password
#' eg_oauth_password("myuser", "mypassword")
#'
#' # Or use environment variables
#' Sys.setenv(EGNYTE_USERNAME = "myuser", EGNYTE_PASSWORD = "mypassword")
#' eg_oauth_password()
#'
#' # Now you can use eg_read() and eg_write()
#' eg_read("/Shared/Documents/file.txt", "local.txt")
#' }
#'
#' @seealso [eg_oauth_app()] to configure the OAuth application first.
#' @export
eg_oauth_password <- function(username = NULL, password = NULL) {
  app <- getOption("egnyte.oauth_app")
  if (is.null(app)) {
    cli::cli_abort(c(
      "OAuth app not configured.",
      "i" = "Run {.fn eg_oauth_app} first to set up your OAuth credentials."
    ))
  }

  # Get username from args, env var, or prompt

if (is.null(username)) {
    username <- Sys.getenv("EGNYTE_USERNAME", "")
    if (username == "" && interactive()) {
      username <- readline("Egnyte username: ")
    }
  }

  # Get password from args, env var, or prompt
  if (is.null(password)) {
    password <- Sys.getenv("EGNYTE_PASSWORD", "")
    if (password == "" && interactive()) {
      password <- readline("Egnyte password: ")
    }
  }

  if (username == "" || password == "") {
    cli::cli_abort(c(
      "Username and password are required.",
      "i" = "Provide via arguments or environment variables:",
      "i" = "{.envvar EGNYTE_USERNAME}, {.envvar EGNYTE_PASSWORD}"
    ))
  }

  cli::cli_alert_info("Authenticating with Egnyte...")

  token_url <- paste0("https://", app$domain, ".egnyte.com/puboauth/token")

  # Build request body - include client_secret only if provided
  body_params <- list(
    client_id = app$client_id,
    username = username,
    password = password,
    grant_type = "password"
  )

  if (!is.null(app$client_secret) && app$client_secret != "") {
    body_params$client_secret <- app$client_secret
  }

  resp <- httr2::request(token_url) |>
    httr2::req_headers(`Content-Type` = "application/x-www-form-urlencoded") |>
    httr2::req_body_form(!!!body_params) |>
    httr2::req_error(is_error = function(resp) FALSE) |>
    httr2::req_perform()

  if (httr2::resp_status(resp) >= 400) {
    body <- tryCatch(
      httr2::resp_body_json(resp),
      error = function(e) list(error_description = "Unknown error")
    )
    cli::cli_abort(c(
      "Authentication failed.",
      "i" = "Error: {.val {body$error_description %||% body$error %||% 'Unknown error'}}"
    ))
  }

  tokens <- httr2::resp_body_json(resp)

  options(
    egnyte.domain = app$domain,
    egnyte.api_key = tokens$access_token,
    egnyte.token_expires = Sys.time() + tokens$expires_in
  )

  cli::cli_alert_success("Authentication successful!")
  cli::cli_alert_info(
    "Access token expires: {.val {format(getOption('egnyte.token_expires'))}}"
  )

  invisible(tokens)
}

#' Refresh OAuth Access Token
#'
#' Uses the stored refresh token to obtain a new access token without
#' requiring user interaction.
#'
#' @return Invisibly returns a list containing the new `access_token`,
#'   `refresh_token`, `token_type`, and `expires_in`.
#'
#' @details
#' Access tokens expire after 30 days. Call this function to obtain a new
#' access token using the refresh token that was stored during the initial
#' authorization.
#'
#' If the refresh token is also expired or revoked (e.g., user changed
#' password), you will need to run [eg_oauth_authorize()] again.
#'
#' @examples
#' \dontrun{
#' # Refresh the access token
#' eg_oauth_refresh()
#' }
#'
#' @seealso [eg_oauth_authorize()] for the initial authorization.
#' @export
eg_oauth_refresh <- function() {
  app <- getOption("egnyte.oauth_app")
  refresh_token <- getOption("egnyte.refresh_token")

  if (is.null(app)) {
    cli::cli_abort(c(
      "OAuth app not configured.",
      "i" = "Run {.fn eg_oauth_app} and {.fn eg_oauth_authorize} first."
    ))
  }

  if (is.null(refresh_token)) {
    cli::cli_abort(c(
      "No refresh token available.",
      "i" = "Run {.fn eg_oauth_authorize} to obtain tokens first."
    ))
  }

  token_url <- paste0("https://", app$domain, ".egnyte.com/puboauth/token")

  resp <- httr2::request(token_url) |>
    httr2::req_headers(`Content-Type` = "application/x-www-form-urlencoded") |>
    httr2::req_body_form(
      client_id = app$client_id,
      client_secret = app$client_secret,
      refresh_token = refresh_token,
      grant_type = "refresh_token"
    ) |>
    httr2::req_error(is_error = function(resp) FALSE) |>
    httr2::req_perform()

  if (httr2::resp_status(resp) >= 400) {
    cli::cli_abort(c(
      "Failed to refresh OAuth token.",
      "i" = "The refresh token may have expired. Run {.fn eg_oauth_authorize} again."
    ))
  }

  tokens <- httr2::resp_body_json(resp)

  options(
    egnyte.api_key = tokens$access_token,
    egnyte.refresh_token = tokens$refresh_token %||% refresh_token,
    egnyte.token_expires = Sys.time() + tokens$expires_in
  )

  cli::cli_alert_success("Access token refreshed!")
  cli::cli_alert_info(
    "New token expires: {.val {format(getOption('egnyte.token_expires'))}}"
  )

  invisible(tokens)
}

#' Exchange Authorization Code for Tokens
#'
#' @param app OAuth app configuration list.
#' @param code The authorization code.
#'
#' @return List with access_token, refresh_token, etc.
#' @noRd
oauth_exchange_code <- function(app, code) {
  token_url <- paste0("https://", app$domain, ".egnyte.com/puboauth/token")

  resp <- httr2::request(token_url) |>
    httr2::req_headers(`Content-Type` = "application/x-www-form-urlencoded") |>
    httr2::req_body_form(
      client_id = app$client_id,
      client_secret = app$client_secret,
      redirect_uri = app$redirect_uri,
      code = code,
      grant_type = "authorization_code"
    ) |>
    httr2::req_error(is_error = function(resp) FALSE) |>
    httr2::req_perform()

  if (httr2::resp_status(resp) >= 400) {
    body <- tryCatch(
      httr2::resp_body_json(resp),
      error = function(e) list(error = "unknown")
    )
    cli::cli_abort(c(
      "Failed to exchange authorization code for tokens.",
      "i" = "Error: {.val {body$error %||% 'Unknown error'}}"
    ))
  }

  httr2::resp_body_json(resp)
}

#' Null coalescing operator
#' @noRd
`%||%` <- function(x, y) if (is.null(x)) y else x
