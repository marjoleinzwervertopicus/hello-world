source("Library/init.R")
database <- import("Library/database/database.R")
conn <- database$get_connections("etl.proigia")
result <- conn$etl.proigia$get("SELECT * FROM telefonie_op_uurbasis")



a <- conn$etl.proigia$get("SELECT * FROM weerdata_per_dag")
saveRDS(a, "/home/shared/data/clients/proigia/raw_data/weerdata_per_dag.rds")


result %>% filter(datum_tijd > as.POSIXct("2017-03-26")) %>% View()

result_test <- result %>%
  mutate(datum_uur_1 = as.numeric(format(datum_tijd, "%H"))) %>%
  mutate(datum_uur_2 = as.numeric(format(strptime(tijd,"%H:%M:%S"),'%H')))
  



a <- conn$etl.proigia$get("SELECT * FROM weerdata_per_dag")


# saveRDS(result, paste0("/home/shared/data/clients/proigia/raw_data/", table_name, ".rds"))


#save all
source("Library/init.R")
database <- import("Library/database/database.R")



conn <- database$get_connections("etl.proigia")



table_names <- c("telefonie_op_dagbasis",
                 "telefonie_op_kwartierbasis",
                 "telefonie_op_uurbasis",
                 "weercode",
                 "weerdata_per_dag",
                 "weerdata_per_uur",
                 "telefonie_historie",
                 "telefonie_gehashed",
                 "telefonie_actueel")



for(table_name in table_names) {
  result <- conn$etl.proigia$get(paste0("SELECT * FROM ", table_name))
  saveRDS(result, paste0("/home/shared/data/clients/proigia/raw_data/", table_name, ".rds"))
}

