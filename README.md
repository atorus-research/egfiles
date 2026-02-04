# egnyte

<!-- badges: start -->
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

## Overview

**egnyte** provides an interface for reading and writing files directly to and from [Egnyte](https://www.egnyte.com/) cloud storage. If you work in an environment where Egnyte is your file storage solution, this package lets you interact with those files programmatically from R without manually downloading and uploading through the web interface.

The package supports multiple authentication methods (API keys and OAuth 2.0) and handles a variety of file formats commonly used in data analysis. Under the hood, egnyte leverages the excellent [readr](https://readr.tidyverse.org/), [readxl](https://readxl.tidyverse.org/), and [haven](https://haven.tidyverse.org/) packages for file parsing, so if you're familiar with those packages, the interfaces here should feel natural.

## Installation

You can install egnyte from GitHub:

```r
# install.packages("pak")
pak::pak("atorus-research/egnyte")
```

## Getting Started

Before you can interact with Egnyte, you need to authenticate. The simplest approach is using an API key:

```r
library(egnyte)

eg_auth(
  domain = "your-company",
  api_key = "your-api-key"
)
```

Once authenticated, reading and writing files is straightforward:

```r
# Read a CSV file from Egnyte
dat <- eg_read_csv("/Shared/Data/analysis.csv")

# Write results back to Egnyte
eg_write_csv(results, "/Shared/Data/results.csv")
```

For a more complete walkthrough, see `vignette("configuration")` to set up your credentials and `vignette("authorization")` to understand the different authentication options.

## Supported File Formats

egnyte provides format-specific functions for common data file types. These functions use [readr](https://readr.tidyverse.org/), [readxl](https://readxl.tidyverse.org/), [writexl](https://docs.ropensci.org/writexl/), and [haven](https://haven.tidyverse.org/) under the hood, so all arguments you're familiar with from those packages are available here.

| Format | Read | Write | Underlying Package |
|--------|------|-------|------------------|
| CSV | `eg_read_csv()` | `eg_write_csv()` | readr |
| Delimited | `eg_read_delim()` | `eg_write_delim()` | readr |
| Excel | `eg_read_excel()` | `eg_write_excel()` | readxl / writexl |
| SAS (.sas7bdat) | `eg_read_sas()` | — | haven |
| SAS Transport (.xpt) | `eg_read_xpt()` | `eg_write_xpt()` | haven |
| Stata (.dta) | `eg_read_stata()` | `eg_write_stata()` | haven |
| SPSS (.sav) | `eg_read_spss()` | `eg_write_spss()` | haven |
| RDS | `eg_read_rds()` | `eg_write_rds()` | base R |

For any file type not listed above, you can use `eg_read()` and `eg_write()` to transfer raw files.

## Authentication Methods

egnyte supports three authentication approaches:

- **API Key**: Simplest option, good for personal use and scripting
- **OAuth Authorization Code**: Interactive browser-based login, supports token refresh
- **OAuth Password**: Direct username/password authentication

See `vignette("authorization")` for details on when to use each method.

## Learn More

- `vignette("configuration")` - Setting up your API key and environment
- `vignette("authorization")` - Understanding authentication methods
- `vignette("file-transfer")` - Uploading and downloading files
- `vignette("reading-writing")` - Working with data files

## Code of Conduct

Please note that the egnyte project is released with a [Contributor Code of Conduct](https://contributor-covenant.org/version/2/1/CODE_OF_CONDUCT.html). By contributing to this project, you agree to abide by its terms.
