library(httr)

access_token <- content(POST(
  url = "https://login.devise.cloud/realms/master/protocol/openid-connect/token",
  body = list(
    username = "admin",
    password = "admin",
    grant_type = "password",
    client_id = "admin-cli"
  ),
  encode="form"
))$access_token


user_count <- content(GET(
  url = "https://login.devise.cloud/admin/realms/Devise/users/count",
  add_headers(
    `Content-Type` = "application/json",
    Authorization = paste0("bearer ", access_token)
  )
))
