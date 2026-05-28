Sys.setenv("DEVISE_DB_USER" = "postgres")

source("Library/init.R")
db_connect <- import("Library/database/db_connect.R")
connections <- db_connect("mknn", preset = "postgres_etl_server")
# a <- connections$query("SELECT v_a_arc_inzet_kar_id_new, v_a_arc_inzet_kar_id FROM v_a_arc_inzet_kar")
# a <- connections$query("SELECT v_a_arc_inzet_kar_id_old, v_a_arc_inzet_kar_id FROM v_a_arc_inzet_kar")

# connections$query("UPDATE v_a_arc_inzet_kar SET v_a_arc_inzet_kar_id = v_a_arc_inzet_kar_id_new")
# a <- connections$query("SELECT * FROM information_schema.columns WHERE table_name = 'v_a_arc_inzet_kar'")

# a <- connections$query("SELECT * FROM information_schema.table_constraints WHERE table_name='v_a_arc_inzet_kar'")

# connections$query("ALTER TABLE v_a_arc_inzet_kar DROP CONSTRAINT v_a_arc_inzet_kar_pkey")
# 
# connections$query("ALTER TABLE v_a_arc_inzet_kar ADD PRIMARY KEY (v_a_arc_inzet_kar_id)")
# a <- connections$query("SELECT * FROM information_schema.constraint_column_usage  WHERE table_name='v_a_arc_inzet_kar'")
a <- connections$query("SELECT * FROM information_schema.table_constraints  WHERE table_name='v_a_arc_inzet_kar'")

# connections$query("ALTER TABLE v_a_arc_inzet_kar ADD COLUMN v_a_arc_inzet_kar_id_new integer")
# connections$query("ALTER TABLE v_a_arc_inzet_kar ALTER COLUMN v_a_arc_inzet_kar_id_new SET DEFAULT nextval('v_a_arc_inzet_kar_v_a_arc_inzet_kar_id_seq'::regclass)")

# connections$query("ALTER TABLE v_a_arc_inzet_kar RENAME COLUMN v_a_arc_inzet_kar_id TO v_a_arc_inzet_kar_id_old")
# connections$query("ALTER TABLE v_a_arc_inzet_kar RENAME COLUMN v_a_arc_inzet_kar_id_new TO v_a_arc_inzet_kar_id")

# connections$query("ALTER TABLE v_a_arc_inzet_kar RENAME COLUMN v_a_arc_inzet_kar_id TO v_a_arc_inzet_kar_id_new")
# connections$query("ALTER TABLE v_a_arc_inzet_kar RENAME COLUMN v_a_arc_inzet_kar_id_old TO v_a_arc_inzet_kar_id")

# connections$query("ALTER SEQUENCE v_a_arc_inzet_kar_v_a_arc_inzet_kar_id_seq RESTART WITH 1; ")
# connections$query("UPDATE v_a_arc_inzet_kar SET v_a_arc_inzet_kar_id_new=nextval('v_a_arc_inzet_kar_v_a_arc_inzet_kar_id_seq');")

connections$disconnect()
