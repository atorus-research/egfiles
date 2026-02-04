# File Transfer

This vignette covers how to upload and download files to and from Egnyte
using egfiles. We’ll focus on the core
[`eg_read()`](https://username.github.io/egfiles/reference/eg_read.md)
and
[`eg_write()`](https://username.github.io/egfiles/reference/eg_write.md)
functions, which handle raw file transfers. If you’re working with data
files specifically (CSVs, Excel files, etc.) and want to load them
directly into R data frames, see
[`vignette("reading-writing")`](https://username.github.io/egfiles/articles/reading-writing.md)
instead.

## Prerequisites

Before you can transfer files, you need to authenticate with Egnyte. If
you haven’t done that yet, see
[`vignette("configuration")`](https://username.github.io/egfiles/articles/configuration.md)
or
[`vignette("authorization")`](https://username.github.io/egfiles/articles/authorization.md)
to get set up.

``` r
library(egfiles)

# Authenticate (assuming you've set up environment variables)
eg_auth()
```

## Downloading Files

The
[`eg_read()`](https://username.github.io/egfiles/reference/eg_read.md)
function downloads a file from Egnyte to your local machine.

### Basic Usage

``` r
# Download a file to a specific location
eg_read("/Shared/Documents/report.pdf", destfile = "local_report.pdf")
```

The first argument is the path to the file in Egnyte. Egnyte paths
typically start with `/Shared/` for shared folders or
`/Private/username/` for private folders.

### Downloading to a Temporary File

If you don’t specify a destination,
[`eg_read()`](https://username.github.io/egfiles/reference/eg_read.md)
creates a temporary file and returns its path:

``` r
# Download to a temp file
temp_path <- eg_read("/Shared/Documents/report.pdf")

# The file is now at temp_path
print(temp_path)
#> [1] "/var/folders/.../file123.pdf"
```

This is useful when you just need to work with a file briefly and don’t
care where it’s stored.

### Understanding Egnyte Paths

Egnyte paths can be a bit different from what you might expect:

- They always start with a forward slash
- Shared content is under `/Shared/`
- Private folders are under `/Private/your-username/`
- Paths are case-sensitive

Some examples:

``` r
# A file in a shared folder
eg_read("/Shared/Data/analysis/results.csv", destfile = "results.csv")

# A file in a nested folder
eg_read("/Shared/Projects/2024/Q1/report.docx", destfile = "report.docx")

# A file in your private folder
eg_read("/Private/jsmith/notes.txt", destfile = "notes.txt")
```

If you’re not sure what the correct path is, the easiest approach is to
navigate to the file in the Egnyte web interface and look at the URL.
The path after your domain is the Egnyte path.

## Uploading Files

The
[`eg_write()`](https://username.github.io/egfiles/reference/eg_write.md)
function uploads a local file to Egnyte.

### Basic Usage

``` r
# Upload a file
eg_write("local_report.pdf", path = "/Shared/Documents/report.pdf")
```

The first argument is the path to your local file, and `path` is where
you want it to end up in Egnyte.

### Handling Existing Files

By default,
[`eg_write()`](https://username.github.io/egfiles/reference/eg_write.md)
will fail if a file already exists at the destination:

``` r
# This will error if the file already exists
eg_write("report.pdf", path = "/Shared/Documents/report.pdf")
#> Error: File already exists at /Shared/Documents/report.pdf
#> Use overwrite = TRUE to replace it
```

If you want to replace an existing file, set `overwrite = TRUE`:

``` r
# Replace existing file
eg_write("report.pdf", path = "/Shared/Documents/report.pdf", overwrite = TRUE)
```

This behavior is intentional - it prevents you from accidentally
overwriting files. Get in the habit of being explicit about when you
want to overwrite.

### Creating Folders

When you upload a file, Egnyte will create any necessary parent folders
automatically. You don’t need to create the folder structure beforehand:

``` r
# This works even if the "2024/Q1" folders don't exist yet
eg_write("report.pdf", path = "/Shared/Projects/2024/Q1/report.pdf")
```

## Working with Different File Types

[`eg_read()`](https://username.github.io/egfiles/reference/eg_read.md)
and
[`eg_write()`](https://username.github.io/egfiles/reference/eg_write.md)
work with any file type - they just transfer bytes. This makes them
suitable for:

- Documents (PDF, Word, etc.)
- Images
- Archives (ZIP, tar, etc.)
- Any binary file
- Text files you want to process yourself

For data files where you want to load the contents directly into R as a
data frame, egfiles provides specialized functions like
[`eg_read_csv()`](https://username.github.io/egfiles/reference/eg_read_file.md),
[`eg_read_excel()`](https://username.github.io/egfiles/reference/eg_read_file.md),
etc. See
[`vignette("reading-writing")`](https://username.github.io/egfiles/articles/reading-writing.md)
for those.

## Listing Directory Contents

The
[`eg_list()`](https://username.github.io/egfiles/reference/eg_list.md)
function returns the full paths of files within an Egnyte directory.

### Basic Usage

``` r
# List files in a directory
files <- eg_list("/Shared/Documents")
files
#> [1] "/Shared/Documents/report.pdf"
#> [2] "/Shared/Documents/notes.txt"
#> [3] "/Shared/Documents/data.csv"
```

### Recursive Listing

To list files in subdirectories as well, use `recursive = TRUE`:

``` r
# List all files, including those in subdirectories
all_files <- eg_list("/Shared/Projects", recursive = TRUE)
all_files
#> [1] "/Shared/Projects/readme.txt"
#> [2] "/Shared/Projects/2024/Q1/report.pdf"
#> [3] "/Shared/Projects/2024/Q1/data.xlsx"
#> [4] "/Shared/Projects/2024/Q2/summary.docx"
```

### Filtering Results

Since
[`eg_list()`](https://username.github.io/egfiles/reference/eg_list.md)
returns a character vector, you can filter results with standard R
functions:

``` r
# Get only CSV files
all_files <- eg_list("/Shared/Data", recursive = TRUE)
csv_files <- all_files[grepl("\\.csv$", all_files)]

# Get files matching a pattern
reports <- all_files[grepl("report", all_files, ignore.case = TRUE)]
```

### Combining with Downloads

A common workflow is to list files, filter them, and then download:

``` r
# Find all Excel files in a project folder
files <- eg_list("/Shared/Projects/2024", recursive = TRUE)
excel_files <- files[grepl("\\.xlsx$", files)]

# Download each one
for (f in excel_files) {
  local_name <- basename(f)
  eg_read(f, destfile = file.path("downloads", local_name))
}
```

## Common Patterns

### Downloading, Processing, and Re-uploading

A common workflow is to download a file, do something with it, and
upload the result:

``` r
# Download the raw data
eg_read("/Shared/Data/raw_data.xlsx", destfile = "raw_data.xlsx")

# ... do your processing ...
# (maybe using readxl to read it, process with dplyr, write with writexl)

# Upload the processed result
eg_write("processed_data.xlsx", path = "/Shared/Data/processed_data.xlsx")
```

### Batch Downloads

If you need to download multiple files, you can use a loop or apply
function:

``` r
# Files to download
files <- c(
  "/Shared/Data/file1.csv",
  "/Shared/Data/file2.csv",
  "/Shared/Data/file3.csv"
)

# Download each to a local folder
for (f in files) {
  local_name <- basename(f)
  eg_read(f, destfile = file.path("downloads", local_name))
}
```

### Checking If a File Exists Before Uploading

There’s no dedicated function to check if a file exists, but you can use
a simple pattern:

``` r
safe_upload <- function(local_file, egnyte_path, overwrite = FALSE) {
  tryCatch(
    eg_write(local_file, path = egnyte_path, overwrite = overwrite),
    error = function(e) {
      if (grepl("already exists", e$message)) {
        message("File exists. Use overwrite = TRUE to replace.")
      } else {
        stop(e)
      }
    }
  )
}
```

## Error Handling

When things go wrong, egfiles tries to give you helpful error messages:

**File not found:**

    Error: File not found at /Shared/Documents/missing.pdf

Check the path - remember it’s case-sensitive.

**Access denied:**

    Error: Access denied to /Shared/Confidential/secret.pdf

You don’t have permission for this file or folder. Talk to your Egnyte
admin.

**File already exists:**

    Error: File already exists at /Shared/Documents/report.pdf
    Use overwrite = TRUE to replace it

Either use a different path or set `overwrite = TRUE`.

**Authentication error:**

    Error: Invalid API key or token expired

Re-run your authentication setup. See
[`vignette("authorization")`](https://username.github.io/egfiles/articles/authorization.md).

## Next Steps

Now that you know how to transfer files:

- Learn to read data files directly into R with
  [`vignette("reading-writing")`](https://username.github.io/egfiles/articles/reading-writing.md)
- Review authentication options in
  [`vignette("authorization")`](https://username.github.io/egfiles/articles/authorization.md)
