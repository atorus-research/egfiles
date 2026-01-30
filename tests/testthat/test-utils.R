test_that("eg_clean_path adds leading slash", {
  expect_equal(eg_clean_path("Shared/file.txt"), "/Shared/file.txt")
  expect_equal(eg_clean_path("/Shared/file.txt"), "/Shared/file.txt")
})

test_that("eg_clean_path removes trailing slash", {
  expect_equal(eg_clean_path("/Shared/folder/"), "/Shared/folder")
  expect_equal(eg_clean_path("/Shared/folder"), "/Shared/folder")
})

test_that("eg_clean_path handles multiple leading slashes", {
  expect_equal(eg_clean_path("///Shared/file.txt"), "/Shared/file.txt")
  expect_equal(eg_clean_path("//Shared/folder/"), "/Shared/folder")
})

test_that("eg_url builds correct URL", {
  setup_mock_auth()

  expect_equal(
    eg_url("fs-content/Shared/file.txt"),
    "https://testcompany.egnyte.com/pubapi/v1/fs-content/Shared/file.txt"
  )
})

test_that("eg_url accepts explicit domain parameter", {
  expect_equal(
    eg_url("fs-content/test.txt", domain = "customdomain"),
    "https://customdomain.egnyte.com/pubapi/v1/fs-content/test.txt"
  )
})

test_that("eg_request creates authenticated request", {
  setup_mock_auth(domain = "mydomain", api_key = "my_secret_key")

  req <- eg_request("fs-content/test.txt")

  expect_s3_class(req, "httr2_request")
  expect_true(grepl("mydomain.egnyte.com", req$url))
  expect_true(grepl("fs-content/test.txt", req$url))
  # httr2 stores headers internally - verify Authorization header exists
  # The header is stored with the key in the headers list
  expect_true("Authorization" %in% names(req$headers))
})

test_that("eg_check_response returns invisibly on success", {
  resp <- mock_response(status = 200)

  result <- eg_check_response(resp)

  expect_invisible(eg_check_response(resp))
  expect_identical(result, resp)
})

test_that("eg_check_response handles 401 unauthorized", {
  resp <- mock_response(status = 401)

  expect_error(
    eg_check_response(resp),
    "Invalid API key or expired token"
  )
})

test_that("eg_check_response handles 403 forbidden", {
  resp <- mock_response(status = 403)

  expect_error(
    eg_check_response(resp),
    "Access denied"
  )
})

test_that("eg_check_response handles 404 not found", {
  resp <- mock_response(status = 404)

  expect_error(
    eg_check_response(resp),
    "not found"
  )
})

test_that("eg_check_response handles 409 conflict", {
  resp <- mock_response(status = 409)

  expect_error(
    eg_check_response(resp),
    "already exists"
  )
})

test_that("eg_check_response handles unknown error codes", {
  resp <- mock_response(status = 500)

  expect_error(
    eg_check_response(resp),
    "Egnyte API error.*500"
  )
})

test_that("eg_check_response handles 4xx errors generically", {
  resp <- mock_response(status = 422)

  expect_error(
    eg_check_response(resp),
    "Egnyte API error.*422"
  )
})
