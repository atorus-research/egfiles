# Upload a File to Egnyte

Uploads a local file to Egnyte cloud storage.

## Usage

``` r
eg_write(file, path, overwrite = FALSE)
```

## Arguments

- file:

  Local path to the file to upload.

- path:

  The Egnyte destination path (e.g., "/Shared/Documents/file.txt").

- overwrite:

  If FALSE (default), the upload will fail if a file already exists at
  the destination. Set to TRUE to replace existing files.

## Value

The Egnyte path (invisibly).

## Examples

``` r
if (FALSE) { # \dontrun{
# Upload a file
eg_write("local_report.pdf", "/Shared/Documents/report.pdf")

# Overwrite an existing file
eg_write("updated_data.csv", "/Shared/Data/data.csv", overwrite = TRUE)
} # }
```
