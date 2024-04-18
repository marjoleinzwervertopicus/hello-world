library(shiny)
library(shinyjs)
library(shinyWidgets)

source("Library/init.R") 

# source("Library/init.R")
# database <- import("Library/database/database.R")
# connections <- database$get_connections("marjolein")

# connections$customer$set("DROP TABLE edit_test_empty")
# connections$customer$set("CREATE TABLE edit_test_empty (edit_test_id  SERIAL PRIMARY KEY, aantal smallint, bedrag double precision, datum date, datum_tijd timestamp without time zone,urgentie character varying, opmerking character varying, is_devise boolean)")

# connections$customer$set("CREATE TABLE edit_test_small (edit_test_id  SERIAL PRIMARY KEY, aantal smallint)")
# connections$customer$set(paste0("INSERT INTO edit_test_small(aantal) VALUES (2)"))


# connections$customer$set("DROP TABLE edit_test")

# connections$customer$set("CREATE TABLE edit_test (edit_test_id  SERIAL PRIMARY KEY, aantal smallint, bedrag double precision, datum date, datum_tijd timestamp without time zone,urgentie character varying, opmerking character varying, is_devise boolean)")
# connections$customer$set(paste0("INSERT INTO edit_test(aantal, bedrag, datum, datum_tijd, urgentie, opmerking, is_devise) VALUES (2, 2.5, '01-01-2024', '01-01-2024 12:21:22', 'A2', 'test', TRUE)"))


# connections$customer$set("CREATE TABLE edit_test (edit_test_id  SERIAL PRIMARY KEY, aantal smallint, bedrag double precision, datum date, datum_tijd timestamp without time zone,urgentie character varying(2), opmerking character varying, is_devise boolean NOT NULL)")
# connections$customer$set(paste0("INSERT INTO edit_test(aantal, bedrag, datum, datum_tijd, urgentie, opmerking, is_devise) VALUES (2, 2.5, '01-01-2024', '01-01-2024 12:21:22', 'A2', 'test', TRUE)"))

# connections$customer$set("CREATE TABLE edit_test_double (edit_test_id  SERIAL PRIMARY KEY, aantal smallint, bedrag double precision, datum date, datum_tijd timestamp without time zone,urgentie character varying(2), opmerking character varying, is_devise boolean NOT NULL,
#                          aantal2 smallint, bedrag2 double precision, datum2 date, datum_tijd2 timestamp without time zone,urgentie2 character varying(2), opmerking2 character varying, is_devise2 boolean NOT NULL)")
# connections$customer$set(paste0("INSERT INTO edit_test_double (aantal, bedrag, datum, datum_tijd, urgentie, opmerking, is_devise,
#                                                        aantal2, bedrag2, datum2, datum_tijd2, urgentie2, opmerking2, is_devise2) VALUES 
#                                                       (2, 2.5, '01-01-2024', '01-01-2024 12:21:22', 'A2', 'test', TRUE,
#                                                       2, 2.5, '01-01-2024', '01-01-2024 12:21:22', 'A2', 'test', TRUE)"))


# connections$customer$get("SELECT * FROM edit_test")

editable_table <- source("Library/utilities/editable_table.R")$value
database <- import("Library/database/database.R")

table_output_empty_id <- "table_output_empty_id"

table_output_id <- "table_output_id"
table_output_id2 <- "table_output_id2"
table_output_id3 <- "table_output_id3"
table_output_id4 <- "table_output_id4"
table_output_id0 <- "table_output_id0"


server <- function(input, output, session) {
  connections <- database$get_connections("marjolein")
  
  
  editable_table$create(
    list(input = input, output = output, session = session),
    table_output_empty_id,
    list(
      database = list(
        table_name = "edit_test_empty",
        id_column_name = "edit_test_id",
        hide_id_column = F,
        connection = connections$customer
      )
    ),
    column_types = list(
      aantal = "integer",
      bedrag = "numeric",
      datum = "Date",
      datum_tijd = "Datetime",
      urgentie = "character_short",
      opmerking = "character_long",
      is_devise = "logical"
    )
  )
  
  
  editable_table$create(
    list(input = input, output = output, session = session),
    table_output_id0,
    list(
      database = list(
        table_name = "edit_test",
        id_column_name = "edit_test_id",
        hide_id_column = F,
        connection = connections$customer
      )
    ),
    column_types = list(
      aantal = "integer",
      bedrag = "numeric",
      datum = "Date",
      datum_tijd = "Datetime",
      urgentie = "character_short",
      opmerking = "character_long",
      is_devise = "logical"
    )
  )
  
  editable_table$create(
    list(input = input, output = output, session = session),
    table_output_id,
    list(
      database = list(
        table_name = "edit_test_double",
        id_column_name = "edit_test_id",
        hide_id_column = F,
        connection = connections$customer
      )
    ),
    column_types = list(
      aantal = "integer",
      bedrag = "numeric",
      datum = "Date",
      datum_tijd = "Datetime",
      urgentie = "character_short",
      opmerking = "character_long",
      is_devise = "logical",
      aantal2 = "integer",
      bedrag2 = "numeric",
      datum2 = "Date",
      datum_tijd2 = "Datetime",
      urgentie2 = "character_short",
      opmerking2 = "character_long",
      is_devise2 = "logical"
    ),
    options = list(
      column_value_restrictions = list(
        aantal = list(min = 10, max = 20),
        # bedrag = list(max = 10000.5),
        urgentie = list(choices = c("A1", "A2", "B"), max_nchar = 2),
        datum = list(min = as.Date("2024-01-01"), max = as.Date("2025-01-01")),
        opmerking = list(allow_empty = T, max_nchar = 5),
        is_devise = list(allow_empty = T)
      ),
      editable_column_names = c(
        # "aantal",
        "bedrag",
        "datum",
        "datum_tijd",
        "urgentie"
      ),
      row_label = "standplaats",
      display_search_bar = TRUE,
      rows_per_page = NULL,
      hide_id_column = TRUE,
      na_value = "geen waarde"
    )
  )
  
  editable_table$create(
    list(input = input, output = output, session = session),
    table_output_id2,
    list(
      file_path = "~/RStudio/Map1_empty.csv"
    ),
    column_types = list(
      aantal = "integer",
      bedrag = "numeric",
      datum = "Date",
      datum_tijd = "Datetime",
      urgentie = "character_short",
      opmerking = "character_long",
      is_devise = "logical"
    ),
    options = list(
      column_value_restrictions = list(
        aantal = list(min = 10, max = 20),
        # bedrag = list(max = 10000.5),
        # urgentie = list(choices = c("A1", "A2", "B")),
        datum = list(min = as.Date("2024-01-01"), max = as.Date("2025-01-01")),
        opmerking = list(allow_empty = T, max_nchar = 5),
        is_devise = list(allow_empty = T)
      ),
      editable_column_names = c(
        # "aantal",
        "bedrag",
        "datum",
        "datum_tijd",
        "urgentie"
      ),
      row_label = "standplaats",
      display_search_bar = TRUE,
      rows_per_page = NULL,
      hide_id_column = TRUE,
      na_value = "geen waarde"
    )
  )
  
  editable_table$create(
    list(input = input, output = output, session = session),
    table_output_id3,
    list(
      file_path = "~/RStudio/Map1_empty.xlsx"
    ),
    column_types = list(
      aantal = "integer",
      bedrag = "numeric",
      datum = "Date",
      datum_tijd = "Datetime",
      urgentie = "character_short",
      opmerking = "character_long",
      is_devise = "logical"
    ),
    options = list(
      column_value_restrictions = list(
        aantal = list(min = 10, max = 20),
        # bedrag = list(max = 10000.5),
        urgentie = list(choices = c(A1 = "A1", A2 = "A2", B = "B", Leeg = NA), allow_empty = T),
        datum = list(min = as.Date("2024-01-01"), max = as.Date("2025-01-01")),
        opmerking = list(allow_empty = T, max_nchar = 5),
        is_devise = list(allow_empty = T)
      ),
      editable_column_names = c(
        # "aantal",
        "bedrag",
        "datum",
        "datum_tijd",
        "urgentie"
      ),
      row_label = "standplaats",
      display_search_bar = TRUE,
      rows_per_page = NULL,
      hide_id_column = TRUE,
      na_value = "geen waarde"
    )
  )
  
  editable_table$create(
    list(input = input, output = output, session = session),
    table_output_id4,
    list(
      database = list(
        table_name = "edit_test_small",
        id_column_name = "edit_test_id",
        hide_id_column = F,
        connection = connections$customer
      )
    ),
    column_types = list(
      aantal = "integer"
    )
  )
  

}

ui <- fluidPage(
  useShinyjs(),
  useShinyFeedback(),
  "Empty table",
  uiOutput(table_output_empty_id),
  "Table with 2 columns",
  uiOutput(table_output_id4),
  "Table with no options passed",
  uiOutput(table_output_id0),
  "Database table with 2 of each type of column",
  uiOutput(table_output_id),
  "Csv table",
  uiOutput(table_output_id2),
  "XLSX table",
  uiOutput(table_output_id3),

)

shinyApp(ui = ui, server = server)