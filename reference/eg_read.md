# Download a File from Egnyte

Downloads a file from Egnyte cloud storage to a local path.

## Usage

``` r
eg_read(path, destfile = NULL)
```

## Arguments

- path:

  The Egnyte path to the file (e.g., "/Shared/Documents/file.txt").

- destfile:

  Local file path where the file will be saved. If NULL (default), the
  file is downloaded to a temporary file.

## Value

The local file path (invisibly).

## Examples

``` r
if (FALSE) { # \dontrun{
# Download to a specific location
eg_read("/Shared/Documents/report.pdf", "local_report.pdf")

# Download to a temp file
local_path <- eg_read("/Shared/Documents/data.csv")
read.csv(local_path)
} # }
```
