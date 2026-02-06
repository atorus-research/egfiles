Package version 0.1.1

Initial Release resubmission with the following comments resolved:

Possibly misspelled words in DESCRIPTION:
  Egnyte (2:34, 10:62, 11:23)

Please single quote software names in both Title and Description fields
of the DESCRIPTION file.

## R CMD check results

0 errors | 0 warnings | 0 notes

## Test environments

* local macOS (aarch64-apple-darwin20), R 4.5.1
* GitHub Actions: ubuntu-latest (release), windows-latest (release), macOS-latest (release)

## Notes

* All examples use `\dontrun{}` as they require a paid Egnyte account
  and valid API credentials to execute. There is no public test server
  available, so `\donttest{}` is not feasible.
* Vignettes use `eval = FALSE` for the same reason.
* Authentication functions (`eg_auth()`, `eg_oauth_authorize()`, etc.)
  store credentials in R `options()` by explicit user action. This is
  necessary because API calls throughout the session need access to
  the stored credentials. Options are not modified on package load or
  attach.
