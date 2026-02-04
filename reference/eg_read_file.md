# Read Data Files from Egnyte

These functions download data files from Egnyte and read them into R
using the appropriate package. Each function is a thin wrapper that
handles the file transfer, then delegates to the underlying reader.

## Usage

``` r
eg_read_csv(path, ...)

eg_read_delim(path, delim = "\t", ...)

eg_read_sas(path, ...)

eg_read_xpt(path, ...)

eg_read_stata(path, ...)

eg_read_spss(path, ...)

eg_read_excel(path, sheet = NULL, ...)

eg_read_rds(path)
```

## Arguments

- path:

  The Egnyte path to the file (e.g., "/Shared/Data/myfile.csv").

- ...:

  Additional arguments passed to the underlying read function.

- delim:

  The field delimiter. Defaults to tab (`"\t"`).

- sheet:

  Sheet to read. Either a string (sheet name) or an integer (sheet
  position). Defaults to the first sheet.

## Value

- For tabular data: A tibble (or data frame for RDS files containing
  data frames).

- For RDS files: The R object stored in the file.

Haven-based readers (`eg_read_sas()`, `eg_read_xpt()`,
`eg_read_stata()`, `eg_read_spss()`) return tibbles with labelled
columns preserving variable labels and formats from the source file.

## Details

Each function requires an optional package to be installed:

|                   |          |                                                                                  |
|-------------------|----------|----------------------------------------------------------------------------------|
| Function          | Package  | Underlying Function                                                              |
| `eg_read_csv()`   | readr    | [`readr::read_csv()`](https://readr.tidyverse.org/reference/read_delim.html)     |
| `eg_read_delim()` | readr    | [`readr::read_delim()`](https://readr.tidyverse.org/reference/read_delim.html)   |
| `eg_read_excel()` | readxl   | [`readxl::read_excel()`](https://readxl.tidyverse.org/reference/read_excel.html) |
| `eg_read_sas()`   | haven    | [`haven::read_sas()`](https://haven.tidyverse.org/reference/read_sas.html)       |
| `eg_read_xpt()`   | haven    | [`haven::read_xpt()`](https://haven.tidyverse.org/reference/read_xpt.html)       |
| `eg_read_stata()` | haven    | [`haven::read_dta()`](https://haven.tidyverse.org/reference/read_dta.html)       |
| `eg_read_spss()`  | haven    | [`haven::read_sav()`](https://haven.tidyverse.org/reference/read_spss.html)      |
| `eg_read_rds()`   | (base R) | [`readRDS()`](https://rdrr.io/r/base/readRDS.html)                               |

All arguments passed through `...` are forwarded to the underlying
function, so you can use any options those functions support (e.g.,
`col_types` for readr functions, `encoding` for haven functions).

## See also

- [`eg_read()`](https://atorus-research.github.io/egnyte/reference/eg_read.md)
  for downloading raw files without parsing

- [eg_write_file](https://atorus-research.github.io/egnyte/reference/eg_write_file.md)
  for writing data files to Egnyte

## Examples

``` r
if (FALSE) { # \dontrun{
# CSV files
df <- eg_read_csv("/Shared/Data/mydata.csv")
df <- eg_read_csv("/Shared/Data/mydata.csv", col_types = "ccn")

# Delimited files
df <- eg_read_delim("/Shared/Data/mydata.txt")
df <- eg_read_delim("/Shared/Data/mydata.txt", delim = "|")

# Excel files
df <- eg_read_excel("/Shared/Data/workbook.xlsx")
df <- eg_read_excel("/Shared/Data/workbook.xlsx", sheet = "Summary")

# SAS files
df <- eg_read_sas("/Shared/Data/mydata.sas7bdat")
df <- eg_read_xpt("/Shared/Data/mydata.xpt")

# Stata files
df <- eg_read_stata("/Shared/Data/mydata.dta")

# SPSS files
df <- eg_read_spss("/Shared/Data/mydata.sav")

# RDS files (any R object)
obj <- eg_read_rds("/Shared/Data/model.rds")
} # }
```
