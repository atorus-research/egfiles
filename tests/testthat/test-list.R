test_that("eg_list returns file paths from a directory", {
  setup_mock_auth()

  mock_performer <- mock_request_performer(
    mock_json_response(list(
      is_folder = TRUE,
      files = list(
        list(path = "/Shared/Documents/file1.txt"),
        list(path = "/Shared/Documents/file2.csv")
      ),
      folders = list()
    ))
  )

  local_mocked_bindings(
    req_perform = mock_performer$fn,
    .package = "httr2"
  )

  result <- eg_list("/Shared/Documents")

  expect_equal(result, c("/Shared/Documents/file1.txt", "/Shared/Documents/file2.csv"))
  expect_length(mock_performer$env$calls, 1)
})

test_that("eg_list returns empty character vector for empty directory", {
  setup_mock_auth()

  mock_performer <- mock_request_performer(
    mock_json_response(list(
      is_folder = TRUE,
      folders = list()
    ))
  )

  local_mocked_bindings(
    req_perform = mock_performer$fn,
    .package = "httr2"
  )

  result <- eg_list("/Shared/Empty")

  expect_equal(result, character(0))
})

test_that("eg_list cleans path before request", {
  setup_mock_auth()

  mock_performer <- mock_request_performer(
    mock_json_response(list(
      is_folder = TRUE,
      files = list(list(path = "/Shared/docs/file.txt")),
      folders = list()
    ))
  )

  local_mocked_bindings(
    req_perform = mock_performer$fn,
    .package = "httr2"
  )

  # Path without leading slash
  result <- eg_list("Shared/docs")

  expect_equal(result, "/Shared/docs/file.txt")
  expect_true(grepl("fs/Shared/docs", mock_performer$env$calls[[1]]$req$url))
})

test_that("eg_list recursive collects files from subdirectories", {
  setup_mock_auth()

  # Sequence of 4 responses for recursive listing:
  # 1. eg_list_single("/Shared/Root") -> files in root
  # 2. eg_list_folders("/Shared/Root") -> one subfolder
  # 3. eg_list_single("/Shared/Root/Sub") -> files in subfolder
  # 4. eg_list_folders("/Shared/Root/Sub") -> no subfolders (end recursion)
  responses <- list(
    mock_json_response(list(
      is_folder = TRUE,
      files = list(list(path = "/Shared/Root/a.txt")),
      folders = list()
    )),
    mock_json_response(list(
      is_folder = TRUE,
      files = list(),
      folders = list(list(path = "/Shared/Root/Sub"))
    )),
    mock_json_response(list(
      is_folder = TRUE,
      files = list(list(path = "/Shared/Root/Sub/b.txt")),
      folders = list()
    )),
    mock_json_response(list(
      is_folder = TRUE,
      files = list(),
      folders = list()
    ))
  )

  mock_performer <- mock_request_performer(responses)

  local_mocked_bindings(
    req_perform = mock_performer$fn,
    .package = "httr2"
  )

  result <- eg_list("/Shared/Root", recursive = TRUE)

  expect_equal(result, c("/Shared/Root/a.txt", "/Shared/Root/Sub/b.txt"))
  expect_length(mock_performer$env$calls, 4)
})

test_that("eg_list recursive with no subfolders behaves like non-recursive", {
  setup_mock_auth()

  responses <- list(
    # eg_list_single
    mock_json_response(list(
      is_folder = TRUE,
      files = list(list(path = "/Shared/Flat/x.csv")),
      folders = list()
    )),
    # eg_list_folders
    mock_json_response(list(
      is_folder = TRUE,
      files = list(),
      folders = list()
    ))
  )

  mock_performer <- mock_request_performer(responses)

  local_mocked_bindings(
    req_perform = mock_performer$fn,
    .package = "httr2"
  )

  result <- eg_list("/Shared/Flat", recursive = TRUE)

  expect_equal(result, "/Shared/Flat/x.csv")
  expect_length(mock_performer$env$calls, 2)
})

test_that("eg_list errors when path is not a directory", {
  setup_mock_auth()

  mock_performer <- mock_request_performer(
    mock_json_response(list(
      is_folder = FALSE,
      name = "file.txt"
    ))
  )

  local_mocked_bindings(
    req_perform = mock_performer$fn,
    .package = "httr2"
  )

  expect_error(
    eg_list("/Shared/file.txt"),
    "is not a directory"
  )
})

test_that("eg_list handles 401 authentication error", {
  setup_mock_auth()

  mock_performer <- mock_request_performer(mock_response(status = 401))

  local_mocked_bindings(
    req_perform = mock_performer$fn,
    .package = "httr2"
  )

  expect_error(
    eg_list("/Shared/Documents"),
    "Invalid API key"
  )
})

test_that("eg_list handles 403 permission error", {
  setup_mock_auth()

  mock_performer <- mock_request_performer(mock_response(status = 403))

  local_mocked_bindings(
    req_perform = mock_performer$fn,
    .package = "httr2"
  )

  expect_error(
    eg_list("/Shared/Restricted"),
    "Access denied"
  )
})

test_that("eg_list handles 404 not found error", {
  setup_mock_auth()

  mock_performer <- mock_request_performer(mock_response(status = 404))

  local_mocked_bindings(
    req_perform = mock_performer$fn,
    .package = "httr2"
  )

  expect_error(
    eg_list("/Shared/Nonexistent"),
    "not found"
  )
})

test_that("eg_encode_path encodes special characters", {
  # Simple path with no special characters
  expect_equal(eg_encode_path("/Shared/Documents"), "/Shared/Documents")

  # Path with spaces
  expect_equal(eg_encode_path("/Shared/My Documents"), "/Shared/My%20Documents")

  # Path with multiple special characters
  result <- eg_encode_path("/Shared/folder name/file (1)")
  expect_true(grepl("folder%20name", result))
  expect_true(grepl("%28", result))  # encoded '('
})

test_that("eg_list_single constructs correct API endpoint", {
  setup_mock_auth()

  mock_performer <- mock_request_performer(
    mock_json_response(list(
      is_folder = TRUE,
      files = list(list(path = "/Shared/Test/file.txt")),
      folders = list()
    ))
  )

  local_mocked_bindings(
    req_perform = mock_performer$fn,
    .package = "httr2"
  )

  result <- eg_list_single("/Shared/Test")

  expect_equal(result, "/Shared/Test/file.txt")
  expect_true(grepl("fs/Shared/Test", mock_performer$env$calls[[1]]$req$url))
})

test_that("eg_list_folders returns folder paths", {
  setup_mock_auth()

  mock_performer <- mock_request_performer(
    mock_json_response(list(
      is_folder = TRUE,
      files = list(),
      folders = list(
        list(path = "/Shared/Dir/Sub1"),
        list(path = "/Shared/Dir/Sub2")
      )
    ))
  )

  local_mocked_bindings(
    req_perform = mock_performer$fn,
    .package = "httr2"
  )

  result <- eg_list_folders("/Shared/Dir")

  expect_equal(result, c("/Shared/Dir/Sub1", "/Shared/Dir/Sub2"))
})

test_that("eg_list_folders returns empty vector when no folders", {
  setup_mock_auth()

  mock_performer <- mock_request_performer(
    mock_json_response(list(
      is_folder = TRUE,
      files = list(list(path = "/Shared/Flat/only_files.txt"))
    ))
  )

  local_mocked_bindings(
    req_perform = mock_performer$fn,
    .package = "httr2"
  )

  result <- eg_list_folders("/Shared/Flat")

  expect_equal(result, character(0))
})
