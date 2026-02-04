# Reading and Writing Data Files

While
[`eg_read()`](https://atorus-research.github.io/egnyte/reference/eg_read.md)
and
[`eg_write()`](https://atorus-research.github.io/egnyte/reference/eg_write.md)
handle raw file transfers, you probably spend most of your time working
with data files that you want to load directly into R as data frames.
egnyte provides a set of functions that handle the download-read or
write-upload workflow in a single step.

## Prerequisites

Before you can read or write files, you need to authenticate. See
[`vignette("configuration")`](https://atorus-research.github.io/egnyte/articles/configuration.md)
or
[`vignette("authorization")`](https://atorus-research.github.io/egnyte/articles/authorization.md)
if you haven’t set that up yet.

``` r
library(egnyte)

eg_auth()
```

## Reading Data Files

egnyte provides read functions for common data formats. Each function:

1.  Downloads the file from Egnyte to a temporary location
2.  Reads it using the appropriate R package
3.  Returns the data as a data frame (or tibble)
4.  Cleans up the temporary file

### CSV Files

``` r
# Read a CSV file
dat <- eg_read_csv("/Shared/Data/analysis.csv")
```

This uses
[`readr::read_csv()`](https://readr.tidyverse.org/reference/read_delim.html)
under the hood. You can pass any additional arguments that `read_csv()`
accepts:

``` r
# Specify column types
dat <- eg_read_csv(
  "/Shared/Data/analysis.csv",
  col_types = cols(
    id = col_integer(),
    name = col_character(),
    value = col_double()
  )
)

# Skip rows, select columns, etc.
dat <- eg_read_csv(
  "/Shared/Data/analysis.csv",
  skip = 2,
  col_select = c(id, name, value)
)
```

### Delimited Files

For files with delimiters other than commas:

``` r
# Tab-delimited file (default)
dat <- eg_read_delim("/Shared/Data/data.tsv")

# Pipe-delimited file
dat <- eg_read_delim("/Shared/Data/data.txt", delim = "|")

# Semicolon-delimited (common in European CSVs)
dat <- eg_read_delim("/Shared/Data/european.csv", delim = ";")
```

### Excel Files

``` r
# Read an Excel file (first sheet by default)
dat <- eg_read_excel("/Shared/Data/workbook.xlsx")

# Read a specific sheet by name
dat <- eg_read_excel("/Shared/Data/workbook.xlsx", sheet = "Summary")

# Read a specific sheet by position
dat <- eg_read_excel("/Shared/Data/workbook.xlsx", sheet = 3)
```

Additional
[`readxl::read_excel()`](https://readxl.tidyverse.org/reference/read_excel.html)
arguments work here too:

``` r
# Specify a range
dat <- eg_read_excel(
  "/Shared/Data/workbook.xlsx",
  range = "B2:F100"
)

# Skip rows
dat <- eg_read_excel(
  "/Shared/Data/workbook.xlsx",
  skip = 5
)
```

### SAS Files

``` r
# Read a SAS7BDAT file
dat <- eg_read_sas("/Shared/Data/dataset.sas7bdat")

# Read a SAS transport file (.xpt)
dat <- eg_read_xpt("/Shared/Data/dataset.xpt")
```

These use
[`haven::read_sas()`](https://haven.tidyverse.org/reference/read_sas.html)
and
[`haven::read_xpt()`](https://haven.tidyverse.org/reference/read_xpt.html).
Haven preserves SAS attributes like variable labels and formats.

### Stata Files

``` r
# Read a Stata file
dat <- eg_read_stata("/Shared/Data/dataset.dta")
```

### SPSS Files

``` r
# Read an SPSS file
dat <- eg_read_spss("/Shared/Data/dataset.sav")
```

### R Objects (RDS)

``` r
# Read an RDS file
obj <- eg_read_rds("/Shared/Data/model.rds")
```

RDS files can contain any R object, not just data frames. This is useful
for saving fitted models, lists, or other complex objects.

## Writing Data Files

The write functions work in reverse - they take an R object, write it to
a temporary file, and upload it to Egnyte.

### CSV Files

``` r
# Write a data frame to CSV
eg_write_csv(dat, "/Shared/Data/results.csv")
```

By default, this will fail if the file already exists:

``` r
# Overwrite an existing file
eg_write_csv(dat, "/Shared/Data/results.csv", overwrite = TRUE)
```

You can pass additional arguments to
[`readr::write_csv()`](https://readr.tidyverse.org/reference/write_delim.html):

``` r
# Don't include column names
eg_write_csv(dat, "/Shared/Data/results.csv", col_names = FALSE)

# Use a different NA representation
eg_write_csv(dat, "/Shared/Data/results.csv", na = ".")
```

### Delimited Files

``` r
# Write a tab-delimited file
eg_write_delim(dat, "/Shared/Data/results.tsv")

# Write with a different delimiter
eg_write_delim(dat, "/Shared/Data/results.txt", delim = "|")
```

### Excel Files

``` r
# Write a single sheet
eg_write_excel(dat, "/Shared/Data/results.xlsx")

# Write multiple sheets by passing a named list
eg_write_excel(
  list(
    "Summary" = summary_df,
    "Details" = details_df,
    "Raw" = raw_df
  ),
  "/Shared/Data/workbook.xlsx"
)
```

### SAS Transport Files

``` r
# Write a SAS transport file
eg_write_xpt(dat, "/Shared/Data/results.xpt")
```

Note: egnyte can write XPT files but not native SAS7BDAT files. If you
need SAS7BDAT, you’ll need to use SAS itself or another tool.

### Stata Files

``` r
# Write a Stata file
eg_write_stata(dat, "/Shared/Data/results.dta")
```

### SPSS Files

``` r
# Write an SPSS file
eg_write_spss(dat, "/Shared/Data/results.sav")
```

### R Objects (RDS)

``` r
# Save any R object
eg_write_rds(fitted_model, "/Shared/Data/model.rds")

# Control compression
eg_write_rds(large_data, "/Shared/Data/data.rds", compress = "xz")
```

## Optional Dependencies

The format-specific functions require additional packages that aren’t
installed by default with egnyte:

| Function                                                                                                                                                                                                                                                              | Required Package            |
|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------|
| [`eg_read_csv()`](https://atorus-research.github.io/egnyte/reference/eg_read_file.md), [`eg_write_csv()`](https://atorus-research.github.io/egnyte/reference/eg_write_file.md)                                                                                        | readr                       |
| [`eg_read_delim()`](https://atorus-research.github.io/egnyte/reference/eg_read_file.md), [`eg_write_delim()`](https://atorus-research.github.io/egnyte/reference/eg_write_file.md)                                                                                    | readr                       |
| [`eg_read_excel()`](https://atorus-research.github.io/egnyte/reference/eg_read_file.md)                                                                                                                                                                               | readxl                      |
| [`eg_write_excel()`](https://atorus-research.github.io/egnyte/reference/eg_write_file.md)                                                                                                                                                                             | writexl                     |
| [`eg_read_sas()`](https://atorus-research.github.io/egnyte/reference/eg_read_file.md), [`eg_read_xpt()`](https://atorus-research.github.io/egnyte/reference/eg_read_file.md), [`eg_write_xpt()`](https://atorus-research.github.io/egnyte/reference/eg_write_file.md) | haven                       |
| [`eg_read_stata()`](https://atorus-research.github.io/egnyte/reference/eg_read_file.md), [`eg_write_stata()`](https://atorus-research.github.io/egnyte/reference/eg_write_file.md)                                                                                    | haven                       |
| [`eg_read_spss()`](https://atorus-research.github.io/egnyte/reference/eg_read_file.md), [`eg_write_spss()`](https://atorus-research.github.io/egnyte/reference/eg_write_file.md)                                                                                      | haven                       |
| [`eg_read_rds()`](https://atorus-research.github.io/egnyte/reference/eg_read_file.md), [`eg_write_rds()`](https://atorus-research.github.io/egnyte/reference/eg_write_file.md)                                                                                        | (base R - no extra package) |

If you try to use a function without the required package installed,
egnyte will prompt you to install it:

    The readr package is required for this function.
    Would you like to install it? (yes/no)

## A Few Tips

### Working with Large Files

The read functions download the entire file before reading it. For large
files, this can take a while and use significant memory. A few
suggestions:

- If you only need specific columns, use the `col_select` argument (for
  CSV/delim files) to avoid loading unnecessary data
- Consider whether you really need the whole file, or if you can work
  with a sample
- For very large datasets, you might want to use
  [`eg_read()`](https://atorus-research.github.io/egnyte/reference/eg_read.md)
  to download the file once, then work with it locally

### Passing Arguments Through

All the format-specific functions accept `...` arguments that get passed
to the underlying read/write function. If you’re familiar with
[`readr::read_csv()`](https://readr.tidyverse.org/reference/read_delim.html)
or
[`haven::read_sas()`](https://haven.tidyverse.org/reference/read_sas.html),
you can use all the same options:

``` r
# readr options
dat <- eg_read_csv(
  "/Shared/Data/data.csv",
  col_types = "ccdd",
  locale = locale(decimal_mark = ","),
  na = c("", "NA", "N/A", ".")
)

# haven options
dat <- eg_read_sas(
  "/Shared/Data/data.sas7bdat",
  encoding = "latin1"
)
```

### File Extensions Matter

egnyte uses the file extension to determine the format when downloading.
Make sure your files have the correct extension:

- `.csv` for CSV files
- `.xlsx` or `.xls` for Excel files
- `.sas7bdat` for SAS data files
- `.xpt` for SAS transport files
- `.dta` for Stata files
- `.sav` for SPSS files
- `.rds` for R objects

## Comparison with Base File Transfer

Here’s the difference between using the format-specific functions
vs. the base
[`eg_read()`](https://atorus-research.github.io/egnyte/reference/eg_read.md)/[`eg_write()`](https://atorus-research.github.io/egnyte/reference/eg_write.md):

**Using eg_read_csv() (recommended for data files):**

``` r
# One step - download and read
dat <- eg_read_csv("/Shared/Data/data.csv")
```

**Using eg_read() (manual approach):**

``` r
# Two steps - download, then read
temp_file <- eg_read("/Shared/Data/data.csv")
dat <- readr::read_csv(temp_file)
unlink(temp_file)  # Clean up
```

The format-specific functions handle all this for you and clean up
temporary files automatically.

## Next Steps

- Learn about authentication options in
  [`vignette("authorization")`](https://atorus-research.github.io/egnyte/articles/authorization.md)
- See raw file transfer in
  [`vignette("file-transfer")`](https://atorus-research.github.io/egnyte/articles/file-transfer.md)
