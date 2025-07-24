source("Library/init.R")
db_connect <- import("Library/database/db_connect.R")

# db_source <- db_connect("mknn", preset = "postgres_application_server")
db_dev_drenthe <- db_connect("rav_drenthe", preset = "postgres_development_server")
db_dev_ijsselland <- db_connect("rav_ijsselland", preset = "postgres_development_server")
db_dev_hollands_midden <- db_connect("rav_hollands_midden", preset = "postgres_development_server")
db_prod_hollands_midden <- db_connect("rav_hollands_midden", preset = "postgres_application_server")
db_prod_ijsselland <- db_connect("rav_ijsselland", preset = "postgres_application_server")


db_prod_ijsselland$query("UPDATE scenario SET type = 'concept' WHERE scenario_id = 1")

db_dev_drenthe$info$columns("scenario")
db_dev_drenthe$query("select column_name, data_type from information_schema.columns WHERE table_name = 'scenario'")


db_dev_hollands_midden$table("resource") |>
  db_prod_hollands_midden$write("resource", overwrite = T)


db_dev_ijsselland$table("resource") |>
  db_prod_ijsselland$write("resource", overwrite = T)

db_prod_ijsselland$table("scenario")


db_dev_hollands_midden$query("TRUNCATE TABLE scenario")
db_dev_hollands_midden$query("TRUNCATE TABLE resource")

db_prod_ijsselland$table("scenario")

db_dev_hollands_midden$query("UPDATE scenario SET type = 'concept' WHERE scenario_id = 1")


# db_prod_ijsselland <- db_connect("rav_ijsselland", preset = "postgres_application_server")
# 
# db_prod_ijsselland$query("SELECT * FROM resource")

db_dev_drenthe$query("SELECT * FROM resource")



db_dev_ijsselland
db_prod_hollands_midden$query("ALTER TABLE scenario ALTER COLUMN deleted SET DEFAULT false;")
db_prod_hollands_midden$query("ALTER TABLE scenario ALTER COLUMN ts SET DEFAULT CURRENT_TIMESTAMP;")

db_prod_hollands_midden$query("CREATE SEQUENCE scenario_scenario_id_seq START 10;")
db_prod_hollands_midden$query("ALTER TABLE scenario ALTER COLUMN scenario_id SET DEFAULT nextval('scenario_scenario_id_seq'::regclass);")

# db_prod_ijsselland$table("resource")


CURRENT_TIMESTAMP
