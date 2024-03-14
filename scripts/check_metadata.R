collect_metadata <- function() {
  drilldown_metadata <- import("Library/utilities/metadata.R")
  clients <- c("rav_drenthe", "rav_fryslan", "rav_ijsselland", "rav_limburg_noord", "rav_limburg_zuid", "mk_limburg")
  
  all_client_metadata <- tibble()
  for(client in clients) {
    client_metadata <- drilldown_metadata$get_variables(client)
    client_metadata$client <- client
    all_client_metadata <- rbind(all_client_metadata, client_metadata)
  }
  
  write.csv(all_client_metadata, "all_client_metadata.csv")
}


all_client_metadata <- read.csv("/home/shared/data/clients/all_client_metadata.csv")

check_metadata <- function(column_name) {
  all_client_metadata %>% filter(name == column_name) %>% select(name, label, description, table_name, client, calculation)
}

check_metadata("task_type")
