# Set Egnyte Authentication Credentials

Stores Egnyte domain and API key for use in subsequent API calls.
Credentials can also be set via environment variables `EGNYTE_DOMAIN`
and `EGNYTE_API_KEY`.

## Usage

``` r
eg_auth(domain, api_key)
```

## Arguments

- domain:

  Your Egnyte domain (the subdomain part of yourcompany.egnyte.com)

- api_key:

  Your Egnyte API key or OAuth access token

## Value

Invisibly returns a list with the stored credentials.

## Examples

``` r
if (FALSE) { # \dontrun{
eg_auth("mycompany", "my_api_key_here")
} # }
```
