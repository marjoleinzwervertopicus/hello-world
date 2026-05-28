source("Library/init.R")
db_connect <- import("Library/database/db_connect.R")
dev_connection <- db_connect("lazk", preset = "postgres_development_server")
dev_connection$query("SELECT * FROM specialization_type")

#changes types
dev_connection$query("UPDATE specialization_type SET name = 'PICU' WHERE name = 'Kinder-IC'", get = FALSE)
dev_connection$query("UPDATE specialization_type SET name = 'NICU' WHERE name = 'Perinatologisch centrum'", get = FALSE)
dev_connection$query("UPDATE specialization_type SET name = 'CVA' WHERE name = 'Profiel CVA'", get = FALSE)
dev_connection$query("UPDATE specialization_type SET name = '(Verdenking) RAAA' WHERE name = 'Profiel (r)AAA'", get = FALSE)
dev_connection$query("UPDATE specialization_type SET name = 'AMI' WHERE name = 'Profiel AMI'", get = FALSE)
dev_connection$query("UPDATE specialization_type SET name = 'ECMO' WHERE name = 'Ecmo'", get = FALSE)
dev_connection$query("UPDATE specialization_type SET name = 'Level-1 traumazorg' WHERE name = 'Traumacentrum'", get = FALSE)

#new types
dev_connection$query("INSERT INTO specialization_type (name) VALUES ('Interventie/ clippen SAB')", get = FALSE)
dev_connection$query("INSERT INTO specialization_type (name) VALUES ('Neurotrauma (neurochirurgie)')", get = FALSE)
dev_connection$query("INSERT INTO specialization_type (name) VALUES ('(Verdenking) SAB')", get = FALSE)
dev_connection$query("INSERT INTO specialization_type (name) VALUES ('PCI Centrum')", get = FALSE)
dev_connection$query("INSERT INTO specialization_type (name) VALUES ('EHH')", get = FALSE)
dev_connection$query("INSERT INTO specialization_type (name) VALUES ('EHLH')", get = FALSE)
dev_connection$query("INSERT INTO specialization_type (name) VALUES ('Acute psychiatrie')", get = FALSE)

#deleted types
dev_connection$query("DELETE FROM specialization_type WHERE name = 'Profiel gedrag'", get = FALSE)
dev_connection$query("DELETE FROM specialization_type WHERE name = 'CBRN-centra'", get = FALSE)
dev_connection$query("DELETE FROM specialization_type WHERE name = 'Barotrauma'", get = FALSE)
dev_connection$query("DELETE FROM specialization_type WHERE name = 'Neurochirurgie'", get = FALSE)
