... <- (function() {
  library(DT)
  library(shinyFeedback)
  import <- source("Library/import.R")$value()
  modal <- import("Library/utilities/modal.R")
  files <- import("Library/utilities/files.R")
  
  #column_value_restrictions
  #numeric: min, max
  #character: max_char (max number of characters), choices (options for the value)
  #date: min, max
  #all fields: allow_empty (allow NULL/NA/"" default TRUE)
  this <- list(create = function(state, ns, table_output_id, editable_column_names = NULL, 
                         table_file_location = NULL, database_table_name = NULL, database_table_id_column = NULL, column_value_restrictions = NULL, row_label = "rij") {
    if(is.null(table_file_location) && is.null(database_table_name)) {
      stop("At least one of table_file_location and table_file_name must be passed")
    }
    
    if(!is.null(database_table_name)) {
      if(!"connections" %in% names(state)) stop("When passing database_table_name, state must have connections")
      if(is.null(database_table_id_column)) {
        stop("When passing database_table_name, the name of the id column must also be passed with 'database_table_id_column'")
      }
    }
    

    
    if(!is.null(database_table_name)) {
      input_table <- state$connections$customer$get(paste0("SELECT * FROM ", database_table_name))
    } else {
      input_table <- files$load_file(table_file_location, all_characters = FALSE)
      
      #load_file will read all numeric columns as double, not int. So convert to int if possible
      input_table <- input_table %>% mutate(across(where(~is.numeric(.) & all(grepl(pattern = "^[0-9]*$", as.character(.)))), as.integer))
    }
    
    if(is.null(editable_column_names)) editable_column_names <- colnames(input_table)
    
    non_existing_columns <- editable_column_names[!editable_column_names %in% colnames(input_table)]
    if(!is_empty(non_existing_columns)) stop(paste0("The following columns are not present in the table: ", paste0(non_existing_columns, collapse = ", ")))
    
    add_observers(state, ns, input_table, column_value_restrictions, editable_column_names, row_label)
    
    state$output[[table_output_id]] <- renderUI({
      div(
        actionButton(ns("add_row"), icon = icon("plus"), title = "Toevoegen", label = ""),
        actionButton(ns("edit_row"), icon = icon("edit"), title = "Wijzigen", label = ""),
        actionButton(ns("delete_row"), icon = icon("minus"), title = "Verwijderen", label = ""),
        
      datatable(
        input_table,
        style = "bootstrap",
        escape = FALSE,
        rownames = FALSE,
        selection = "single",
        class = 'hover',
        options = list(
          # paging = nrow(showed_result) > page_length,
          # searching = nrow(showed_result) > page_length, 
          # info = nrow(showed_result) > page_length,
          # pageLength = page_length,
          # ordering = copy_if_not_null(options$visible$table_tab$ordering, TRUE),
          language = list(url = '//cdn.datatables.net/plug-ins/1.10.11/i18n/Dutch.json'),
          dom = 'ftp',
          searchHighlight = TRUE,
          rowCallback = JS(paste0("function(row, data) {
            $(row).click(function() {
              var click_index = $(this)[0]._DT_RowIndex + 1;
              if(!window['", ns("row_clicked_"), "' + click_index]) {
                Shiny.onInputChange(\"", ns("row_click_index"), "\", null);
                Shiny.onInputChange(\"", ns("row_click_index"), "\", click_index);
              }
              });
            }"))
        )
      )
      )
    })
  })
  
  add_observers <- function(state, ns, input_table, column_value_restrictions, editable_column_names, row_label) {
    modal <- modal$create(state)
    
    table_classes <- sapply(input_table, class)
    table_classes[map_lgl(table_classes, ~identical(., c("POSIXct", "POSIXt")))] <- "date"
    
    onclick(ns("add_row"), {
      uuid <- uuid::UUIDgenerate()
      modal_ns <- function(x) paste0(ns(x), "_", uuid)
      
      column_ui <- lapply(seq_len(ncol(input_table)), function(i) {
        column_name <- colnames(input_table)[i]
        column_class <- table_classes[[column_name]]
        column_restictions <- column_value_restrictions[[column_name]]
        create_column_ui(modal_ns, column_name, column_class, column_restictions)
      })
      
      modal$show(
        easyClose = TRUE,
        title = paste("Voeg", row_label, "toe"),
        column_ui,
        actionButton(ns("do_add_row"), "Toevoegen", class = "submit-button")
      )
      
      onclick(ns("do_add_row"), {
        add_values <- lapply(seq_len(ncol(input_table)), function(i) {
          column_name <- colnames(input_table)[i]
          input_value <- state$input[[modal_ns(paste0(column_name, "_value"))]]
        }) %>% setNames(colnames(input_table))
        
        are_values_correct <- lapply(seq_len(length(add_values)), function(j) {
          value <- add_values[j]
          column_name <- names(value)
          check_value(value[[1]], table_classes[[column_name]], column_value_restrictions[[column_name]])
        }) |> setNames(names(add_values))
        
        if(all(map_lgl(are_values_correct, ~isTRUE(.)))) {
          browser()
          save_row(add_values)
        } else {
          are_values_correct <- are_values_correct[map_lgl(are_values_correct, ~!isTRUE(.))]
          lapply(seq_len(length(are_values_correct)), function(k) {
            column_name <- names(are_values_correct)[k]
            message <- are_values_correct[[k]]
            input_id <- modal_ns(paste0(column_name, "_value"))
            feedbackDanger(inputId = input_id, text = message, show = TRUE)
            
            observeEvent(state$input[[input_id]], {
              hideFeedback(input_id)
            }, ignoreInit = TRUE, once = TRUE)
          })
        }
        
      })
    })
    
    onclick(ns("delete_row"), {
      browser()
    })
    
    onclick(ns("edit_row"), {
      row_data <- input_table[state$input[[ns("row_click_index")]], ]
      uuid <- uuid::UUIDgenerate()
      modal_ns <- function(x) paste0(ns(x), "_", uuid)
      
      column_ui <- lapply(seq_len(ncol(input_table)), function(i) {
        column_name <- colnames(input_table)[i]
        column_class <- table_classes[[column_name]]
        column_restictions <- column_value_restrictions[[column_name]]
        can_edit <- column_name %in% editable_column_names
        create_column_ui(modal_ns, column_name, column_class, column_value = row_data[[column_name]], column_restictions, can_edit)
      })
      
      modal$show(
        easyClose = TRUE,
        title = paste("Pas", row_label, "aan"),
        column_ui,
        actionButton(ns("do_add_row"), "Wijzig", class = "submit-button")
      )
    })
  }
  
  create_column_ui <- function(ns, column_name, column_class, column_restrictions, column_value = NULL, can_edit = TRUE) {
    input_id <- ns(paste0(column_name, "_value"))
    if(column_class %in% c("numeric", "integer") && !all(c("min", "max") %in% names(column_restrictions))) {
      if(is.null(column_restrictions)) {
        column_restrictions <- list(min = NA, max = NA)
      } else {
        column_restrictions <- modifyList(list(min = NA, max = NA), column_restrictions)
      }
    }
    if(column_class == "character") {
      if("choices" %in% names(column_restrictions)) {
        ui <- selectizeInput(input_id, column_name, choices = column_restrictions$choices, selected = column_value)
      } else {
        ui <- textInput(input_id, column_name, value = column_value)
      }
    } else if(column_class == "numeric") {
      value <- if(!is.null(column_value)) column_value else if(!is.na(column_restrictions$min)) column_restrictions$min else 0
      ui <- numericInput(input_id, column_name, value = value , step = 0.1, min = column_restrictions$min, max = column_restrictions$max)
    } else if(column_class == "integer") {
      value <- if(!is.null(column_value)) column_value else if(!is.na(column_restrictions$min)) column_restrictions$min else 0
      ui <- numericInput(input_id, column_name, value = value, step = 1, min = column_restrictions$min, max = column_restrictions$max)
    } else if(column_class == "logical") {
      ui <- radioButtons(input_id, column_name, choices = c("Ja" = TRUE, "Nee" = "FALSE", "(Geen waarde)" = NA), inline = TRUE, selected = column_value)
    } else if(column_class == "date") {
      ui <- dateInput(input_id, column_name, language = "nl", weekstart = 1, min = column_restrictions$min, max = column_restrictions$max, value = as.Date(column_value))
    } else {
      stop("Column class '", column_class, "' is not implemented yet")
    }
    
    if(can_edit) {
      ui
    } else {
      disabled(ui)
    }
  }
  
  #is the value of type class and does it adhere to the restrictions?
  check_value <- function(value, class, restrictions) {
    allowed_types <- list(
      integer = "integer",
      numeric = c("integer", "numeric"),
      logical = "character",
      date = "Date",
      character = "character"
    )
    
    is_correct_type <- class(value) %in% allowed_types[[class]]
    
    if(class == "integer" && !is_correct_type) {
      return("Vul een heel getal in")
    }
    if(!is_correct_type) {
      browser()
      #should not happen??
    }
    
    if("min" %in% names(restrictions) && class %in% c("integer", "numeric")) {
      if(value < restrictions$min) return(paste0("Vul een waarde in die hoger of gelijk is aan ", restrictions$min))
    }
    
    if("max" %in% names(restrictions) && class %in% c("integer", "numeric")) {
      if(value > restrictions$max) return(paste0("Vul een waarde in die lager of gelijk is aan ", restrictions$max))
    }
    
    if("max_char" %in% names(restrictions) && class == "character") {
      if(nchar(value) > restrictions$max_char) return(paste0("Vul een waarde met een maximaal  ", restrictions$max, "karakters"))
    }
    
    if("allow_empty" %in% names(restrictions)) {
      if(class %in% c("numeric", "integer")) {
        is_empty <- is.na(value)
      } else if(class == "character") {
        is_empty <- nchar(value) == 0
      } else if(class == "date") {
        is_empty <- length(value) == 0
      }
      if(is_empty) return("Vul een waarde in")
    }
    
    TRUE
  }
  
  this
})()