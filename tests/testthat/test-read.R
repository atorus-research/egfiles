test_that("eg_read downloads file to temporary location", {
  setup_mock_auth()

  # Create a mock performer that writes content to the destination file
  mock_performer <- mock_request_performer(mock_file_response("test,data\n1,2"))

  local_mocked_bindings(
    req_perform = mock_performer$fn,
    .package = "httr2"
  )

  result <- eg_read("/Shared/test.csv")

  # Check that file was created and contains expected content

  expect_true(file.exists(result))
  expect_equal(readLines(result, warn = FALSE), c("test,data", "1,2"))

  # Check that correct endpoint was called
  expect_length(mock_performer$env$calls, 1)
  expect_true(grepl("fs-content/Shared/test.csv", mock_performer$env$calls[[1]]$req$url))

  # Clean up
  unlink(result)
})

test_that("eg_read downloads to specified destfile", {
  setup_mock_auth()

  mock_performer <- mock_request_performer(mock_file_response("file content"))

  local_mocked_bindings(
    req_perform = mock_performer$fn,
    .package = "httr2"
  )

  destfile <- tempfile(fileext = ".txt")
  on.exit(unlink(destfile), add = TRUE)

  result <- eg_read("/Shared/myfile.txt", destfile = destfile)

  expect_equal(result, destfile)
  expect_true(file.exists(destfile))
  expect_equal(readLines(destfile, warn = FALSE), "file content")
})

test_that("eg_read preserves file extension in temp file", {
  setup_mock_auth()

  mock_performer <- mock_request_performer(mock_file_response("data"))

  local_mocked_bindings(
    req_perform = mock_performer$fn,
    .package = "httr2"
  )

  result <- eg_read("/Shared/data.xlsx")

  expect_true(grepl("\\.xlsx$", result))
  unlink(result)
})

test_that("eg_read handles paths without extension", {
  setup_mock_auth()

  mock_performer <- mock_request_performer(mock_file_response("data"))

  local_mocked_bindings(
    req_perform = mock_performer$fn,
    .package = "httr2"
  )

  result <- eg_read("/Shared/noextension")

  expect_true(file.exists(result))
  unlink(result)
})

test_that("eg_read cleans path before request", {
  setup_mock_auth()

  mock_performer <- mock_request_performer(mock_file_response("data"))

  local_mocked_bindings(
    req_perform = mock_performer$fn,
    .package = "httr2"
  )

  # Path without leading slash should still work
  result <- eg_read("Shared/file.txt")

  expect_true(grepl("fs-content/Shared/file.txt", mock_performer$env$calls[[1]]$req$url))
  unlink(result)
})

test_that("eg_read handles API errors", {
  setup_mock_auth()

  mock_performer <- mock_request_performer(mock_response(status = 404))

  local_mocked_bindings(
    req_perform = mock_performer$fn,
    .package = "httr2"
  )

  expect_error(
    eg_read("/Shared/nonexistent.txt"),
    "not found"
  )
})

test_that("eg_read handles 401 authentication error", {
  setup_mock_auth()

  mock_performer <- mock_request_performer(mock_response(status = 401))

  local_mocked_bindings(
    req_perform = mock_performer$fn,
    .package = "httr2"
  )

  expect_error(
    eg_read("/Shared/test.txt"),
    "Invalid API key"
  )
})

test_that("eg_read handles 403 permission error", {
  setup_mock_auth()

  mock_performer <- mock_request_performer(mock_response(status = 403))

  local_mocked_bindings(
    req_perform = mock_performer$fn,
    .package = "httr2"
  )

  expect_error(
    eg_read("/Shared/restricted.txt"),
    "Access denied"
  )
})

test_that("eg_read returns path invisibly", {
  setup_mock_auth()

  mock_performer <- mock_request_performer(mock_file_response("data"))

  local_mocked_bindings(
    req_perform = mock_performer$fn,
    .package = "httr2"
  )

  expect_invisible(result <- eg_read("/Shared/file.txt"))
  expect_true(is.character(result))
  unlink(result)
})
