source("Library/init.R")
db_connect <- import("Library/database/db_connect.R")
connections <- db_connect("lazk", preset = "postgres_development_server")
connections$query("SELECT column_name, column_default FROM information_schema.columns WHERE (table_schema, table_name) = ('public', 'specialization_type')")
# connections$query("SELECT * FROM specialization")

#specialization: 3199
connections$query("SELECT MAX(id_specialization) FROM specialization")

# connections$query("CREATE SEQUENCE specialization_id_specialization_seq START 3200;")
connections$query("ALTER SEQUENCE specialization_id_specialization_seq RESTART WITH 3200;")
connections$query("ALTER TABLE specialization ALTER COLUMN id_specialization SET DEFAULT nextval('specialization_id_specialization_seq'::regclass);")

#specialization_type: 430
connections$query("SELECT MAX(id_specialization_type) FROM specialization_type")

# connections$query("CREATE SEQUENCE specialization_type_id_specialization_type_seq START 431;")
connections$query("ALTER SEQUENCE specialization_type_id_specialization_type_seq RESTART WITH 431;")
connections$query("ALTER TABLE specialization_type ALTER COLUMN id_specialization_type SET DEFAULT nextval('specialization_type_id_specialization_type_seq'::regclass)")

#hospital: 665
connections$query("SELECT MAX(id_hospital) FROM hospital")

# connections$query("CREATE SEQUENCE hospital_id_hospital_seq START 666;")
connections$query("ALTER SEQUENCE hospital_id_hospital_seq RESTART WITH 666;")
connections$query("ALTER TABLE hospital ALTER COLUMN id_hospital SET DEFAULT nextval('hospital_id_hospital_seq'::regclass)")

#provider: 23494
connections$query("SELECT MAX(id_provider) FROM provider")

# connections$query("CREATE SEQUENCE provider_id_provider_seq START 23495;")
connections$query("ALTER SEQUENCE provider_id_provider_seq RESTART WITH 23495;")
connections$query("ALTER TABLE provider ALTER COLUMN id_provider SET DEFAULT nextval('provider_id_provider_seq'::regclass)")


connections$disconnect()
