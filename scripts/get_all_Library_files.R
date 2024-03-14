library(stringr)

file_counter <- 0

all_library_files <- c()
processed_files <- c()

get_library_files <- function(filename) {
  processed_files <<- c(processed_files, filename)
  print(paste0("check file: ", filename))
  
  parsed_file <- tryCatch({
    getParseData(parse(filename, keep.source = TRUE))
  }, error = function(e) {
    #syntax error in file
    browser()
    tibble(text = character(0), token = character(0))
  })
  
  library_lines <- which(grepl("Library/", parsed_file$text))
  library_lines <- library_lines[which(parsed_file$text[library_lines - 3] %in% c("import", "source"))]
  
  library_files <- parsed_file$text[library_lines]
  
  if(rlang::is_empty(library_files)) {
    library_files <- c()
  } else {
    library_files <- str_extract(library_files, "Library/.*")
    library_files <- gsub("\".*", "", library_files)
    
    if(any(!file.exists(library_files))) {
      file <- library_files[!file.exists(library_files)]
      warning(paste0("file '", file, "' does not exist"))
      browser()
    }
    
  }
  
  all_library_files <<- unique(c(all_library_files, library_files))
}


process_folder <- function(folder_path) {
  files <- list.files(folder_path, pattern = "\\.R$")
  for(file in files) {
    r_file <- paste0(folder_path, "/", file)
    print(paste0(file_counter, " check file: ", r_file))
    file_counter <<- file_counter + 1
    tryCatch({
      get_library_files(r_file)
    }, error = function(cond){
      browser()
    })
    
  }
  folders <- list.dirs(path = folder_path, recursive = FALSE)
  
  folders <- folders[folders != "/home/marjolein/RStudio/Upload/Library"]
  for(sub_folder in folders) {
    if(!any(startsWith(strsplit(folder_path, "/")[[1]], "."))) {
      process_folder(sub_folder)
    }
  }
}

#code will fail with paste0 in imports!!!!!!!!!!!!

process_library_files <- function(files) {
  for(file in files) {
    get_library_files(file)
  }
  
  if(!all(all_library_files %in% processed_files)) {
    files_to_process <- all_library_files[!all_library_files %in% processed_files]
    process_library_files(files_to_process)
  }
}


for(file in all_library_files) {
  
  temp_file_name <- gsub("Library", "Library2", file)
  
  if(!dir.exists(dirname(temp_file_name))) {
    dir.create(dirname(temp_file_name), recursive = TRUE)
  }
  
  file.copy(file, temp_file_name)
}


copy_library_files <- function() {
  for(file in all_library_files) {
    
    temp_file_name <- gsub("Library", "Library2", file)
    
    if(!dir.exists(dirname(temp_file_name))) {
      dir.create(dirname(temp_file_name), recursive = TRUE)
    }
    
    file.copy(file, temp_file_name)
  }
}


process_folder(getwd())
process_library_files(all_library_files)
# copy_library_files()



