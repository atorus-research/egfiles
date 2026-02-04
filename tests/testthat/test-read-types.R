# Tests for check_installed helper

test_that("check_installed errors when package missing", {
  expect_error(
    egnyte:::check_installed("nonexistent_fake_package_12345"),
    "nonexistent_fake_package_12345.*required"
  )
})

test_that("check_installed succeeds for installed packages", {
  expect_no_error(egnyte:::check_installed("testthat"))
})

test_that("check_installed provides installation hint", {
  expect_error(
    egnyte:::check_installed("fakepkg123"),
    "install.packages"
  )
})

# Tests for eg_read_csv

test_that("eg_read_csv downloads and parses CSV file", {
  skip_if_not_installed("readr")
  setup_mock_auth()

  csv_content <- "name,value\nalice,1\nbob,2"
  mock_performer <- mock_request_performer(mock_file_response(csv_content))

  local_mocked_bindings(
    req_perform = mock_performer$fn,
    .package = "httr2"
  )

  result <- eg_read_csv("/Shared/data.csv")

  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 2)
  expect_equal(result$name, c("alice", "bob"))
  expect_equal(result$value, c(1, 2))
})

test_that("eg_read_csv passes additional arguments to readr", {
  skip_if_not_installed("readr")
  setup_mock_auth()

  csv_content <- "name,value\nalice,1\nbob,2"
  mock_performer <- mock_request_performer(mock_file_response(csv_content))

  local_mocked_bindings(
    req_perform = mock_performer$fn,
    .package = "httr2"
  )

  result <- eg_read_csv("/Shared/data.csv", col_types = "cc")

  expect_type(result$value, "character")
})

# Tests for eg_read_delim

test_that("eg_read_delim downloads and parses delimited file", {
  skip_if_not_installed("readr")
  setup_mock_auth()

  tsv_content <- "name\tvalue\nalice\t1\nbob\t2"
  mock_performer <- mock_request_performer(mock_file_response(tsv_content))

  local_mocked_bindings(
    req_perform = mock_performer$fn,
    .package = "httr2"
  )

  result <- eg_read_delim("/Shared/data.tsv")

  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 2)
  expect_equal(result$name, c("alice", "bob"))
})

test_that("eg_read_delim accepts custom delimiter", {
  skip_if_not_installed("readr")
  setup_mock_auth()

  pipe_content <- "name|value\nalice|1\nbob|2"
  mock_performer <- mock_request_performer(mock_file_response(pipe_content))

  local_mocked_bindings(
    req_perform = mock_performer$fn,
    .package = "httr2"
  )

  result <- eg_read_delim("/Shared/data.txt", delim = "|")

  expect_equal(result$name, c("alice", "bob"))
  expect_equal(result$value, c(1, 2))
})

# Tests for eg_read_excel

test_that("eg_read_excel downloads and parses Excel file", {
  skip_if_not_installed("readxl")
  skip_if_not_installed("writexl")
  setup_mock_auth()

  # Create a real Excel file for testing
  test_xlsx <- tempfile(fileext = ".xlsx")
  writexl::write_xlsx(data.frame(x = 1:3, y = c("a", "b", "c")), test_xlsx)
  xlsx_bytes <- readBin(test_xlsx, "raw", file.info(test_xlsx)$size)
  unlink(test_xlsx)

  mock_performer <- mock_request_performer(mock_response(status = 200, body = xlsx_bytes))

  local_mocked_bindings(
    req_perform = mock_performer$fn,
    .package = "httr2"
  )

  result <- eg_read_excel("/Shared/data.xlsx")

  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 3)
  expect_equal(result$x, 1:3)
})

test_that("eg_read_excel accepts sheet parameter", {
  skip_if_not_installed("readxl")
  skip_if_not_installed("writexl")
  setup_mock_auth()

  # Create Excel file with multiple sheets
  test_xlsx <- tempfile(fileext = ".xlsx")
  writexl::write_xlsx(
    list(
      Sheet1 = data.frame(a = 1:2),
      Sheet2 = data.frame(b = 3:4)
    ),
    test_xlsx
  )
  xlsx_bytes <- readBin(test_xlsx, "raw", file.info(test_xlsx)$size)
  unlink(test_xlsx)

  mock_performer <- mock_request_performer(mock_response(status = 200, body = xlsx_bytes))

  local_mocked_bindings(
    req_perform = mock_performer$fn,
    .package = "httr2"
  )

  result <- eg_read_excel("/Shared/workbook.xlsx", sheet = "Sheet2")

  expect_true("b" %in% names(result))
  expect_equal(result$b, 3:4)
})

# Tests for eg_read_rds

test_that("eg_read_rds downloads and reads RDS file", {
  setup_mock_auth()

  # Create RDS content
  test_obj <- list(a = 1:5, b = "test")
  rds_file <- tempfile(fileext = ".rds")
  saveRDS(test_obj, rds_file)
  rds_bytes <- readBin(rds_file, "raw", file.info(rds_file)$size)
  unlink(rds_file)

  mock_performer <- mock_request_performer(mock_response(status = 200, body = rds_bytes))

  local_mocked_bindings(
    req_perform = mock_performer$fn,
    .package = "httr2"
  )

  result <- eg_read_rds("/Shared/object.rds")

  expect_equal(result$a, 1:5)
  expect_equal(result$b, "test")
})

test_that("eg_read_rds can read any R object", {
  setup_mock_auth()

  # Save a complex object
  test_obj <- lm(mpg ~ cyl, data = mtcars)
  rds_file <- tempfile(fileext = ".rds")
  saveRDS(test_obj, rds_file)
  rds_bytes <- readBin(rds_file, "raw", file.info(rds_file)$size)
  unlink(rds_file)

  mock_performer <- mock_request_performer(mock_response(status = 200, body = rds_bytes))

  local_mocked_bindings(
    req_perform = mock_performer$fn,
    .package = "httr2"
  )

  result <- eg_read_rds("/Shared/model.rds")

  expect_s3_class(result, "lm")
})

# Tests for eg_read_xpt (SAS transport)

test_that("eg_read_xpt downloads and parses XPT file", {
  skip_if_not_installed("haven")
  setup_mock_auth()

  # Create XPT file
  test_xpt <- tempfile(fileext = ".xpt")
  haven::write_xpt(data.frame(x = 1:3, y = c(1.1, 2.2, 3.3)), test_xpt)
  xpt_bytes <- readBin(test_xpt, "raw", file.info(test_xpt)$size)
  unlink(test_xpt)

  mock_performer <- mock_request_performer(mock_response(status = 200, body = xpt_bytes))

  local_mocked_bindings(
    req_perform = mock_performer$fn,
    .package = "httr2"
  )

  result <- eg_read_xpt("/Shared/data.xpt")

  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 3)
})

# Tests for eg_read_stata

test_that("eg_read_stata downloads and parses DTA file", {
  skip_if_not_installed("haven")
  setup_mock_auth()

  # Create Stata file
  test_dta <- tempfile(fileext = ".dta")
  haven::write_dta(data.frame(x = 1:3, y = c("a", "b", "c")), test_dta)
  dta_bytes <- readBin(test_dta, "raw", file.info(test_dta)$size)
  unlink(test_dta)

  mock_performer <- mock_request_performer(mock_response(status = 200, body = dta_bytes))

  local_mocked_bindings(
    req_perform = mock_performer$fn,
    .package = "httr2"
  )

  result <- eg_read_stata("/Shared/data.dta")

  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 3)
})

# Tests for eg_read_spss

test_that("eg_read_spss downloads and parses SAV file", {
  skip_if_not_installed("haven")
  setup_mock_auth()

  # Create SPSS file
  test_sav <- tempfile(fileext = ".sav")
  haven::write_sav(data.frame(x = 1:3, y = c(10, 20, 30)), test_sav)
  sav_bytes <- readBin(test_sav, "raw", file.info(test_sav)$size)
  unlink(test_sav)

  mock_performer <- mock_request_performer(mock_response(status = 200, body = sav_bytes))

  local_mocked_bindings(
    req_perform = mock_performer$fn,
    .package = "httr2"
  )

  result <- eg_read_spss("/Shared/data.sav")

  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 3)
})

# Error handling tests

test_that("eg_read_csv handles API errors", {
  skip_if_not_installed("readr")
  setup_mock_auth()

  mock_performer <- mock_request_performer(mock_response(status = 404))

  local_mocked_bindings(
    req_perform = mock_performer$fn,
    .package = "httr2"
  )

  expect_error(
    eg_read_csv("/Shared/missing.csv"),
    "not found"
  )
})

test_that("eg_read_excel handles API errors", {
  skip_if_not_installed("readxl")
  setup_mock_auth()

  mock_performer <- mock_request_performer(mock_response(status = 403))

  local_mocked_bindings(
    req_perform = mock_performer$fn,
    .package = "httr2"
  )

  expect_error(
    eg_read_excel("/Shared/restricted.xlsx"),
    "Access denied"
  )
})
