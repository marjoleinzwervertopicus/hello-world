files <- source("Library/utilities/files.R")$value

#csv
#tz changes but time doesn't change with it
tibble_cet <- tibble(datetime = Sys.time())
files$write_csv(tibble_cet, "~/RStudio/hello-world/test_write.csv")
test_read_csv_utc <- files$load_file("~/RStudio/hello-world/test_write.csv", all_characters = FALSE)
tibble_cet$datetime
test_read_csv_utc$datetime

#when reading with tz, the read value is the same as the write value
test_read_csv_cet <- files$load_file("~/RStudio/hello-world/test_write.csv", all_characters = FALSE, tz = "Europe/Amsterdam")
test_read_csv_cet$datetime


#xlsx: when writing, time is written as UTC
tibble_cet <- tibble(datetime = Sys.time())
tibble_utc <- tibble(datetime = as.POSIXct(Sys.time(), tz = "UTC"))
files$write_xlsx(tibble_cet, "~/RStudio/hello-world/test_write_cet.xlsx")
files$write_xlsx(tibble_utc, "~/RStudio/hello-world/test_write_utc.xlsx")

#when reading, time is interpreted as UTC. Make sure that when time is written, it is UTC. Then transform after reading if needed
test_read_xlsx_cet <- files$load_file("~/RStudio/hello-world/test_write_cet.xlsx", all_characters = FALSE)
test_read_xlsx_cet$datetime
test_read_xlsx_utc <- files$load_file("~/RStudio/hello-world/test_write_utc.xlsx", all_characters = FALSE)
test_read_xlsx_utc$datetime


#special characters
tibble_speciale_karakters <- tibble(speciale_karakters = c("Fryslân", "patiënt", "?"))

#latin1
#gets written as latin1
files$write_csv(tibble_speciale_karakters, "~/RStudio/hello-world/test_characters.csv")

#result is correct
test_read_special_characters <- files$load_file("~/RStudio/hello-world/test_characters.csv", all_characters = FALSE)


#UTF-8
files$write_csv(tibble_speciale_karakters, "~/RStudio/hello-world/test_characters_utf.csv", convert_encoding = F, encoding = "UTF-8")

#result is also correct
test_read_special_characters_utf <- files$load_file("~/RStudio/hello-world/test_characters_utf.csv", all_characters = FALSE)




