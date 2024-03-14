# reports <- source("Library/utilities/reports.R")$value
# 
# a <- reports$render("clients/rav_drenthe/dashboards/medewerker_rmd/dashboard.Rmd",
#                     params = list(nurse_code = "3543",
#                                   client = "rav_drenthe"))


source("deploy/init.R")

deploy_for_user <- function(nurse_code, email, client) {
  render("clients/rav_drenthe/dashboards/medewerker_rmd/dashboard.Rmd",
         params = list(nurse_code = nurse_code,
                       client = client)) |>
    deploy(client = "rav_drenthe", 
           insight_name = paste0("medewerker_dashboard_", nurse_code), 
           name = paste0("Dashboard ritregistratie (", nurse_code, ")"),
           tile_category = "Dashboards", 
           icon = "user-nurse",
           shared_user_groups = paste0("Persoonlijk dashboard ", nurse_code, " ", email))
}  

# All dashboards are deployed to rav_drenthe  

deploy_for_user("3543", "j.hadderingh@rav.nl", "rav_fryslan")
