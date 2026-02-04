# Write Data Files to Egnyte

These functions write R objects to data files and upload them to Egnyte.
Each function is a thin wrapper that writes to a temporary file using
the appropriate package, then handles the upload.

## Usage

``` r
eg_write_csv(x, path, overwrite = FALSE, ...)

eg_write_delim(x, path, delim = "\t", overwrite = FALSE, ...)

eg_write_xpt(x, path, overwrite = FALSE, ...)

eg_write_stata(x, path, overwrite = FALSE, ...)

eg_write_spss(x, path, overwrite = FALSE, ...)

eg_write_excel(x, path, overwrite = FALSE, ...)

eg_write_rds(x, path, overwrite = FALSE, compress = TRUE)
```

## Arguments

- x:

  A data frame (or R object for `eg_write_rds()`) to write. For
  `eg_write_excel()`, can also be a named list of data frames to create
  multiple sheets.

- path:

  The Egnyte destination path (e.g., "/Shared/Data/results.csv").

- overwrite:

  If `FALSE` (default), fails if a file already exists at `path`. Set to
  `TRUE` to replace existing files.

- ...:

  Additional arguments passed to the underlying write function.

- delim:

  The field delimiter. Defaults to tab (`"\t"`).

- compress:

  Compression type for RDS files. See
  [`saveRDS()`](https://rdrr.io/r/base/readRDS.html) for options.
  Defaults to `TRUE`.

## Value

The Egnyte path (invisibly).

## Details

Each function requires an optional package to be installed:

|                    |          |                                                                                         |
|--------------------|----------|-----------------------------------------------------------------------------------------|
| Function           | Package  | Underlying Function                                                                     |
| `eg_write_csv()`   | readr    | [`readr::write_csv()`](https://readr.tidyverse.org/reference/write_delim.html)          |
| `eg_write_delim()` | readr    | [`readr::write_delim()`](https://readr.tidyverse.org/reference/write_delim.html)        |
| `eg_write_excel()` | writexl  | [`writexl::write_xlsx()`](https://docs.ropensci.org/writexl//reference/write_xlsx.html) |
| `eg_write_xpt()`   | haven    | [`haven::write_xpt()`](https://haven.tidyverse.org/reference/read_xpt.html)             |
| `eg_write_stata()` | haven    | [`haven::write_dta()`](https://haven.tidyverse.org/reference/read_dta.html)             |
| `eg_write_spss()`  | haven    | [`haven::write_sav()`](https://haven.tidyverse.org/reference/read_spss.html)            |
| `eg_write_rds()`   | (base R) | [`saveRDS()`](https://rdrr.io/r/base/readRDS.html)                                      |

All arguments passed through `...` are forwarded to the underlying
function.

**Note on SAS files:** Haven can only write SAS transport files (.xpt),
not native SAS data files (.sas7bdat). Transport files are compatible
with SAS and can be read back with
[`eg_read_xpt()`](https://atorus-research.github.io/egnyte/reference/eg_read_file.md)
or
[`haven::read_xpt()`](https://haven.tidyverse.org/reference/read_xpt.html).

## See also

- [`eg_write()`](https://atorus-research.github.io/egnyte/reference/eg_write.md)
  for uploading raw files without conversion

- [eg_read_file](https://atorus-research.github.io/egnyte/reference/eg_read_file.md)
  for reading data files from Egnyte

## Examples

``` r
if (FALSE) { # \dontrun{
# CSV files
eg_write_csv(mtcars, "/Shared/Data/mtcars.csv")
eg_write_csv(mtcars, "/Shared/Data/mtcars.csv", overwrite = TRUE)

# Delimited files
eg_write_delim(mtcars, "/Shared/Data/mtcars.tsv")
eg_write_delim(mtcars, "/Shared/Data/mtcars.txt", delim = "|")

# Excel files
eg_write_excel(mtcars, "/Shared/Data/mtcars.xlsx")

# Multiple sheets
eg_write_excel(
  list(cars = mtcars, flowers = iris),
  "/Shared/Data/workbook.xlsx"
)

# SAS transport files
eg_write_xpt(mtcars, "/Shared/Data/mtcars.xpt")

# Stata files
eg_write_stata(mtcars, "/Shared/Data/mtcars.dta")

# SPSS files
eg_write_spss(mtcars, "/Shared/Data/mtcars.sav")

# RDS files (any R object)
eg_write_rds(my_model, "/Shared/Data/model.rds")
eg_write_rds(large_data, "/Shared/Data/data.rds", compress = "xz")
} # }
```
