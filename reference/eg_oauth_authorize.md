# Authorize with Egnyte via OAuth 2.0

Initiates the OAuth 2.0 Authorization Code flow. This opens a browser
window for the user to log in and authorize the application, then
prompts for the authorization code to exchange for access tokens.

## Usage

``` r
eg_oauth_authorize(scope = "Egnyte.filesystem")
```

## Arguments

- scope:

  Character vector of OAuth scopes to request. Defaults to
  `"Egnyte.filesystem"` for file operations. Other scopes include
  `"Egnyte.link"`, `"Egnyte.user"`, and `"Egnyte.projectfolders"`.

## Value

Invisibly returns a list containing `access_token`, `refresh_token`,
`token_type`, and `expires_in`.

## Details

The OAuth flow:

1.  Opens a browser to Egnyte's authorization page

2.  User logs in (via SSO if configured) and approves access

3.  Egnyte redirects to your configured redirect_uri with `?code=...`

4.  Copy the code from the URL and paste it when prompted

5.  The code is exchanged for access and refresh tokens

**Note:** Egnyte requires HTTPS redirect URIs. After authorization,
you'll be redirected to your configured URI. Copy the `code` parameter
from the URL (everything after `code=` and before any `&`).

Access tokens expire after 30 days. Use
[`eg_oauth_refresh()`](https://atorus-research.github.io/egnyte/reference/eg_oauth_refresh.md)
to obtain a new token using the refresh token.

## See also

[`eg_oauth_app()`](https://atorus-research.github.io/egnyte/reference/eg_oauth_app.md)
to configure the OAuth application first.

## Examples

``` r
if (FALSE) { # \dontrun{
# First set up your OAuth app
eg_oauth_app("mycompany", "client_id", "client_secret",
             redirect_uri = "https://your-app.com/callback")

# Then authorize (opens browser, prompts for code)
eg_oauth_authorize()

# Now you can use eg_read() and eg_write()
eg_read("/Shared/Documents/file.txt", "local.txt")
} # }
```
