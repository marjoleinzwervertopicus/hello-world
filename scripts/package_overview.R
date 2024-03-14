library(purrr)
library(tibble)
library(dplyr)
# unable_to_load <- c()
# 
# lapply(.packages(all.available = TRUE), function(x) {
#   tryCatch({
#     library(x, character.only = TRUE)
#   }, error = function(e) {
#     unable_to_load <<- c(unable_to_load, x)
#   }, warning = function(w) {
#   })
# })
# print("done loading packages")
# removed_namespaces <- c()
package_use_overview <- list()

file_counter <- 0

get_used_functions <- function(filename) {
  parsed_file <- tryCatch({
    getParseData(parse(filename, keep.source = TRUE))
  }, error = function(e) {
    #syntax error in file
    tibble(text = character(0), token = character(0))
  })
  functions <- parsed_file$text[which(parsed_file$token == "SYMBOL_FUNCTION_CALL")]
  function_packages <- paste(as.vector(sapply(functions, function(x) {
    packages <- find(x)
    if(!is_empty(packages)) {
      packages <- find(x)
      if(length(packages) > 1 && "maptools" %in% packages) packages <- "maptools"
      packages[[1]]
    }
  })))
  
  # functions_not_found <- unique(functions[function_packages == "character(0)"])
  overview <- tapply(functions, factor(function_packages), c)
  overview <- overview[grepl("^package:", names(overview))]
  removed_namespaces <<- names(overview)[!grepl("^package:", names(overview))]
  package_use <- lapply(overview, function(package_functions) list(length = length(package_functions), functions = unique(package_functions)))
}

process_folder <- function(folder_path) {
  files <- list.files(folder_path, pattern = "\\.R$")
  for(file in files) {
    r_file <- paste0(folder_path, "/", file)
    print(paste0(file_counter, " check file: ", r_file))
    file_counter <<- file_counter + 1
    tryCatch({
      package_use <- get_used_functions(r_file)
    }, error = function(cond){
      browser()
    })
    if(length(package_use) != 0) {
      for(package_name in names(package_use)) {
        package_use_overview[[package_name]][[r_file]] <<- package_use[[package_name]]
        package_use_overview[[package_name]]$functions <<- unique(c(package_use_overview[[package_name]]$functions, package_use[[package_name]]$functions))
      }
    }
  }
  folders <- list.dirs(path = folder_path, recursive = FALSE)
  for(sub_folder in folders) {
    if(!any(startsWith(strsplit(folder_path, "/")[[1]], "."))) {
      process_folder(sub_folder)
    }
  }
}

process_folder(getwd())

# saveRDS(package_use_overview, file = "package_use_overview.rds")
loaded_packages <- paste0("package:", (.packages()))
installed_packages <- as_tibble(installed.packages())

used_packages <- names(package_use_overview)
package_licenses <- installed_packages[paste0("package:", installed_packages$Package) %in% used_packages, ] %>% dplyr::select("Package", "License")
# write.xlsx(package_licenses, "package_licenses.xlsx")

packages_not_used <- loaded_packages[!loaded_packages %in% names(package_use_overview)]

package_total_use <- lapply(package_use_overview, function(package) sum(map_int(package[names(package) != "functions"], function(package_file) package_file$length)))
package_total_use <- package_total_use[order(unlist(package_total_use))]
package_total_use_table <- tibble(name = names(package_total_use), use_amount = unlist(unname(package_total_use)))
# write.xlsx(package_total_use_table, "package_use.xlsx")

packages_not_loaded <- installed_packages$Package[!paste0("package:", installed_packages$Package) %in% loaded_packages]

# package_use_overview
# package_total_use
# package_licenses
# packages_not_used
# packages_not_loaded