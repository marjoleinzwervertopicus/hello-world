... <- (function(){
# comparison of tables (test vs 'live' development) to check if there are no unintended changes.
Sys.setenv("DEVISE_DB_USER" = "postgres")
source("Library/init.R")
db <- import("Library/database/db.R")

get_table_differences = function(comparison_tables_current_new, skip_columns = character(0), current_host = "application", new_host = "development") {
  if (!current_host %in% c("test", "development", "application")) stop("Current_host must be one of 'test', 'development', 'application'")
  if (!new_host %in% c("test", "development", "application")) stop("Current_host must be one of 'test', 'development', 'application'")
  if (!is.character(skip_columns)) stop("skip_columns must be a character vector")
  
  if (!is.list(comparison_tables_current_new) && length(comparison_tables_current_new) == 2) {
    comparison_tables_current_new <- list(comparison_tables_current_new)
  }
  
  table_pair_names <- if (!is.null(names(comparison_tables_current_new))) {
    names(comparison_tables_current_new)
  } else {
    paste("pair_", seq_along(comparison_tables_current_new))
  }
  
  table_differences <- map2(comparison_tables_current_new, table_pair_names, function(tables, table_pair_name) {
    if (length(tables) != 2) stop("Must provide two tables for each comparison (in order of current, new)")
    
    names(tables) <- c("current", "new")
    
    # get table types (database table or dataframe), query function (for database table) and column names
    tables <- map2(tables, names(tables), function(table_i, current_or_new) {
      if (is.character(table_i) && length(table_i) == 1 && length(str_split_1(table_i, " ")) == 2) {
        # table is a database table
        table_name <- str_split_1(table_i, " ")[[2]]
        db_table_con <- db(table_i, 
                           host = paste0("postgres_", 
                                         ifelse(current_or_new == "current",
                                                current_host,
                                                new_host), 
                                         "_server")
        )[[table_name]]
        
        table_properties <- list(
          type = "db_table",
          name = table_name,
          query = db_table_con$connection$get,
          col_names = db_table_con$show_columns()$column_name
        )
      } else if (is.data.frame(table_i)) {
        # table is a dataframe
        table_properties <- list(
          type = "dataframe",
          data = table_i,
          col_names = names(table_i)
        )
      } else {
        # table format is invalid
        stop("Table must either be a connection string or a dataframe")
      }
      
      return(table_properties)
    })
    
    # determine new and missing columns in new table
    new_columns <- tables$new$col_names[!tables$new$col_names %in% tables$current$col_names]
    missing_columns <- tables$current$col_names[!tables$current$col_names %in% tables$new$col_names]
    skipped_columns <- tables$new$col_names[tables$new$col_names %in% skip_columns]
    
    # compare both tables column by column
    comparison <- map(set_names(tables$new$col_names), function(col_name) {
      if (col_name %in% skip_columns) return(NULL)
      if (col_name %in% new_columns) return(NULL)
      
      # if a column is a list of vectors, we will sort the vectors and convert each vector to a single string to minimize the number of unique elements (assuming the order in each vector is irrelevant
      list_to_unique_vector <- function(list_object) {
        list_object <- list_object |> 
          map(\(element) sort(element, na.last = TRUE) |> paste0(collapse = "|")) |> 
          unlist() |> 
          unique()
      }
      
      # getting unique values in current column of each table to compare. Using unique values only to minimise the runtime and still get a good idea of changes in the dataset due to changes in preparation.
      unique_values <- map(tables, function(table_i) {
        unique_values <- if (table_i$type == "db_table") {
          table_i$query(paste0("SELECT DISTINCT ", col_name, " FROM ", table_i$name)) |> 
            pull()
        } else if (table_i$type == "dataframe") {
          table_i$data |> 
            distinct(pick(all_of(col_name))) |> 
            pull()
        }
        
        if (is.list(unique_values)) unique_values <- list_to_unique_vector(unique_values)
        
        # sorting the vector to be able to do a simple identical comparison instead of expensive '%in%'. Only if not all is equal will we use '%in%'.
        unique_values <- unique_values |> sort(na.last = TRUE) 
        return(unique_values)
      })
      
      unique_equal <- identical(unique_values$new, unique_values$current)
      all_unique_equal <- all(unique_equal)
      
      if (!all_unique_equal) {
        return(tibble(
          not_equal_column = col_name,
          unique_new = list(unique_values$new[!unique_values$new %in% unique_values$current]),
          unique_missing = list(unique_values$current[!unique_values$current %in% unique_values$new])
        ))
      } else {
        return(NULL)
      }
    }) |> 
      discard(is.null) |> 
      list_rbind()
    
    tibble(
      table_pair_name = table_pair_name,
      equal = all(
        length(new_columns) == 0,
        length(missing_columns) == 0,
        length(comparison) == 0
      ),
      skipped_columns = list(skipped_columns),
      new_columns = list(new_columns),
      missing_columns = list(missing_columns),
      not_equal_columns = list(comparison$not_equal_column),
      differences = list(comparison),
    )
  }) |> 
    list_rbind()
  
  return(table_differences)
}

get_table_differences
})()