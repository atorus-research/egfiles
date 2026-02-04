# List Files in an Egnyte Directory

Returns a character vector of full file paths within the specified
Egnyte directory.

## Usage

``` r
eg_list(path, recursive = FALSE)
```

## Arguments

- path:

  The Egnyte path to the directory (e.g., "/Shared/Documents").

- recursive:

  If TRUE, recursively list files in subdirectories. Defaults to FALSE.

## Value

A character vector of full file paths.

## Examples

``` r
if (FALSE) { # \dontrun{
# List files in a directory
eg_list("/Shared/Documents")

# Recursively list all files
eg_list("/Shared/Documents", recursive = TRUE)
} # }
```
