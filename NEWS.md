# egnyte 0.1.0

* Initial CRAN release.
* Core file transfer functions: `eg_read()` and `eg_write()`.
* Format-specific readers: `eg_read_csv()`, `eg_read_delim()`, `eg_read_excel()`,
  `eg_read_sas()`, `eg_read_xpt()`, `eg_read_stata()`, `eg_read_spss()`,
  `eg_read_rds()`.
* Format-specific writers: `eg_write_csv()`, `eg_write_delim()`,
  `eg_write_excel()`, `eg_write_xpt()`, `eg_write_stata()`, `eg_write_spss()`,
  `eg_write_rds()`.
* Directory listing with `eg_list()`, including recursive support.
* API key authentication via `eg_auth()`.
* OAuth 2.0 support: Authorization Code flow (`eg_oauth_authorize()`),
  Resource Owner Password flow (`eg_oauth_password()`), and token refresh
  (`eg_oauth_refresh()`).
