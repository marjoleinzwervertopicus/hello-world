# dirs <- list.files(paste0("/srv/shiny-server/upload/uploaded/"), full.names = T)
# sum(purrr::map_lgl(dirs, ~length(list.files(.)) == 0))



get_uploaded_file_amount <- function(user_email) {
  files <- list.files(paste0("/srv/shiny-server/upload/uploaded/", user_email))
  warning(user_email)
  warning(files)
  if(length(files) != 0 && any(grepl("A1", files))) browser()
  length(files)
}


# get_uploaded_file_amount("renco@meetdevise.com")
# get_uploaded_file_amount("marjolein@deviseanalytics.com")



users <- c(
  "w.dgraaf@mijnantonius.nl",
  "miranda.de.boer@tjongerschans.nl",
  "m.haak@dokterdrenthe.nl",
  "ytzen.westra@mcl.nl",
  "bianca.blaeser@mcl.nl",
  "Philip.Grundmeijer@ambulancezorggroningen.nl",
  "erik@hapdashboard.nl", #nu 8, meer dan 8 is nieuwe uploads
  "t.j.hoogstins@umcg.nl", "i.a.van.der.weide@umcg.nl",
  "folkert.schootstra@dokterswacht.nl",
  "i.meinders@nijsmellinghe.nl",
  "j.drupsteen@mzh.nl",
  "h.steenhuis@treant.nl",
  "karin.ploeger@wza.nl",
  "s.goldberg@ozg.nl"
  )

lapply(users, function(email) get_uploaded_file_amount(email)) %>% setNames(users)
