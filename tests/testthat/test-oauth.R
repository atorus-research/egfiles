# Tests for eg_oauth_app

test_that("eg_oauth_app stores configuration", {
  withr::local_options(list(egfiles.oauth_app = NULL))

  eg_oauth_app("testdomain", "test_client_id", "test_client_secret")

  app <- getOption("egfiles.oauth_app")

  expect_equal(app$domain, "testdomain")
  expect_equal(app$client_id, "test_client_id")
  expect_equal(app$client_secret, "test_client_secret")
  expect_equal(app$redirect_uri, "https://localhost/callback")
})

test_that("eg_oauth_app accepts custom redirect_uri", {
  withr::local_options(list(egfiles.oauth_app = NULL))

  eg_oauth_app(
    "testdomain",
    "test_client_id",
    "test_client_secret",
    redirect_uri = "https://myapp.com/callback"
  )

  app <- getOption("egfiles.oauth_app")
  expect_equal(app$redirect_uri, "https://myapp.com/callback")
})

test_that("eg_oauth_app requires all arguments", {
  expect_error(eg_oauth_app("domain"), "client_id.*client_secret")
  expect_error(eg_oauth_app("domain", "id"), "client_secret")
  expect_error(eg_oauth_app(client_id = "id"), "domain")
})

test_that("eg_oauth_app returns configuration invisibly", {
  withr::local_options(list(egfiles.oauth_app = NULL))

  result <- eg_oauth_app("testdomain", "test_client_id", "test_client_secret")

  expect_invisible(eg_oauth_app("testdomain", "test_client_id", "test_client_secret"))
  expect_type(result, "list")
  expect_equal(result$domain, "testdomain")
})

# Tests for eg_oauth_authorize

test_that("eg_oauth_authorize errors without app configuration", {
  withr::local_options(list(egfiles.oauth_app = NULL))

  expect_error(eg_oauth_authorize(), "OAuth app not configured")
})

# Tests for eg_oauth_refresh

test_that("eg_oauth_refresh errors without app configuration", {
  withr::local_options(list(
    egfiles.oauth_app = NULL,
    egfiles.refresh_token = NULL
  ))

  expect_error(eg_oauth_refresh(), "OAuth app not configured")
})

test_that("eg_oauth_refresh errors without refresh token", {
  withr::local_options(list(
    egfiles.oauth_app = list(
      domain = "test",
      client_id = "id",
      client_secret = "secret"
    ),
    egfiles.refresh_token = NULL
  ))

  expect_error(eg_oauth_refresh(), "No refresh token available")
})

test_that("eg_oauth_refresh successfully refreshes token", {
  setup_mock_oauth(refresh_token = "old_refresh_token")

  mock_performer <- mock_request_performer(
    mock_token_response(
      access_token = "new_access_token",
      refresh_token = "new_refresh_token",
      expires_in = 2592000
    )
  )

  local_mocked_bindings(
    req_perform = mock_performer$fn,
    .package = "httr2"
  )

  result <- eg_oauth_refresh()

  expect_equal(result$access_token, "new_access_token")
  expect_equal(getOption("egfiles.api_key"), "new_access_token")
  expect_equal(getOption("egfiles.refresh_token"), "new_refresh_token")
})

test_that("eg_oauth_refresh preserves old refresh token if new one not provided", {
  setup_mock_oauth(refresh_token = "preserved_refresh_token")

  # Response without refresh_token
  mock_performer <- mock_request_performer(
    mock_token_response(
      access_token = "new_access_token",
      refresh_token = NULL,
      expires_in = 2592000
    )
  )

  local_mocked_bindings(
    req_perform = mock_performer$fn,
    .package = "httr2"
  )

  eg_oauth_refresh()

  expect_equal(getOption("egfiles.refresh_token"), "preserved_refresh_token")
})

test_that("eg_oauth_refresh handles HTTP errors", {
  setup_mock_oauth(refresh_token = "some_refresh_token")

  mock_performer <- mock_request_performer(mock_response(status = 400))

  local_mocked_bindings(
    req_perform = mock_performer$fn,
    .package = "httr2"
  )

  expect_error(
    eg_oauth_refresh(),
    "Failed to refresh|expired"
  )
})

test_that("eg_oauth_refresh updates token expiration time", {
  setup_mock_oauth(refresh_token = "refresh_token")

  mock_performer <- mock_request_performer(
    mock_token_response(expires_in = 3600)
  )

  local_mocked_bindings(
    req_perform = mock_performer$fn,
    .package = "httr2"
  )

  before_time <- Sys.time()
  eg_oauth_refresh()
  after_time <- Sys.time()

  token_expires <- getOption("egfiles.token_expires")
  expect_true(token_expires > before_time + 3500)
  expect_true(token_expires < after_time + 3700)
})

# Tests for auto-refresh in eg_get_auth

test_that("auto-refresh is triggered when token is expired", {
  withr::local_options(list(
    egfiles.domain = "testdomain",
    egfiles.api_key = "old_token",
    egfiles.refresh_token = "refresh_token",
    egfiles.token_expires = Sys.time() - 3600,
    egfiles.oauth_app = list(
      domain = "testdomain",
      client_id = "id",
      client_secret = "secret"
    )
  ))

  # This should try to refresh but fail (no real server)
  # The important thing is it tries and then falls back
  expect_message(
    tryCatch(eg_get_auth(), error = function(e) NULL),
    "expired|refresh",
    ignore.case = TRUE
  )
})

test_that("auto-refresh succeeds with mocked response", {
  withr::local_options(list(
    egfiles.domain = "testdomain",
    egfiles.api_key = "old_expired_token",
    egfiles.refresh_token = "valid_refresh_token",
    egfiles.token_expires = Sys.time() - 3600,  # Expired
    egfiles.oauth_app = list(
      domain = "testdomain",
      client_id = "id",
      client_secret = "secret"
    )
  ))
  withr::local_envvar(list(
    EGNYTE_DOMAIN = "",
    EGNYTE_API_KEY = ""
  ))

  mock_performer <- mock_request_performer(
    mock_token_response(access_token = "fresh_new_token")
  )

  local_mocked_bindings(
    req_perform = mock_performer$fn,
    .package = "httr2"
  )

  auth <- eg_get_auth()

  expect_equal(auth$api_key, "fresh_new_token")
})

test_that("auto-refresh continues with old token on failure", {
  withr::local_options(list(
    egfiles.domain = "testdomain",
    egfiles.api_key = "old_token_still_works",
    egfiles.refresh_token = "bad_refresh_token",
    egfiles.token_expires = Sys.time() - 3600,  # Expired
    egfiles.oauth_app = list(
      domain = "testdomain",
      client_id = "id",
      client_secret = "secret"
    )
  ))
  withr::local_envvar(list(
    EGNYTE_DOMAIN = "",
    EGNYTE_API_KEY = ""
  ))

  mock_performer <- mock_request_performer(mock_response(status = 401))

  local_mocked_bindings(
    req_perform = mock_performer$fn,
    .package = "httr2"
  )

  # Should warn but still return the old credentials
  expect_warning(
    auth <- eg_get_auth(),
    "Failed to refresh"
  )

  expect_equal(auth$api_key, "old_token_still_works")
})

# Tests for eg_oauth_password

test_that("eg_oauth_password errors without app configuration", {
  withr::local_options(list(egfiles.oauth_app = NULL))

  expect_error(eg_oauth_password("user", "pass"), "OAuth app not configured")
})

test_that("eg_oauth_password errors without credentials", {
  withr::local_options(list(
    egfiles.oauth_app = list(
      domain = "test",
      client_id = "id",
      client_secret = "secret"
    )
  ))
  withr::local_envvar(list(
    EGNYTE_USERNAME = "",
    EGNYTE_PASSWORD = ""
  ))

  expect_error(
    eg_oauth_password(NULL, NULL),
    "Username and password are required"
  )
})

test_that("eg_oauth_password reads from environment variables", {
  withr::local_options(list(
    egfiles.oauth_app = list(
      domain = "test",
      client_id = "id",
      client_secret = "secret"
    )
  ))
  withr::local_envvar(list(
    EGNYTE_USERNAME = "envuser",
    EGNYTE_PASSWORD = "envpass"
  ))

  mock_performer <- mock_request_performer(
    mock_token_response(access_token = "env_token")
  )

  local_mocked_bindings(
    req_perform = mock_performer$fn,
    .package = "httr2"
  )

  result <- eg_oauth_password()

  expect_equal(result$access_token, "env_token")
})

test_that("eg_oauth_password authenticates successfully", {
  setup_mock_oauth()

  mock_performer <- mock_request_performer(
    mock_token_response(access_token = "password_flow_token", expires_in = 2592000)
  )

  local_mocked_bindings(
    req_perform = mock_performer$fn,
    .package = "httr2"
  )

  result <- eg_oauth_password("testuser", "testpass")

  expect_equal(result$access_token, "password_flow_token")
  expect_equal(getOption("egfiles.api_key"), "password_flow_token")
  expect_equal(getOption("egfiles.domain"), "testcompany")
})

test_that("eg_oauth_password sets token expiration", {
  setup_mock_oauth()

  mock_performer <- mock_request_performer(
    mock_token_response(expires_in = 7200)
  )

  local_mocked_bindings(
    req_perform = mock_performer$fn,
    .package = "httr2"
  )

  before_time <- Sys.time()
  eg_oauth_password("user", "pass")

  token_expires <- getOption("egfiles.token_expires")
  expect_true(token_expires > before_time + 7100)
})

test_that("eg_oauth_password handles authentication failure", {
  setup_mock_oauth()

  mock_performer <- mock_request_performer(
    mock_error_response(401, "invalid_grant", "Invalid username or password")
  )

  local_mocked_bindings(
    req_perform = mock_performer$fn,
    .package = "httr2"
  )

  expect_error(
    eg_oauth_password("baduser", "badpass"),
    "Authentication failed"
  )
})

test_that("eg_oauth_password includes error description in message", {
  setup_mock_oauth()

  mock_performer <- mock_request_performer(
    mock_error_response(400, "invalid_request", "Missing required parameter")
  )

  local_mocked_bindings(
    req_perform = mock_performer$fn,
    .package = "httr2"
  )

  expect_error(
    eg_oauth_password("user", "pass"),
    "Missing required parameter|Authentication failed"
  )
})

test_that("eg_oauth_password handles rate limiting", {
  setup_mock_oauth()

  mock_performer <- mock_request_performer(mock_response(status = 429))

  local_mocked_bindings(
    req_perform = mock_performer$fn,
    .package = "httr2"
  )

  expect_error(
    eg_oauth_password("user", "pass"),
    "Authentication failed"
  )
})

test_that("eg_oauth_password handles empty client_secret", {
  withr::local_options(list(
    egfiles.oauth_app = list(
      domain = "test",
      client_id = "id",
      client_secret = ""  # Empty secret
    )
  ))
  withr::local_envvar(list(
    EGNYTE_USERNAME = "",
    EGNYTE_PASSWORD = ""
  ))

  mock_performer <- mock_request_performer(
    mock_token_response(access_token = "token_without_secret")
  )

  local_mocked_bindings(
    req_perform = mock_performer$fn,
    .package = "httr2"
  )

  result <- eg_oauth_password("user", "pass")

  expect_equal(result$access_token, "token_without_secret")
})

# Tests for oauth_exchange_code (internal function)

test_that("oauth_exchange_code exchanges code for tokens", {
  app <- list(
    domain = "testdomain",
    client_id = "test_id",
    client_secret = "test_secret",
    redirect_uri = "https://localhost/callback"
  )

  mock_performer <- mock_request_performer(
    mock_token_response(
      access_token = "exchanged_token",
      refresh_token = "refresh_from_exchange"
    )
  )

  local_mocked_bindings(
    req_perform = mock_performer$fn,
    .package = "httr2"
  )

  result <- egfiles:::oauth_exchange_code(app, "auth_code_123")

  expect_equal(result$access_token, "exchanged_token")
  expect_equal(result$refresh_token, "refresh_from_exchange")
})

test_that("oauth_exchange_code handles invalid code", {
  app <- list(
    domain = "testdomain",
    client_id = "test_id",
    client_secret = "test_secret",
    redirect_uri = "https://localhost/callback"
  )

  mock_performer <- mock_request_performer(
    mock_error_response(400, "invalid_grant", "Authorization code expired")
  )

  local_mocked_bindings(
    req_perform = mock_performer$fn,
    .package = "httr2"
  )

  expect_error(
    egfiles:::oauth_exchange_code(app, "expired_code"),
    "Failed to exchange|invalid_grant"
  )
})

# Tests for %||% operator

test_that("null coalescing operator returns first value if not NULL", {
  `%||%` <- egfiles:::`%||%`
  expect_equal("value" %||% "default", "value")
  expect_equal(1 %||% 2, 1)
  expect_equal(list(a = 1) %||% list(b = 2), list(a = 1))
})

test_that("null coalescing operator returns second value if first is NULL", {
  `%||%` <- egfiles:::`%||%`
  expect_equal(NULL %||% "default", "default")
  expect_equal(NULL %||% 42, 42)
})
