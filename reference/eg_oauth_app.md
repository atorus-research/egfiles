# Set Up OAuth Application Credentials

Configures the OAuth 2.0 application credentials for Egnyte
authentication. These credentials are obtained by registering your
application at <https://developers.egnyte.com>.

## Usage

``` r
eg_oauth_app(
  domain,
  client_id,
  client_secret,
  redirect_uri = "https://localhost/callback"
)
```

## Arguments

- domain:

  Your Egnyte domain (the subdomain of yourcompany.egnyte.com).

- client_id:

  The API key (client ID) from your registered application.

- client_secret:

  The client secret from your registered application.

- redirect_uri:

  The redirect URI configured for your app in the Egnyte developer
  portal. Must be HTTPS. Defaults to `https://localhost/callback`.

## Value

Invisibly returns a list with the OAuth app configuration.

## Details

After registering at <https://developers.egnyte.com>, you will receive a
client_id and client_secret. Your application must be approved by Egnyte
before it becomes active.

**Important:** You must configure the same redirect_uri in your Egnyte
app settings. Egnyte requires all redirect URIs to be HTTPS.

During development, your API key only works with your registered Egnyte
domain. After certification, it works with all Egnyte domains.

## See also

[`eg_oauth_authorize()`](https://username.github.io/egfiles/reference/eg_oauth_authorize.md)
to complete the OAuth flow.

## Examples

``` r
if (FALSE) { # \dontrun{
eg_oauth_app(
  domain = "mycompany",
  client_id = "your_client_id",
  client_secret = "your_client_secret",
  redirect_uri = "https://your-registered-redirect.com/callback"
)
} # }
```
