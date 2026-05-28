source("Library/init.R")
db_connect <- import("Library/database/db_connect.R")
echo <- F

remove_all_rights <- function(host, database_names, schema = "public", users) {
  for(database in database_names) {
    con <- db_connect(database, host = host, as_pool = F)
    for(user in users) {
      con$query(paste0("REVOKE ALL ON ALL TABLES IN SCHEMA ", schema, " FROM \"", user, "\""), get = F, echo = echo)
      con$query(paste0("REVOKE ALL ON ALL SEQUENCES IN SCHEMA ", schema, " FROM \"", user, "\""), get = F, echo = echo)
      con$query(paste0("REVOKE ALL ON SCHEMA ", schema, " FROM \"", user, "\""), get = FALSE)
    }
    con$disconnect()
  }
  
}

#copied code from set_database_privileges.R
set_postgres_grants <- function(host, database_names, schema = "public", tables = NULL, users, read = TRUE, write = FALSE, with_fix = FALSE) {
  for(database in database_names) {
    con <- db_connect(database, host = host, as_pool = F)
    
    has_access_lock <- con$query(paste0(
      "SELECT COUNT(*) FROM pg_locks
                JOIN pg_stat_activity ON pg_locks.pid = pg_stat_activity.pid
                JOIN pg_database ON pg_locks.database = pg_database.oid
              WHERE pg_database.datname = '", database, "'
                AND pg_locks.mode IN ('AccessExclusiveLock')
                AND pg_stat_activity.state != 'idle'"
    ), echo = FALSE)$count > 0
    
    if(has_access_lock) {
      warning(
        "set_postgres_grants skipped for database ", database,
        " because there is an AccessExclusiveLock on a table in the database.")
      next
    }
    
    tryCatch({
      active_queries <- con$query("SELECT state, query FROM pg_stat_activity WHERE state = 'active'", echo = F)
      
      for(user in users) {
        con$query(paste0("GRANT CONNECT ON DATABASE ", database, " TO \"", user, "\""), get = F, echo = echo)
        
        if(read) {
          if(is.null(tables)) {
            if(!with_fix) {
              con$query(paste0("GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA ", schema, " TO \"", user, "\""), get = F, echo = echo)
              con$query(paste0("GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA ", schema, " TO \"", user, "\""), get = F, echo = echo)
            }
            con$query(paste0("GRANT USAGE ON SCHEMA ", schema, " TO \"", user, "\""), get = F, echo = echo)
            con$query(paste0("GRANT USAGE ON ALL SEQUENCES IN SCHEMA ", schema, " TO \"", user, "\""), get = F, echo = echo)
            con$query(paste0("GRANT SELECT ON ALL TABLES IN SCHEMA ", schema, " TO \"", user, "\""), get = F, echo = echo)
          } else {
            for(table in tables) {
              con$query(paste0("GRANT SELECT ON ", table, " TO \"", user, "\""), get = F, echo = echo)
            }
          }
        }
        
        if(write) {
          if(!read) stop("Also need read privileges to write")
          con$query(paste0("GRANT UPDATE ON ALL TABLES IN SCHEMA ", schema, " TO \"", user, "\""), get = F, echo = echo)
          con$query(paste0("GRANT INSERT ON ALL TABLES IN SCHEMA ", schema, " TO \"", user, "\""), get = F, echo = echo)
          con$query(paste0("GRANT DELETE ON ALL TABLES IN SCHEMA ", schema, " TO \"", user, "\""), get = F, echo = echo)
        }
      }
    }, error = function(e) {
      #TODO: remove after error is fixed
      message(
        "Error: ", e$message, "\n",
        "active queries at moment of issue:\n",
        paste0(active_queries$query, collapse = "\n")
      )
    })
    
    con$disconnect()
  }
}
#end copy


#start test (master, without fix)
#use superuser to grant/revoke rights
Sys.setenv("DEVISE_DB_USER" = "postgres")
remove_all_rights("postgres_development_server", "rav_drenthe", users = "marieke@devise.nl")
set_postgres_grants("postgres_development_server", "rav_drenthe", read = TRUE, write = FALSE, users = "marieke@devise.nl", with_fix = FALSE)

connections <- db_connect("rav_drenthe", preset = "postgres_development_server")
connections$query("CREATE TABLE cars (
  brand VARCHAR(255),
  model VARCHAR(255),
  year INT
);")
connections$query("INSERT INTO cars (brand, model, year) VALUES ('Ford', 'Mustang', 1964);")

#set user to the one whose rights we just set
Sys.setenv("DEVISE_DB_USER" = "marieke@devise.nl")


connections <- db_connect("rav_drenthe", preset = "postgres_development_server")
#this works but it shouldn't
connections$query("DELETE FROM cars;")


#test with fix
Sys.setenv("DEVISE_DB_USER" = "postgres")
remove_all_rights("postgres_development_server", "rav_drenthe", users = "marieke@devise.nl")
set_postgres_grants("postgres_development_server", "rav_drenthe", read = TRUE, write = FALSE, users = "marieke@devise.nl", with_fix = TRUE)

connections <- db_connect("rav_drenthe", preset = "postgres_development_server")
#add row again
connections$query("INSERT INTO cars (brand, model, year) VALUES ('Ford', 'Mustang', 1964);")


#set user to the one whose rights we just set
Sys.setenv("DEVISE_DB_USER" = "marieke@devise.nl")
connections <- db_connect("rav_drenthe", preset = "postgres_development_server")

#ERROR: permission denied for relation cars
connections$query("DELETE FROM cars;")

# ERROR:  must be owner of relation cars
connections$query("DROP TABLE cars")