test_that("eg_auth stores credentials", {
  withr::local_options(list(
    egfiles.domain = NULL,
    egfiles.api_key = NULL
  ))

  eg_auth("testdomain", "testapikey")

  expect_equal(getOption("egfiles.domain"), "testdomain")
  expect_equal(getOption("egfiles.api_key"), "testapikey")
})

test_that("eg_auth requires both arguments", {
  expect_error(eg_auth("domain"), "api_key")
  expect_error(eg_auth(api_key = "key"), "domain")
})

test_that("eg_get_auth returns stored credentials", {
  withr::local_options(list(
    egfiles.domain = "mydomain",
    egfiles.api_key = "mykey"
  ))

  auth <- eg_get_auth()

  expect_equal(auth$domain, "mydomain")
  expect_equal(auth$api_key, "mykey")
})

test_that("eg_get_auth errors when credentials not set", {
  withr::local_options(list(
    egfiles.domain = NULL,
    egfiles.api_key = NULL
  ))
  withr::local_envvar(list(
    EGNYTE_DOMAIN = "",
    EGNYTE_API_KEY = ""
  ))

  expect_error(eg_get_auth(), "credentials not found")
})

test_that("eg_get_auth reads from environment variables", {
  withr::local_options(list(
    egfiles.domain = NULL,
    egfiles.api_key = NULL
  ))
  withr::local_envvar(list(
    EGNYTE_DOMAIN = "envdomain",
    EGNYTE_API_KEY = "envkey"
  ))

  auth <- eg_get_auth()

  expect_equal(auth$domain, "envdomain")
  expect_equal(auth$api_key, "envkey")
})

test_that("options take priority over environment variables", {
  withr::local_options(list(
    egfiles.domain = "optdomain",
    egfiles.api_key = "optkey"
  ))
  withr::local_envvar(list(
    EGNYTE_DOMAIN = "envdomain",
    EGNYTE_API_KEY = "envkey"
  ))

  auth <- eg_get_auth()

  expect_equal(auth$domain, "optdomain")
  expect_equal(auth$api_key, "optkey")
})
