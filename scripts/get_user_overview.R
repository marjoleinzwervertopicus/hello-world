... <- (function() {
  source("Library/init.R")
  database <- import("Library/database/database.R")
  ldapr <- import("Library/utilities/ldap.R")$create()
  
  list(
    get_user_overview = function() {
      client_names <- c("rav_drenthe", "rav_fryslan", "rav_ijsselland", "rav_limburg_noord", "rav_limburg_zuid", "mk_limburg", "mknn", "upload", "mmt_umcg", "kwaliteitskaderapp", "lazk", "jb_lorenz")
      
      user_emails <- tibble(emails = character(0), clients = character(0))
      for(client in client_names) {
        connections <- database$get_connections(client)
        user_info <- connections$customer$get("SELECT email FROM user_info")$email
        
        emails <- tibble(emails = user_info, clients = client)
        user_emails <- rbind(user_emails, emails)
      }
      
      user_emails <- user_emails %>% group_by(emails) %>% 
        pivot_wider(names_from = clients, values_from = "clients") %>%  
        unite(col = clients, all_of(client_names), na.rm = TRUE, sep = ", ") %>%
        select(emails, clients)
      
      # user_emails$in_ldap <- map_lgl(user_emails$emails, ~!is_empty(ldapr$get_users_by_email(.)))
      
      user_emails
    },
  
    get_user_rights = function(client, remove_devise = FALSE) {
      connections <- database$get_connections(client)
      
      user_info <- connections$customer$get("SELECT user_id, email FROM user_info")
      insight_groups <- connections$customer$get("select u.user_group_id, i.type, i.name from user_group_insight u left join insight i on u.insight_id = i.insight_id order by u.user_group_id desc")
      insight_groups <- insight_groups[insight_groups$type != "Berekening", ]
      user_groups <- connections$customer$get("select uug.user_id, ug.user_group_id from user_user_group uug left join user_group ug on uug.user_group_id = ug.user_group_id order by user_user_group_id desc")
      
      user_dashboard <- left_join(user_groups, insight_groups) %>% select(-user_group_id)
      user_info <- left_join(user_info, user_dashboard) %>% select(-user_id, -type)
      
      dashboard_names <- unique(user_info$name)
      dashboard_names <- dashboard_names[!is.na(dashboard_names)]
      
      user_dashboards <- user_info[!duplicated(user_info), ] %>% group_by(email) %>%
        pivot_wider(names_from = name, values_from = "name") %>%  
        unite(col = name, all_of(dashboard_names), na.rm = TRUE, sep = ", ") %>%
        select(email, name)
      
      # write.csv(user_dashboards, paste0("Gebruikers rechten ", client, ".csv"), row.names = FALSE)
      
      user_dashboards
    }
  )
})()


