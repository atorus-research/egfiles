# Tests for eg_write_csv

test_that("eg_write_csv writes and uploads CSV file", {
  skip_if_not_installed("readr")
  setup_mock_auth()

  mock_performer <- mock_request_performer(mock_response(status = 200))

  local_mocked_bindings(
    req_perform = mock_performer$fn,
    .package = "httr2"
  )

  df <- data.frame(x = 1:3, y = c("a", "b", "c"))
  result <- eg_write_csv(df, "/Shared/output.csv")

  expect_equal(result, "/Shared/output.csv")
  expect_length(mock_performer$env$calls, 1)
  expect_true(grepl("fs-content/Shared/output.csv", mock_performer$env$calls[[1]]$req$url))
})

test_that("eg_write_csv passes additional arguments to readr", {
  skip_if_not_installed("readr")
  setup_mock_auth()

  mock_performer <- mock_request_performer(mock_response(status = 200))

  local_mocked_bindings(
    req_perform = mock_performer$fn,
    .package = "httr2"
  )

  df <- data.frame(x = 1:3)
  # na argument is passed to write_csv
  result <- eg_write_csv(df, "/Shared/output.csv", na = "MISSING")

  expect_equal(result, "/Shared/output.csv")
})

test_that("eg_write_csv respects overwrite parameter", {
  skip_if_not_installed("readr")
  setup_mock_auth()

  mock_performer <- mock_request_performer(mock_response(status = 409))

  local_mocked_bindings(
    req_perform = mock_performer$fn,
    .package = "httr2"
  )

  df <- data.frame(x = 1:3)

  expect_error(
    eg_write_csv(df, "/Shared/existing.csv"),
    "already exists"
  )
})

# Tests for eg_write_delim

test_that("eg_write_delim writes and uploads delimited file", {
  skip_if_not_installed("readr")
  setup_mock_auth()

  mock_performer <- mock_request_performer(mock_response(status = 200))

  local_mocked_bindings(
    req_perform = mock_performer$fn,
    .package = "httr2"
  )

  df <- data.frame(x = 1:3, y = c("a", "b", "c"))
  result <- eg_write_delim(df, "/Shared/output.tsv")

  expect_equal(result, "/Shared/output.tsv")
})

test_that("eg_write_delim accepts custom delimiter", {
  skip_if_not_installed("readr")
  setup_mock_auth()

  mock_performer <- mock_request_performer(mock_response(status = 200))

  local_mocked_bindings(
    req_perform = mock_performer$fn,
    .package = "httr2"
  )

  df <- data.frame(x = 1:3)
  result <- eg_write_delim(df, "/Shared/output.txt", delim = "|")

  expect_equal(result, "/Shared/output.txt")
})

# Tests for eg_write_excel

test_that("eg_write_excel writes and uploads Excel file", {
  skip_if_not_installed("writexl")
  setup_mock_auth()

  mock_performer <- mock_request_performer(mock_response(status = 200))

  local_mocked_bindings(
    req_perform = mock_performer$fn,
    .package = "httr2"
  )

  df <- data.frame(x = 1:3, y = c("a", "b", "c"))
  result <- eg_write_excel(df, "/Shared/output.xlsx")

  expect_equal(result, "/Shared/output.xlsx")
  expect_length(mock_performer$env$calls, 1)
})

test_that("eg_write_excel handles multiple sheets", {
  skip_if_not_installed("writexl")
  setup_mock_auth()

  mock_performer <- mock_request_performer(mock_response(status = 200))

  local_mocked_bindings(
    req_perform = mock_performer$fn,
    .package = "httr2"
  )

  sheets <- list(
    Cars = mtcars[1:5, ],
    Iris = iris[1:5, ]
  )
  result <- eg_write_excel(sheets, "/Shared/workbook.xlsx")

  expect_equal(result, "/Shared/workbook.xlsx")
})

# Tests for eg_write_rds

test_that("eg_write_rds writes and uploads RDS file", {
  setup_mock_auth()

  mock_performer <- mock_request_performer(mock_response(status = 200))

  local_mocked_bindings(
    req_perform = mock_performer$fn,
    .package = "httr2"
  )

  obj <- list(a = 1:5, b = "test")
  result <- eg_write_rds(obj, "/Shared/object.rds")

  expect_equal(result, "/Shared/object.rds")
})

test_that("eg_write_rds can save any R object", {
  setup_mock_auth()

  mock_performer <- mock_request_performer(mock_response(status = 200))

  local_mocked_bindings(
    req_perform = mock_performer$fn,
    .package = "httr2"
  )

  model <- lm(mpg ~ cyl, data = mtcars)
  result <- eg_write_rds(model, "/Shared/model.rds")

  expect_equal(result, "/Shared/model.rds")
})

test_that("eg_write_rds respects compress parameter", {
  setup_mock_auth()

  mock_performer <- mock_request_performer(mock_response(status = 200))

  local_mocked_bindings(
    req_perform = mock_performer$fn,
    .package = "httr2"
  )

  obj <- 1:1000
  result <- eg_write_rds(obj, "/Shared/data.rds", compress = "xz")

  expect_equal(result, "/Shared/data.rds")
})

test_that("eg_write_rds can disable compression", {
  setup_mock_auth()

  mock_performer <- mock_request_performer(mock_response(status = 200))

  local_mocked_bindings(
    req_perform = mock_performer$fn,
    .package = "httr2"
  )

  obj <- 1:100
  result <- eg_write_rds(obj, "/Shared/data.rds", compress = FALSE)

  expect_equal(result, "/Shared/data.rds")
})

# Tests for eg_write_xpt

test_that("eg_write_xpt writes and uploads XPT file", {
  skip_if_not_installed("haven")
  setup_mock_auth()

  mock_performer <- mock_request_performer(mock_response(status = 200))

  local_mocked_bindings(
    req_perform = mock_performer$fn,
    .package = "httr2"
  )

  df <- data.frame(x = 1:3, y = c(1.1, 2.2, 3.3))
  result <- eg_write_xpt(df, "/Shared/data.xpt")

  expect_equal(result, "/Shared/data.xpt")
})

# Tests for eg_write_stata

test_that("eg_write_stata writes and uploads DTA file", {
  skip_if_not_installed("haven")
  setup_mock_auth()

  mock_performer <- mock_request_performer(mock_response(status = 200))

  local_mocked_bindings(
    req_perform = mock_performer$fn,
    .package = "httr2"
  )

  df <- data.frame(x = 1:3, y = c("a", "b", "c"))
  result <- eg_write_stata(df, "/Shared/data.dta")

  expect_equal(result, "/Shared/data.dta")
})

# Tests for eg_write_spss

test_that("eg_write_spss writes and uploads SAV file", {
  skip_if_not_installed("haven")
  setup_mock_auth()

  mock_performer <- mock_request_performer(mock_response(status = 200))

  local_mocked_bindings(
    req_perform = mock_performer$fn,
    .package = "httr2"
  )

  df <- data.frame(x = 1:3, y = c(10, 20, 30))
  result <- eg_write_spss(df, "/Shared/data.sav")

  expect_equal(result, "/Shared/data.sav")
})

# Error handling tests

test_that("eg_write_csv handles API errors", {
  skip_if_not_installed("readr")
  setup_mock_auth()

  mock_performer <- mock_request_performer(mock_response(status = 404))

  local_mocked_bindings(
    req_perform = mock_performer$fn,
    .package = "httr2"
  )

  expect_error(
    eg_write_csv(mtcars, "/Shared/missing_folder/data.csv"),
    "not found"
  )
})

test_that("eg_write_excel handles permission errors", {
  skip_if_not_installed("writexl")
  setup_mock_auth()

  mock_performer <- mock_request_performer(mock_response(status = 403))

  local_mocked_bindings(
    req_perform = mock_performer$fn,
    .package = "httr2"
  )

  expect_error(
    eg_write_excel(mtcars, "/Shared/restricted/data.xlsx"),
    "Access denied"
  )
})

test_that("eg_write_rds handles authentication errors", {
  setup_mock_auth()

  mock_performer <- mock_request_performer(mock_response(status = 401))

  local_mocked_bindings(
    req_perform = mock_performer$fn,
    .package = "httr2"
  )

  expect_error(
    eg_write_rds(mtcars, "/Shared/data.rds"),
    "Invalid API key"
  )
})

# Tests for temporary file cleanup

test_that("eg_write_csv cleans up temporary file", {
  skip_if_not_installed("readr")
  setup_mock_auth()

  mock_performer <- mock_request_performer(mock_response(status = 200))

  local_mocked_bindings(
    req_perform = mock_performer$fn,
    .package = "httr2"
  )

  # Get count of temp files before
  temp_files_before <- length(list.files(tempdir(), pattern = "\\.csv$"))

  eg_write_csv(mtcars, "/Shared/data.csv")

  # Temp file should be cleaned up
  temp_files_after <- length(list.files(tempdir(), pattern = "\\.csv$"))
  expect_equal(temp_files_before, temp_files_after)
})

test_that("eg_write_excel cleans up temporary file on success", {
  skip_if_not_installed("writexl")
  setup_mock_auth()

  mock_performer <- mock_request_performer(mock_response(status = 200))

  local_mocked_bindings(
    req_perform = mock_performer$fn,
    .package = "httr2"
  )

  temp_files_before <- length(list.files(tempdir(), pattern = "\\.xlsx$"))

  eg_write_excel(mtcars, "/Shared/data.xlsx")

  temp_files_after <- length(list.files(tempdir(), pattern = "\\.xlsx$"))
  expect_equal(temp_files_before, temp_files_after)
})
