source("Library/init.R")
# deploy <- import("Library/deployment/deploy.R")
# deploy$insight("clients/mk_limburg/kpi_report/deploy_script.R")

database <- import("Library/database/database.R")
connections <- database$get_connections("mk_limburg")
users <- connections$mk_limburg$get("select email, u.name from insight i left join user_group_insight ugi on i.insight_id = ugi.insight_id left join user_group ug on ugi.user_group_id = ug.user_group_id left join user_user_group uug on ug.user_group_id = uug.user_group_id left join user_info u on uug.user_id = u.user_id  where i.type = 'Dashboard' and i.name = 'Meldtijden centralist'")

connections$mk_limburg$get("SELECT * FROM insight")




insight_configs <- import("Library/utilities/insight_config.R")
dispatcher_config <- yaml::read_yaml("insights/dispatcher/dispatcher.yml")
user_emails <- insight_configs$get_users_in_groups(dispatcher_config$shared_user_groups)
if(!is.na(dispatcher_config$shared_user_emails)) {
  user_emails <- unique(c(user_emails, dispatcher_config$shared_user_emails))
}
user_names <- map_chr(user_emails, ~insight_configs$get_user(.)$name)
users <- tibble(email = user_emails, name = user_names)



insight_configs$get_user()

setequal(users$email, yaml_user_emails)
