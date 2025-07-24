source("Library/init.R")

geocode <- import("Library/geography/geocode.R")
geography <- import("Library/calculate/geography.R")$create()


geocode$single(zipcode_housenumber = "4003BS 2", bag_table_name = "bag_adres")

geocode$single(zipcode_housenumber = "4003BS 2", bag_table_name = "bag_adres_feb_25")

#bag_adres_mei_23
geocode$single(zipcode_housenumber = "4003BS 2")

#bag_adres
geography$geocode(zipcode_housenumber = "4003BS 2")
