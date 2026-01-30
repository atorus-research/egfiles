test_that("eg_write uploads file successfully", {
  setup_mock_auth()

  # Create a temporary file to upload
  test_file <- tempfile(fileext = ".txt")
  writeLines("test content", test_file)
  on.exit(unlink(test_file), add = TRUE)

  mock_performer <- mock_request_performer(mock_response(status = 200))

  local_mocked_bindings(
    req_perform = mock_performer$fn,
    .package = "httr2"
  )

  result <- eg_write(test_file, "/Shared/uploaded.txt")

  expect_equal(result, "/Shared/uploaded.txt")
  expect_length(mock_performer$env$calls, 1)
  expect_true(grepl("fs-content/Shared/uploaded.txt", mock_performer$env$calls[[1]]$req$url))
})

test_that("eg_write errors when local file doesn't exist", {
  setup_mock_auth()

  expect_error(
    eg_write("/nonexistent/path/file.txt", "/Shared/dest.txt"),
    "File not found"
  )
})

test_that("eg_write cleans destination path", {
  setup_mock_auth()

  test_file <- tempfile(fileext = ".txt")
  writeLines("content", test_file)
  on.exit(unlink(test_file), add = TRUE)

  mock_performer <- mock_request_performer(mock_response(status = 200))

  local_mocked_bindings(
    req_perform = mock_performer$fn,
    .package = "httr2"
  )

  # Path without leading slash
  result <- eg_write(test_file, "Shared/file.txt")

  expect_equal(result, "/Shared/file.txt")
  expect_true(grepl("fs-content/Shared/file.txt", mock_performer$env$calls[[1]]$req$url))
})

test_that("eg_write handles 409 conflict without overwrite", {
  setup_mock_auth()

  test_file <- tempfile(fileext = ".txt")
  writeLines("content", test_file)
  on.exit(unlink(test_file), add = TRUE)

  mock_performer <- mock_request_performer(mock_response(status = 409))

  local_mocked_bindings(
    req_perform = mock_performer$fn,
    .package = "httr2"
  )

  expect_error(
    eg_write(test_file, "/Shared/existing.txt"),
    "File already exists.*overwrite = TRUE"
  )
})

test_that("eg_write succeeds with 409 when overwrite = TRUE", {
  setup_mock_auth()

  test_file <- tempfile(fileext = ".txt")
  writeLines("content", test_file)
  on.exit(unlink(test_file), add = TRUE)

  # 409 with overwrite should still proceed through eg_check_response
  # which would error, but since we're allowing overwrite, we expect
  # it to succeed if the server accepts it (200 response)
  mock_performer <- mock_request_performer(mock_response(status = 200))

  local_mocked_bindings(
    req_perform = mock_performer$fn,
    .package = "httr2"
  )

  result <- eg_write(test_file, "/Shared/existing.txt", overwrite = TRUE)

  expect_equal(result, "/Shared/existing.txt")
})

test_that("eg_write passes through 409 to check_response when overwrite = TRUE", {
  setup_mock_auth()

  test_file <- tempfile(fileext = ".txt")
  writeLines("content", test_file)
  on.exit(unlink(test_file), add = TRUE)

  # When overwrite = TRUE, a 409 should pass through to eg_check_response
  mock_performer <- mock_request_performer(mock_response(status = 409))

  local_mocked_bindings(
    req_perform = mock_performer$fn,
    .package = "httr2"
  )

  # With overwrite = TRUE, the function doesn't handle 409 specially,
  # so eg_check_response will throw an error
  expect_error(
    eg_write(test_file, "/Shared/existing.txt", overwrite = TRUE),
    "already exists"
  )
})

test_that("eg_write handles 401 authentication error", {
  setup_mock_auth()

  test_file <- tempfile(fileext = ".txt")
  writeLines("content", test_file)
  on.exit(unlink(test_file), add = TRUE)

  mock_performer <- mock_request_performer(mock_response(status = 401))

  local_mocked_bindings(
    req_perform = mock_performer$fn,
    .package = "httr2"
  )

  expect_error(
    eg_write(test_file, "/Shared/file.txt"),
    "Invalid API key"
  )
})

test_that("eg_write handles 403 permission error", {
  setup_mock_auth()

  test_file <- tempfile(fileext = ".txt")
  writeLines("content", test_file)
  on.exit(unlink(test_file), add = TRUE)

  mock_performer <- mock_request_performer(mock_response(status = 403))

  local_mocked_bindings(
    req_perform = mock_performer$fn,
    .package = "httr2"
  )

  expect_error(
    eg_write(test_file, "/Shared/restricted.txt"),
    "Access denied"
  )
})

test_that("eg_write handles 404 destination not found", {
  setup_mock_auth()

  test_file <- tempfile(fileext = ".txt")
  writeLines("content", test_file)
  on.exit(unlink(test_file), add = TRUE)

  mock_performer <- mock_request_performer(mock_response(status = 404))

  local_mocked_bindings(
    req_perform = mock_performer$fn,
    .package = "httr2"
  )

  expect_error(
    eg_write(test_file, "/Shared/missing_folder/file.txt"),
    "not found"
  )
})

test_that("eg_write returns path invisibly", {
  setup_mock_auth()

  test_file <- tempfile(fileext = ".txt")
  writeLines("content", test_file)
  on.exit(unlink(test_file), add = TRUE)

  mock_performer <- mock_request_performer(mock_response(status = 200))

  local_mocked_bindings(
    req_perform = mock_performer$fn,
    .package = "httr2"
  )

  expect_invisible(result <- eg_write(test_file, "/Shared/file.txt"))
  expect_equal(result, "/Shared/file.txt")
})

test_that("eg_write sets correct Content-Type header", {
  setup_mock_auth()

  test_file <- tempfile(fileext = ".txt")
  writeLines("content", test_file)
  on.exit(unlink(test_file), add = TRUE)

  mock_performer <- mock_request_performer(mock_response(status = 200))

  local_mocked_bindings(
    req_perform = mock_performer$fn,
    .package = "httr2"
  )

  eg_write(test_file, "/Shared/file.txt")

  req <- mock_performer$env$calls[[1]]$req
  expect_equal(req$headers$`Content-Type`, "application/octet-stream")
})
