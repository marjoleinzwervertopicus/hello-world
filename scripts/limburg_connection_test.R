source("Library/init.R")
library(httr2)
source("Library/modules/edazng/utils/get_token.R")
secrets <- import("Library/utilities/secrets.R")

# Get token
token <- get_token_prod(
  edaz_url = "https://p-lmb.edazng.nl",
  entra_tenant_id = secrets$get("edazng_entra_tenant_id", "rav_limburg"),
  entra_client_id = secrets$get("edazng_entra_client_id", "rav_limburg"),
  entra_client_secret = secrets$get("edazng_entra_client_secret", "rav_limburg"),
  entra_scope = secrets$get("edazng_entra_scope", "rav_limburg")
)
