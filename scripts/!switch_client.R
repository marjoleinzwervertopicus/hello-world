... <- (function() {
  client_options <- list.files("/home/devise/insights/test")
  client_options <- client_options[!client_options %in% c("hap", "hap_dashboard")]
  client_index <- readline(prompt = paste0("Which client do you want to switch to? \n", paste0(paste0(seq_len(length(client_options)), " ", client_options), collapse = "\n")))
  
  if(is.na(suppressWarnings(as.numeric(client_index)))) {
    stop("input was not a number, try again")
  }
  
  client <- client_options[as.numeric(client_index)]
  message("Chosen client is '", client, "'")
  
  application_config <- list(client = client, client_name = client, url = "test", shinyproxy_url = "test")
  yaml::write_yaml(application_config, "configs/application.yml")
  message("Changed configs/application.yml")
  
  do_copy_test_insights <- readline(prompt = paste0("Do you want to copy the test insights from /home/devise/insights/test to the 'insights' folder? y/n\n"))
  do_copy_test_insights <- identical(do_copy_test_insights, "y")
  
  if(do_copy_test_insights) {
    if(dir.exists("insights") && length(list.files("insights")) > 0) {
      do_overwrite_insights <- readline(prompt = paste0("'insights' folder is not empty, do you want to overwrite? y/n\n"))
      do_overwrite_insights <- identical(do_overwrite_insights, "y")
      
      if(do_overwrite_insights) {
        unlink("insights", recursive = TRUE)
      } else {
        message("Copying insights was canceled")
        return()
      }
    }
    
    if(!dir.exists("insights")) dir.create("insights")
    test_insight_paths <- files <- list.files(paste0("/home/devise/insights/test/", client), full.names = TRUE)
    file.copy(test_insight_paths, "insights", recursive = TRUE)
    message("Copying insights complete")
  }
  
  file.remove("configs/user_groups.yml")
  file.copy(paste0("/home/devise/configs/production/", client, "/user_groups.yml"), "configs/user_groups.yml")
  
  
})()