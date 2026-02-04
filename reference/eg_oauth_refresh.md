# Refresh OAuth Access Token

Uses the stored refresh token to obtain a new access token without
requiring user interaction.

## Usage

``` r
eg_oauth_refresh()
```

## Value

Invisibly returns a list containing the new `access_token`,
`refresh_token`, `token_type`, and `expires_in`.

## Details

Access tokens expire after 30 days. Call this function to obtain a new
access token using the refresh token that was stored during the initial
authorization.

If the refresh token is also expired or revoked (e.g., user changed
password), you will need to run
[`eg_oauth_authorize()`](https://atorus-research.github.io/egnyte/reference/eg_oauth_authorize.md)
again.

## See also

[`eg_oauth_authorize()`](https://atorus-research.github.io/egnyte/reference/eg_oauth_authorize.md)
for the initial authorization.

## Examples

``` r
if (FALSE) { # \dontrun{
# Refresh the access token
eg_oauth_refresh()
} # }
```
