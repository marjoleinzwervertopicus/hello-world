#From a docker container running RStudio, I run this

source("Library/init.R")
library(httr2)
secrets <- import("Library/utilities/secrets.R")

edaz_url = "https://p-dre.edazng.nl"

  entra_tenant_id = secrets$get("edazng_entra_tenant_id", "rav_drenthe")
  entra_client_id = secrets$get("edazng_entra_client_id", "rav_drenthe")
  entra_client_secret = secrets$get("edazng_entra_client_secret", "rav_drenthe")
  entra_scope = secrets$get("edazng_entra_scope", "rav_drenthe")
  
  
  entra_url <- paste0("https://login.microsoftonline.com/", entra_tenant_id, "/oauth2/v2.0/token")
  token_entra <- request(entra_url) |>
    req_body_form(
      grant_type = "client_credentials",
      client_id = entra_client_id,
      client_secret = entra_client_secret,
      scope = entra_scope
    ) |>
    req_perform() |>
    resp_body_json()
  
  # edaz_url = "https://p-dre.edazng.nl"
  token <- request(edaz_url) |>
    req_proxy("socks5h://edazng_socks:1080") |>
    req_url_path("api/entra/loginm2m") |>
    req_auth_bearer_token(token_entra$access_token) |>
    req_body_json(
      list(
        clientid = "devise",
        scope = "edazng-database-api"
      )
    ) |>
    req_perform() |>
    resp_body_json()
  