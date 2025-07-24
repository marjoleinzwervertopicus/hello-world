source("Library/init.R")

files <- source("Library/utilities/files.R")$value

rav_limburg_stats <- files$load_file("/home/devise/logs/user_statistics_prod/rav_limburg.csv")
mk_limburg_stats <- files$load_file("/home/devise/logs/user_statistics_prod/mk_limburg.csv")

get_logins(rav_limburg_stats)
get_logins(mk_limburg_stats)

get_dashboards(rav_limburg_stats)
get_dashboards(mk_limburg_stats)



no_devise_2025_filter <- function(data) {
  data |>
    filter(year(ts) > 2024) |>
    filter(!grepl("devise", user_email))
}

get_logins <- function(stats) {
  stats |> 
    no_devise_2025_filter() |>
    filter(name == "login") |> 
    group_by(user_email) |>
    summarize(n = n()) |> 
    arrange(desc(n))
}

get_dashboards <- function(stats) {
  stats |> 
    no_devise_2025_filter() |>
    filter(name == "tools_insight_manager_open_insight") |> 
    mutate(value = gsub("\\.yml", "", basename(value))) |>
    group_by(value) |>
    summarize(n = n()) |> 
    arrange(desc(n))
}


check_logs <- source("Library/utilities/check_logs.R")$value

check_logs$search_logs_for_regex("norbert.otten", lookback_day_amount = 120)
  
