# Authenticate with Egnyte Using Username and Password

Uses the OAuth 2.0 Resource Owner Password flow to obtain an access
token directly using Egnyte credentials. This is simpler than the
Authorization Code flow and doesn't require browser interaction.

## Usage

``` r
eg_oauth_password(username = NULL, password = NULL)
```

## Arguments

- username:

  Egnyte username. If NULL, checks the `EGNYTE_USERNAME` environment
  variable.

- password:

  Egnyte password. If NULL, checks the `EGNYTE_PASSWORD` environment
  variable.

## Value

Invisibly returns a list containing `access_token` and `expires_in`.

## Details

This flow is intended for internal applications where the user trusts
the application with their credentials. The username and password are
sent directly to Egnyte's token endpoint.

You must first configure the OAuth app with
[`eg_oauth_app()`](https://username.github.io/egfiles/reference/eg_oauth_app.md).

Credentials can be provided via:

- Function arguments

- Environment variables: `EGNYTE_USERNAME`, `EGNYTE_PASSWORD`

- Interactive prompt (if running interactively and not provided)

**Note:** This flow does not return a refresh token. When the access
token expires (after 30 days), you'll need to authenticate again.

## See also

[`eg_oauth_app()`](https://username.github.io/egfiles/reference/eg_oauth_app.md)
to configure the OAuth application first.

## Examples

``` r
if (FALSE) { # \dontrun{
# Set up your OAuth app first
eg_oauth_app("mycompany", "client_id", "client_secret")

# Authenticate with username/password
eg_oauth_password("myuser", "mypassword")

# Or use environment variables
Sys.setenv(EGNYTE_USERNAME = "myuser", EGNYTE_PASSWORD = "mypassword")
eg_oauth_password()

# Now you can use eg_read() and eg_write()
eg_read("/Shared/Documents/file.txt", "local.txt")
} # }
```
