library(testthat)
setwd("~/RStudio/Platform")
source("Library/init.R")
db <- import("Library/database/db.R")
db_con <- db("marjolein", host = "postgres_development_server")$connection

setup_tables <- function() {
  db_con$set("DROP TABLE test_no_json")
  db_con$set("CREATE TABLE test_no_json (json_bool bool, json_char character varying, urgentie character varying)")
  db_con$set(paste0("INSERT INTO test_no_json (json_bool, json_char, urgentie) VALUES (true, 'test', 'A1')"))
  
  db_con$set("DROP TABLE test_json")
  db_con$set("CREATE TABLE test_json (json_bool jsonb, json_char jsonb, urgentie character varying)")
  db_con$set(paste0("INSERT INTO test_json (json_bool, json_char, urgentie) VALUES ('", jsonlite::toJSON(c(TRUE, FALSE, TRUE)), "', '", jsonlite::toJSON(c("a", "b", "c")), "', 'A1')"))
}

test_json_dataset <- tibble(json_bool = list(c(T, F, T), c(F, F, T)), json_char = list(c("a", "b", "c"), c("d", "b", "a")), urgentie = c("A1", "A2"))
test_no_json_dataset <- tibble(json_bool = c(T, F), json_char = c("a", "b"), urgentie = c("A1", "A2"))

#db tables are not actually changed, so this only had to be done once
setup_tables()

#table column == json, new column == json
original_result <- db_con$insert_table_unsafe_old(table_name = "test_json", table = test_json_dataset)
new_result <- db_con$insert_table_unsafe(table_name = "test_json", table = test_json_dataset)
testthat::expect_equal(original_result, new_result)

#table column = json, new column != json 
original_result <- db_con$insert_table_unsafe_old(table_name = "test_json", table = test_no_json_dataset)
new_result <- db_con$insert_table_unsafe(table_name = "test_json", table = test_no_json_dataset)
testthat::expect_equal(original_result, new_result)

#table column != and new column == json
original_result <- testthat::expect_warning(db_con$insert_table_unsafe_old(table_name = "test_no_json", table = test_json_dataset), regexp = "Column .* was not jsonb but is still parsed as json")
new_result <- testthat::expect_warning(db_con$insert_table_unsafe(table_name = "test_no_json", table = test_json_dataset), regexp = "Columns .* were not jsonb but are still parsed as json")
testthat::expect_equal(original_result, new_result)

#table column != and new column != json
original_result <- db_con$insert_table_unsafe_old(table_name = "test_no_json", table = test_no_json_dataset)
new_result <- db_con$insert_table_unsafe(table_name = "test_no_json", table = test_no_json_dataset)
testthat::expect_equal(original_result, new_result)
