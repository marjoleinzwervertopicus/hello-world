geocode <- import("Library/geography/geocode.R")


geocode$single(zipcode = "3439LE", bag_table_name = "bag_adres_mei_23")
geocode$single(zipcode_housenumber = "3439LE 3", bag_table_name = "bag_adres_mei_23")

geocode$single(zipcode = "3439LE", bag_table_name = "bag_adres_feb_25")
FROM bag_adres_feb_25 WHERE postcode = '3439LE' LIMIT 10000

geocode$single(zipcode_housenumber = "3439LE 3", bag_table_name = "bag_adres_feb_25") # hier komen geen resultaten uit?
FROM bag_adres_feb_25 WHERE postcode = '3439LE' AND huisnummer = '3' AND huisletter IS NULL LIMIT 10000)


connection <- import("Library/database/db.R")("geography")$connection
connection$get("SELECT * FROM bag_adres_mei_23 WHERE postcode = '3439LE' AND huisnummer = '3' AND huisletter IS NULL LIMIT 10000")
connection$get("SELECT * FROM bag_adres_feb_25 WHERE postcode = '3439LE' AND huisnummer = '3' LIMIT 10000")



huisletter_23 <- connection$get("SELECT huisletter FROM bag_adres_mei_23")
huisletter_25 <- connection$get("SELECT huisletter FROM bag_adres_feb_25")

colnames_23 <- colnames(connection$get("SELECT * FROM bag_adres_mei_23 LIMIT 1"))
colnames_25 <- colnames(connection$get("SELECT * FROM bag_adres_feb_25 LIMIT 1"))
identical(colnames_23, colnames_25)

setdiff(colnames_23, colnames_25)
setdiff(colnames_25, colnames_23)


connection$get("SELECT COUNT(*) FROM bag_adres_feb_25 WHERE huisletter IS NULL")
connection$get("SELECT COUNT(*) FROM bag_adres_mei_23 WHERE huisletter = ''")


a <-connection$get("SELECT * FROM bag_adres_feb_25 WHERE huisletter = '' LIMIT 1")
b <-connection$get("SELECT * FROM bag_adres_mei_23 WHERE huisletter IS NULL LIMIT 1")

connection$get("SELECT COUNT(*) FROM bag_adres_mei_23 WHERE huisnummertoevoeging IS NULL")
connection$get("SELECT COUNT(*) FROM bag_adres_feb_25 WHERE huisnummertoevoeging IS NULL")
connection$get("SELECT COUNT(*) FROM bag_adres_feb_25 WHERE huisnummertoevoeging = ''")

f <- connection$get("SELECT huisnummertoevoeging FROM bag_adres_feb_25")


huisletter_23 |> filter(is.na(huisletter) | huisletter == "") |> group_by(huisletter) |> summarize(n = n())
huisletter_25 |> filter(is.na(huisletter) | huisletter == "") |> group_by(huisletter) |> summarize(n = n())

files <- source("Library/utilities/files.R")$value

bag_file_23 <- "/home/shared/data/geography/bag/bagadres-woning.csv"
bag_23 <- data.table::fread(bag_file_23)
bag_23 |> filter(is.na(huisletter) | huisletter == "") |> group_by(huisletter) |> summarize(n = n())

bag_file_25 <- "/home/shared/data/geography/bag/21-feb-2025/bagadres-woning.csv"
bag_25 <- data.table::fread(bag_file_25)
bag_25 |> filter(is.na(huisletter) | huisletter == "") |> group_by(huisletter) |> summarize(n = n())

bag_25_test <- data.table::fread(bag_file_25, na.strings = "")
bag_25_test |> filter(is.na(huisletter) | huisletter == "") |> group_by(huisletter) |> summarize(n = n())


table_differences <- get_table_differences(list(list("bag_adres_mei_23" = "geography bag_adres_mei_23", "bag_adres_feb_25" = "geography bag_adres_feb_25")), skip_columns = character(0), current_host = "application", new_host = "application")

table_differences_na <- get_table_differences(list(list("bag_25_test" = bag_25_test, "bag_25" = bag_25)), skip_columns = character(0))






