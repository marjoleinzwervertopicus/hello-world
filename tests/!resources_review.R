# load functions and data ---------------------------------------------------

source("Library/init.R")
db_connect <- import("Library/database/db_connect.R")
files <- import("Library/utilities/files.R")
resources_to_daterange <- import("Library/calculate/scenario/resources_to_daterange.R")
shift_names_to_codes <- import("Library/calculate/scenario/shift_names_to_codes.R")
shifts_decode <- import("Library/calculate/scenario/shifts_decode.R")
resources_process <- import("Library/calculate/scenario/resources_process.R")
shifts_to_text <- import("Library/calculate/scenario/shifts_to_text.R")
shifts_to_hours <- import("Library/calculate/scenario/shifts_to_hours.R")
resources_load <- import("Library/calculate/scenario/resources_load.R")

# example resources (both in new format and old format)
db_name <- "shared"
resource_table_name <- "hap_analytics_test_resources" 
holidays_table_name <- "hap_analytics_test_holidays"

db <- db_connect(db_name)
resources <- db$table(resource_table_name) |> collect()
holidays <- db$table(holidays_table_name) |> select(-id) |> collect()
db$disconnect()

resources_current <- files$load_file("/home/shared/review_resources_temp/test_resources.csv", all_characters = FALSE)
timeline <- files$load_file("/home/shared/review_resources_temp/test_timeline.csv", all_characters = FALSE) |> 
  rename(start_date = date_start)

# current functions in master ---------
## shifts_decode -----

day_to_num <- c(
  mo = 1,
  tu = 2,
  we = 3,
  th = 4,
  fr = 5,
  sa = 6,
  su = 0
)

shiftcode_to_hours <- function(shift_code) {
  
  days_of_week <- factor(x = c("mo", "tu", "we", "th", "fr", "sa", "su"))
  hours_of_day <- 0:23
  week_array <- tibble(hour_of_week = paste(sapply(days_of_week, function(x_element) { sapply(hours_of_day, function(y_element) {paste0(x_element, "_", y_element)})})))
  week_df <- as_tibble(c(week_array,week_array %>% separate(hour_of_week, sep = "_", into = c("day", "hour"))))
  week_df$day <- factor(x = week_df$day, levels = c("su", "mo", "tu", "we", "th", "fr", "sa"))
  split <- unlist(strsplit(shift_code, "_"))
  
  shift_type <- split[1]
  first_day <- split[2]
  last_day <- split[3]
  
  start_hour <- as.numeric(split[4])
  start_hour_decimal <- start_hour - floor(start_hour)
  end_hour <- start_hour + as.numeric(split[5])
  end_hour_decimal <- end_hour - floor(end_hour)
  
  start_hour <- floor(start_hour)
  end_hour <- floor(end_hour) - ifelse(end_hour_decimal == 0, 1, 0)
  
  if(end_hour >= 24) {
    hours_next_day <- 1:(end_hour - 23)
    end_hour <- end_hour - 24
    hours_in_shift <- as.character(hours_of_day[c(match(start_hour, hours_of_day):match(23, hours_of_day), hours_next_day)])
    days_in_shift <- #if (match(first_day, days_of_week) <= match(last_day, days_of_week)) {
      days_of_week[match(first_day, days_of_week):match(last_day, days_of_week)]
    # } else {
    #   days_of_week[c(seq(match(first_day, days_of_week), 7),seq(1, match(last_day, days_of_week)))]
    # }
    
    shift_df <- week_df %>% mutate(type = ifelse(day %in% days_in_shift & hour %in% hours_in_shift, shift_type, NA))
    
    if(length(days_in_shift) < 7) {
      shift_df <- shift_df %>% mutate(type = ifelse(day %in% first_day & hour %in% hours_of_day[hours_next_day], NA, type))
      next_day <- days_of_week[ifelse(match(last_day, days_of_week) + 1 > 7, 1, match(last_day, days_of_week) + 1)]
      shift_df <- shift_df %>% mutate(type = ifelse(day %in% next_day & hour %in% hours_of_day[hours_next_day], shift_type, type))
    }
  } else {
    hours_in_shift <- as.character(hours_of_day[match(start_hour, hours_of_day):match(end_hour, hours_of_day)])
    days_in_shift <- days_of_week[match(first_day, days_of_week):match(last_day, days_of_week)]
    shift_df <- week_df %>% mutate(type = ifelse(day %in% days_in_shift & hour %in% hours_in_shift, shift_type, NA))
  }
  if(as.numeric(split[5]) < 24 && (start_hour_decimal != 0 | end_hour_decimal != 0)) {
    shift_df <- shift_df %>% 
      mutate(value = 
               ifelse(!is.na(type),
                      ifelse(hour %in% start_hour,
                             ifelse(start_hour_decimal == 0, 
                                    1, 
                                    1 - start_hour_decimal),
                             ifelse(hour %in% end_hour, 
                                    ifelse(end_hour_decimal == 0, 
                                           1, 
                                           end_hour_decimal),
                                    1)),
                      0
               )
      )
  } else {
    shift_df <- shift_df %>% 
      mutate(value = ifelse(!is.na(type), 1, 0))
  }
  
  expected_hours <- length(days_in_shift) * as.numeric(split[5])
  if(!near(expected_hours, sum(shift_df$value))) {
    stop(paste0("Something went wrong with shift_code ", shift_code))
  }
  
  shift_df <- shift_df %>% mutate(value = ifelse(type %in% "n", value * 0.3, 
                                                 ifelse(type %in% "s", value * 0, 
                                                        value)))
  shift_df <- shift_df[c("hour_of_week", "value", "day", "hour")]
  shift_df[["shift_code"]] <- shift_code
  
  
  shift_df
}

shifts_to_hours_old <- function(shifts, fte_hours = 36){
  
  if(nrow(shifts) > 0) {
    name_codes <- shifts %>% distinct(name, code) %>% group_by(name) %>% summarise(codes = list(code), .groups = "drop")
    
    shifts <- map_df(seq_len(nrow(shifts)), function(i) {
      shift_hours <- shiftcode_to_hours(shifts$code[i])
      shift_hours$day <- factor(shift_hours$day, 
                                levels = c("mo", "tu", "we", "th", "fr", "sa", "su"), 
                                labels = c("Maandag", "Dinsdag", "Woensdag",  "Donderdag", "Vrijdag", "Zaterdag", "Zondag"))
      shift_hours$hour <- as.numeric(shift_hours$hour)
      shift_hours %>% mutate(name = shifts$name[i])
    })
    
    shifts <- shifts %>% mutate(value = ifelse(is.na(value), 0, value))
    shifts <- shifts %>% group_by(name, hour_of_week, day, hour) %>% 
      summarise(value = sum(value, na.rm = T), .groups = "drop")
    shifts <- shifts %>% group_by(name) %>% 
      nest(shift_hours = -name) %>% 
      left_join(name_codes, by = "name") %>% 
      ungroup()
    
    shifts <- shifts %>% 
      mutate(hours_week = map_dbl(shift_hours, function(x = .) sum(x$value, na.rm = T))) %>%
      mutate(fte = hours_week / fte_hours)
  }
  
  
  shifts
}



shift_names_to_codes_current <- function(shift_names, shift_definitions = NULL) {
  
  if (!is.null(shift_definitions)) {
    if (is_tibble(shift_definitions) && all(c("name", "code") %in% colnames(shift_definitions))) {
      
      shift_definitions <- shift_definitions |> 
        group_by(shift_name = name) |> 
        summarise(shift_codes = list(code))
      
    } else if (!is_tibble(shift_definitions) && is.list(shift_definitions)) {
      
      shift_definitions <- tibble(shift_name = names(shift_definitions),
                                  shift_codes = unname(shift_definitions))
      
    } else stop("Incorrect shift_definitions")
  }
  
  unique_shifts <- unique(shift_names[!is.na(shift_names)])
  shift_names_are_codes <- unique_shifts[!unique_shifts %in% shift_definitions$shift_name]
  
  shift_names_are_codes <- tibble(shift_name = shift_names_are_codes) |>
    mutate(shift_codes = str_split(shift_name, pattern = ","))
  
  shift_definitions <- 
    bind_rows(shift_definitions,
              shift_names_are_codes)
  
  tibble(shift_name = shift_names) |>
    left_join(shift_definitions, by = "shift_name")
}



shifts_decode_current <- function(shift_names, shift_definitions = NULL, split_per_day = TRUE, nest_decoded = FALSE) {
  
  if(any(duplicated(shift_names))) warning("Duplicate shift_names are removed")
  unique_shift_names <- unique(shift_names)
  shift_names <- shift_names[!is.na(shift_names)]
  
  shifts <- shift_names_to_codes_current(unique_shift_names, 
                                         shift_definitions)
  
  shifts_unnested <- shifts |>
    unnest(shift_codes) |>
    rename(shift_code = shift_codes) |>
    filter(!is.na(shift_code))
  
  if(nrow(shifts_unnested) > 0) {
    corrects_shift_codes <- grepl("^[a-z]_[a-z]{2}_[a-z]{2}_.*_.*$", shifts_unnested$shift_code)
    
    if(any(!corrects_shift_codes)) {
      stop("Unknown or incorrect shift(s): ", 
           paste0(unique(shifts_unnested$shift_code[!corrects_shift_codes]), 
                  collapse = ", "))
    }
    
    shifts_decoded <- shifts_unnested |>
      separate_wider_delim(cols = shift_code, 
                           delim = "_",
                           names = c("shift_type", "start_day", "end_day", "start_hour", "duration"),
                           cols_remove = FALSE) |>
      mutate(start_day = unname(day_to_num[start_day]),
             end_day = unname(day_to_num[end_day]),
             start_time = as.numeric(start_hour),
             duration = as.numeric(duration),
             end_time = start_time + duration)
    
    unique_day_of_week_ranges <- shifts_decoded |> 
      expand(nesting(start_day, end_day), day_of_week = c(unname(day_to_num))) |> 
      mutate(
        day_in_range = case_when(
          start_day <= end_day & day_of_week >= start_day & day_of_week <= end_day ~ TRUE,
          start_day > end_day & !(day_of_week < start_day & day_of_week > end_day) ~ TRUE,
          .default = FALSE)) |> 
      filter(day_in_range) |> 
      select(-day_in_range)
    
    shifts_decoded <- shifts_decoded |> 
      left_join(unique_day_of_week_ranges, 
                join_by(start_day, 
                        end_day), 
                relationship = "many-to-many") |> 
      select(shift_name, 
             shift_code, 
             shift_type, 
             day_of_week, 
             start_time, 
             duration, 
             end_time)
    
    if (split_per_day) {
      rows_shifts_past_midnight <- which(shifts_decoded$end_time >= 24)
      shifts_decoded_subset <- shifts_decoded[rows_shifts_past_midnight, ]
      shifts_decoded$duration[rows_shifts_past_midnight] <- 24 - shifts_decoded_subset[["start_time"]]
      shifts_decoded_subset$day_of_week <- (shifts_decoded_subset[["day_of_week"]] + 1) %% 7
      shifts_decoded_subset$duration <- shifts_decoded_subset[["duration"]] - (24 - shifts_decoded_subset[["start_time"]])
      shifts_decoded_subset$start_time <- 0
      
      shifts_decoded <- bind_rows(
        shifts_decoded,
        shifts_decoded_subset |> 
          filter(duration != 0))
    }
    
    shifts_decoded <- shifts_decoded |>
      select(-end_time) |>
      mutate(across(c(start_time, duration), \(x) duration(x, "hour"))) |> 
      arrange(shift_name, day_of_week, start_time)
    
  } else {
    shifts_decoded <- tibble(shift_name = character(0), 
                             shift_code = character(0),
                             shift_type = character(0),
                             day_of_week = numeric(0),
                             start_time = duration(0),
                             duration = duration(0))
  }
  
  if (nest_decoded) {
    shifts_decoded <- shifts_decoded |> 
      nest(.by = shift_name, 
           .key = "shift_decoded")
  } 
  
  shifts_decoded
}


## shifts_to_hours ----
shiftcode_to_hours <- function(shift_code) {
  
  days_of_week <- factor(x = c("mo", "tu", "we", "th", "fr", "sa", "su"))
  hours_of_day <- 0:23
  week_array <- tibble(hour_of_week = paste(sapply(days_of_week, function(x_element) { sapply(hours_of_day, function(y_element) {paste0(x_element, "_", y_element)})})))
  week_df <- as_tibble(c(week_array,week_array %>% separate(hour_of_week, sep = "_", into = c("day", "hour"))))
  week_df$day <- factor(x = week_df$day, levels = c("su", "mo", "tu", "we", "th", "fr", "sa"))
  split <- unlist(strsplit(shift_code, "_"))
  
  shift_type <- split[1]
  first_day <- split[2]
  last_day <- split[3]
  
  start_hour <- as.numeric(split[4])
  start_hour_decimal <- start_hour - floor(start_hour)
  end_hour <- start_hour + as.numeric(split[5])
  end_hour_decimal <- end_hour - floor(end_hour)
  
  start_hour <- floor(start_hour)
  end_hour <- floor(end_hour) - ifelse(end_hour_decimal == 0, 1, 0)
  
  if(end_hour >= 24) {
    hours_next_day <- 1:(end_hour - 23)
    end_hour <- end_hour - 24
    hours_in_shift <- as.character(hours_of_day[c(match(start_hour, hours_of_day):match(23, hours_of_day), hours_next_day)])
    days_in_shift <- #if (match(first_day, days_of_week) <= match(last_day, days_of_week)) {
      days_of_week[match(first_day, days_of_week):match(last_day, days_of_week)]
    # } else {
    #   days_of_week[c(seq(match(first_day, days_of_week), 7),seq(1, match(last_day, days_of_week)))]
    # }
    
    shift_df <- week_df %>% mutate(type = ifelse(day %in% days_in_shift & hour %in% hours_in_shift, shift_type, NA))
    
    if(length(days_in_shift) < 7) {
      shift_df <- shift_df %>% mutate(type = ifelse(day %in% first_day & hour %in% hours_of_day[hours_next_day], NA, type))
      next_day <- days_of_week[ifelse(match(last_day, days_of_week) + 1 > 7, 1, match(last_day, days_of_week) + 1)]
      shift_df <- shift_df %>% mutate(type = ifelse(day %in% next_day & hour %in% hours_of_day[hours_next_day], shift_type, type))
    }
  } else {
    hours_in_shift <- as.character(hours_of_day[match(start_hour, hours_of_day):match(end_hour, hours_of_day)])
    days_in_shift <- days_of_week[match(first_day, days_of_week):match(last_day, days_of_week)]
    shift_df <- week_df %>% mutate(type = ifelse(day %in% days_in_shift & hour %in% hours_in_shift, shift_type, NA))
  }
  if(as.numeric(split[5]) < 24 && (start_hour_decimal != 0 | end_hour_decimal != 0)) {
    shift_df <- shift_df %>% 
      mutate(value = 
               ifelse(!is.na(type),
                      ifelse(hour %in% start_hour,
                             ifelse(start_hour_decimal == 0, 
                                    1, 
                                    1 - start_hour_decimal),
                             ifelse(hour %in% end_hour, 
                                    ifelse(end_hour_decimal == 0, 
                                           1, 
                                           end_hour_decimal),
                                    1)),
                      0
               )
      )
  } else {
    shift_df <- shift_df %>% 
      mutate(value = ifelse(!is.na(type), 1, 0))
  }
  
  expected_hours <- length(days_in_shift) * as.numeric(split[5])
  if(!near(expected_hours, sum(shift_df$value))) {
    stop(paste0("Something went wrong with shift_code ", shift_code))
  }
  
  shift_df <- shift_df %>% mutate(value = ifelse(type %in% "n", value * 0.3, 
                                                 ifelse(type %in% "s", value * 0, 
                                                        value)))
  shift_df <- shift_df[c("hour_of_week", "value", "day", "hour")]
  shift_df[["shift_code"]] <- shift_code
  
  
  shift_df
}

shifts_to_hours_current <- function(shifts, fte_hours = 36){
  
  if(nrow(shifts) > 0) {
    name_codes <- shifts %>% distinct(name, code) %>% group_by(name) %>% summarise(codes = list(code), .groups = "drop")
    
    shifts <- map_df(seq_len(nrow(shifts)), function(i) {
      shift_hours <- shiftcode_to_hours(shifts$code[i])
      shift_hours$day <- factor(shift_hours$day, 
                                levels = c("mo", "tu", "we", "th", "fr", "sa", "su"), 
                                labels = c("Maandag", "Dinsdag", "Woensdag",  "Donderdag", "Vrijdag", "Zaterdag", "Zondag"))
      shift_hours$hour <- as.numeric(shift_hours$hour)
      shift_hours %>% mutate(name = shifts$name[i])
    })
    
    shifts <- shifts %>% mutate(value = ifelse(is.na(value), 0, value))
    shifts <- shifts %>% group_by(name, hour_of_week, day, hour) %>% 
      summarise(value = sum(value, na.rm = T), .groups = "drop")
    shifts <- shifts %>% group_by(name) %>% 
      nest(shift_hours = -name) %>% 
      left_join(name_codes, by = "name") %>% 
      ungroup()
    
    shifts <- shifts %>% 
      mutate(hours_week = map_dbl(shift_hours, function(x = .) sum(x$value, na.rm = T))) %>%
      mutate(fte = hours_week / fte_hours)
  }
  
  
  shifts
}

## shifts_to_text ----
shifts_default <- tibble(
  name = c("24 uur", "24 uur", "D3O", "D3O"),
  code = c("a_mo_su_8_15", "n_mo_su_23_9", "a_tu_we_8_8", "a_fr_fr_8_8"))

shifts_to_text_old <- function(shift_names, shift_definitions = shifts_default) {
  
  if(is.null(shift_definitions)) {
    shift_definitions <- tibble(name = unique(shift_names[!is.na(shift_names)])) %>% 
      mutate(code = name)
  } else {
    shift_definitions <- bind_rows(shift_definitions, 
                                   tibble(name = unique(shift_names[!is.na(shift_names) & !shift_names %in% shift_definitions$name]),
                                          code = unique(shift_names[!is.na(shift_names) & !shift_names %in% shift_definitions$name])))
    shift_definitions <- shift_definitions %>% filter(name %in% shift_names)
  }
  
  decode <- function(shift_code) {
    tryCatch({
      split <- unlist(strsplit(shift_code, "_"))
      
      type <- split[1]
      first_day <- split[2]
      last_day <- split[3]
      start_hour <- as.numeric(split[4])
      start_hour_decimal <- start_hour - floor(start_hour)
      end_hour <- start_hour + as.numeric(split[5])
      end_hour_decimal <- end_hour - floor(end_hour)
      
      start_hour <- floor(start_hour)
      end_hour <- floor(end_hour)
      
      if(end_hour >= 24) end_hour <- end_hour - 24
      
      abr_label <- tibble(abr = c("mo", "tu", "we", "th", "fr", "sa", "su"), 
                          label = c("Maandag", "Dinsdag", "Woensdag",  "Donderdag", "Vrijdag", "Zaterdag", "Zondag"))
      
      abr_label$label <- substr(abr_label$label, 1, 2)
      result <- tibble(first_day = abr_label$label[which(first_day == abr_label$abr)],
                       last_day = abr_label$label[which(last_day == abr_label$abr)],
                       start_hour = start_hour,
                       end_hour = end_hour) %>% 
        mutate(text = paste0(ifelse(first_day == last_day, first_day, paste0(first_day, " t/m ", last_day)), " ", floor(start_hour), ":", formatC(round(60 * start_hour_decimal, 0), flag = "0", width = 2), 
                             " - ", 
                             floor(end_hour), ":", formatC(round(60 * end_hour_decimal, 0), flag = "0", width = 2), ifelse(type == "n", " (aanwezigheid)", "")))
    }, error = function(e) {
      browser()
    })
    
    abr_label$label <- substr(abr_label$label, 1, 2)
    result <- tibble(first_day = abr_label$label[which(first_day == abr_label$abr)],
                     last_day = abr_label$label[which(last_day == abr_label$abr)],
                     start_hour = start_hour,
                     end_hour = end_hour) %>% 
      mutate(text = paste0(ifelse(first_day == last_day, first_day, paste0(first_day, " t/m ", last_day)), " ", floor(start_hour), ":", formatC(round(60 * start_hour_decimal,0), flag = "0", width = 2), 
                           " - ", 
                           floor(end_hour), ":", formatC(round(60 * end_hour_decimal,0), flag = "0", width = 2), ifelse(type == "s", " (bereikbaarheid)", ifelse(type == "n", " (aanwezigheid)", ""))))
    result$text
  }
  
  shift_definitions %>% 
    mutate(shift_text = map_chr(code, ~decode(.))) %>% 
    group_by(shift_name = name) %>% 
    summarise(shift_text = paste0(shift_text, collapse = " & "), .groups = "drop")
}

## resources_process ----

# shifts_to_text <- import("Library/calculate/scenario/shifts_to_text.R")
# shifts_to_hours <- import("Library/calculate/scenario/shifts_to_hours.R")
# shifts_decode <- import("Library/calculate/scenario/shifts_decode.R")
coverage_shapes_get <- import("Library/calculate/scenario/coverage_shapes_get.R")
geocode <- import("Library/geography/geocode.R")

shifts_default <- tibble(
  name = c("24 uur", "24 uur", "D3O", "D3O"),
  code = c("a_mo_su_8_15", "n_mo_su_23_9", "a_tu_we_8_8", "a_fr_fr_8_8"))

coverage_shape_range <- c(seq(60, 60*15, by = 60), 60*20, 60*25, 60*35, 60*50) * 1.2

processed_columns <- c("link_chain", "shift_text", "coverage_shapes", "inherit_location", "shift_hours", "codes", "hours_week", "fte", "latitude", "longitude", "shift_decoded")

link_chain_add <- function(resources) {
  
  resources[["link_chain"]] <- NULL
  resources[["inherit_location"]] <- NULL
  
  unique_id_links <- resources |> distinct(id_link) |> drop_na()
  missing_ids <- unique_id_links |> filter(!id_link %in% resources$id) |> pull(id_link)
  if (length(missing_ids) > 0) {
    warning("Linked resource missing for id = ", paste0(missing_ids, collapse = ", "))
    resources[resources$id_link %in% missing_ids, "id_link"] <- NA
  }
  
  next_ids <- left_join(
    unique_id_links,
    resources |> select(id, id_latest = id_link, location, name),
    join_by(id_link == id)
  )
  
  unique_link_chains <- unique_id_links |> 
    mutate(
      id_latest = id_link,
      inherit_location = NA_character_
    )
  
  iteration <- 0
  while (TRUE) {
    iteration <- iteration + 1
    previous_id_link_name <- paste0("id_previous_", iteration)
    
    unique_link_chains <- unique_link_chains |> 
      rename(!!previous_id_link_name := id_latest) |> 
      left_join(
        next_ids,
        join_by(!!previous_id_link_name == id_link)
      ) |> 
      mutate(inherit_location = if_else(!is.na(location), name, inherit_location)) |> 
      select(-location, -name)
    
    if (all(is.na(unique_link_chains$id_latest))) {
      unique_link_chains <- unique_link_chains |> select(-id_latest)
      break
    }
  }
  
  unique_link_chains <- unique_link_chains |> 
    pivot_longer(starts_with("id_previous_"), names_to = NULL, 
                 values_to = "link_chain", values_drop_na = TRUE) |> 
    summarize(link_chain = list(link_chain), .by = c(id_link, inherit_location))
  
  resources <- resources |> 
    left_join(
      unique_link_chains,
      by = "id_link"
    )
  
  resources
}

resources_process_current <- function(resources, 
                                      shift_definitions = shifts_default, 
                                      get_coverage_shapes = TRUE, 
                                      add_link_chain = TRUE,
                                      add_shift_hours = TRUE, 
                                      geocode_locations = TRUE,
                                      decode_shifts = TRUE,
                                      bag_table_name = "bag_adres") {
  
  if (is.null(resources)) stop("Resources is NULL")
  resources <- as_tibble(resources)
  
  if (any(processed_columns %in% colnames(resources))) {
    message("Resources already processed, removing processed columns")
    resources <- resources[, !colnames(resources) %in% processed_columns]
  }
  
  if (!"id" %in% colnames(resources)) resources[["id"]] <- NA_integer_
  if (!"name" %in% colnames(resources)) resources[["name"]] <- NA_character_
  if (!"type" %in% colnames(resources)) resources[["type"]] <- NA_character_
  if (!"location" %in% colnames(resources)) resources[["location"]] <- NA_character_
  if (!"shift_name" %in% colnames(resources)) resources[["shift_name"]] <- NA_character_
  if (!"id_link" %in% colnames(resources)) resources[["id_link"]] <- NA_integer_
  if (!"amount" %in% colnames(resources)) resources[["amount"]] <- 1
  
  if (!is.null(resources) && nrow(resources) > 0) {
    
    resources$id_link <- strtoi(resources$id_link)
    resources$id <- strtoi(resources$id)
    
    if (any(is.na(resources$id))) {
      message("Filling missing ID's")
      
      if(all(is.na(resources$id))) {
        max_id <- 0
      } else {
        max_id <- max(resources$id, na.rm = T)
      }
      
      resources$id[is.na(resources$id)] <- seq(from = max_id + 1, 
                                               length.out = length(resources$id[is.na(resources$id)]))
    }
    
    if (any(duplicated(resources$id))) {
      stop("Resource table has duplicate ids")
    }
    
    resources$location[resources$location == ""] <- NA
    resources$location <- str_trim(resources$location)
    resources$location <- gsub("^([0-9]{4}) ([a-zA-Z]{2}\\s?[0-9]+[a-zA-Z]?)$", "\\1\\2", resources$location)
    resources$id_link[resources$id_link == ""] <- NA
    resources$shift_name[resources$shift_name == ""] <- NA
    
    resources <- arrange(resources, location)
    
    if (!exists("latitude", resources)) {
      resources["latitude"] <- NA
    }
    resources$latitude <- as.numeric(resources$latitude)
    
    if (!exists("longitude", resources)) {
      resources["longitude"] <- NA
    }
    resources$longitude <- as.numeric(resources$longitude)
    
    if (geocode_locations) {
      for(i in seq_len(nrow(resources))) {
        if(is.na(resources$latitude[i]) || is.na(resources$latitude[i])) {
          if(!is.null(geocode) && !is.na(resources$location[i]) && grepl("[0-9]{4}[A-Z]{2}", resources$location[i])) {
            result <- geocode$single(resources$location[i], bag_table_name = bag_table_name)
            if(nrow(result) > 0) {
              resources$latitude[i] <- result$latitude[1]
              resources$longitude[i] <- result$longitude[1]
            }
          }
        }
      }
    }
    
    resources <- resources |> 
      mutate(amount = ifelse(is.na(amount), 1, as.numeric(amount)))
    
    if (add_link_chain) {
      resources <- link_chain_add(resources)
    }
    
    if (decode_shifts) {
      resources <- resources |>
        left_join(shifts_decode_current(unique(resources$shift_name), 
                                        shift_definitions,
                                        split_per_day = TRUE,
                                        nest_decoded = TRUE), 
                  by = "shift_name")
    }
    
    if (add_shift_hours) {
      if (is.null(shift_definitions)) {
        shift_definitions <- tibble(name = unique(resources$shift_name[!is.na(resources$shift_name)])) |> 
          mutate(code = name)
      } else {
        unique_shifts <- unique(resources$shift_name[!is.na(resources$shift_name) & !resources$shift_name %in% shift_definitions$name])
        if (!is_empty(unique_shifts)) {
          shift_definitions <- bind_rows(shift_definitions, 
                                         tibble(name = unique(resources$shift_name[!is.na(resources$shift_name) & !resources$shift_name %in% shift_definitions$name]),
                                                code = unique(resources$shift_name[!is.na(resources$shift_name) & !resources$shift_name %in% shift_definitions$name])))
          i <- nrow(shift_definitions)
          while (any(grep(",", shift_definitions$code))) {
            i <- i - 1
            duplicate_shift_definitions <- shift_definitions[grep(",", shift_definitions$code), ]
            duplicate_shift_definitions$code <- gsub("(.*),([a-zA-Z0-9\\._]*)$", "\\2", duplicate_shift_definitions$code)
            shift_definitions$code <- gsub("(.*),([a-zA-Z0-9\\._]*)$", "\\1", shift_definitions$code)
            
            shift_definitions <- bind_rows(shift_definitions, duplicate_shift_definitions)
            if (i <= 0) {
              stop(paste0("Cannot parse all shift definitions: ", paste(shift_definitions$code[grep(",", shift_definitions$code)], collapse = " & ")))
            }
          }
        }
      }
      
      unique_shifts <- unique(resources$shift_name[!is.na(resources$shift_name) & !resources$shift_name %in% shift_definitions$name])
      if (!is_empty(unique_shifts)) {
        shift_definitions <- bind_rows(shift_definitions, 
                                       tibble(name = unique(resources$shift_name[!is.na(resources$shift_name) & !resources$shift_name %in% shift_definitions$name]),
                                              code = unique(resources$shift_name[!is.na(resources$shift_name) & !resources$shift_name %in% shift_definitions$name])))
      }
      
      shift_text <- resources$shift_name |> shifts_to_text_old(shift_definitions)
      resources <- left_join(resources, shift_text, by = "shift_name")
      
      if (!"shift_hours" %in% colnames(shift_definitions)) {
        shift_definitions <- shifts_to_hours_current(shift_definitions)
      }
      
      
      if (nrow(shift_definitions) > 0) {
        if ("shift_hours" %in% colnames(resources)) {
          resources <- resources |> 
            select(-shift_hours, -codes, -hours_week, -fte)
        }
        
        resources <- resources |> 
          mutate(shift_name = as.character(shift_name)) |> 
          left_join(shift_definitions, 
                    by = c("shift_name" = "name"))
        
        resources <- resources |> 
          mutate(fte = amount * fte)
      }
      
    }
    
    if (get_coverage_shapes && !all(is.na(resources$location))) {
      coverage_shapes <- coverage_shapes_get(resources |> 
                                               filter(!is.na(location) & !is.na(latitude) & !is.na(longitude)), 
                                             range = coverage_shape_range, 
                                             as_named_list = FALSE,
                                             create = T)
      coverage_shapes <- split(coverage_shapes, 
                               f = coverage_shapes[["location"]])
      coverage_shapes <- tibble(location = names(coverage_shapes), 
                                coverage_shapes = unname(coverage_shapes))
      resources <- left_join(resources, 
                             coverage_shapes, 
                             by = "location")
    }
    
  }
  
  resources
}

## resources_to_daterange -----

resources_to_daterange_current <- function(resources, date_range, shift_definitions = NULL) {
  
  if (is.data.frame(resources)) {
    resources <- list(resources)
    names(resources) <- date_range[1]
  }
  
  date_range <- as.Date(date_range)
  resource_dates <- as.Date(names(resources))
  
  if (any(!is.Date(resource_dates))) stop("Resources list should have correct dates")
  if (any(!is.Date(date_range))) stop("Date range should have correct dates")
  if (date_range[1] > date_range[2]) stop("Date range should be chronological")
  if (!identical(resource_dates, sort(resource_dates))) stop("Resource dates should be chronological")
  if (date_range[1] < resource_dates[1]) stop("First resource date must be before first date_range: ", resource_dates[1])
  
  first_i <- max(which(date_range[1] >= resource_dates))
  last_i <- max(which(date_range[2] >= resource_dates))
  seq_i <- seq(first_i, last_i, by = 1)
  
  resources <- resources[seq_i]
  resource_dates <- resource_dates[seq_i]
  resources <- tibble(
    resource_date = resource_dates,
    resources = resources) |> 
    unnest(resources) |> 
    filter(!is.na(shift_name))
  
  if ("shift_decoded" %in% names(resources)) {
    resources <- resources |> 
      unnest(shift_decoded)
  } else {
    resources <- resources |> 
      left_join(shifts_decode_current(unique(resources$shift_name),
                                      shift_definitions = shift_definitions,
                                      split_per_day = TRUE,
                                      nest_decoded = FALSE),
                by = "shift_name", 
                relationship = "many-to-many")
  }
  
  date_sequence <- tibble(
    date = seq(
      from = date_range[1], 
      to = date_range[2], 
      by = "day")) |> 
    mutate(
      week_date = floor_date(date, 
                             unit = "week", 
                             week_start = 1),
      day_of_week = as.numeric(format(date, "%w")))
  
  resources_daterange <- date_sequence |>
    left_join(resources, 
              join_by(closest(date >= resource_date), day_of_week)) |>
    mutate(start_datetime = lubridate::force_tz(date + start_time, "Europe/Amsterdam"),
           end_datetime = start_datetime + seconds(duration),
           duration = as.numeric(duration) / 60 / 60) |>
    filter(!is.na(start_datetime)) |>
    select(-resource_date, 
           -start_time, 
           -shift_code)
  
  resources_daterange
}

# review -----
## general ----
# current is used for current functions (master) and current shift_name
# no affix is used for modified functions and new shift_name

unique_shift_names <- resources |> distinct(shift_name) |> drop_na() |> pull()
unique_shift_names_current <- resources_current |> distinct(shift_name) |> drop_na() |> pull()

## shifts_decode ----

system.time(shifts_decoded <- shifts_decode(unique_shift_names)) # not that the table is twice as big due to addition of holiday
system.time(shifts_current_decoded <- shifts_decode(unique_shift_names_current))
system.time(shifts_current_decoded_current <- shifts_decode_current(unique_shift_names_current))
all.equal(shifts_current_decoded, shifts_current_decoded_current) # only difference is holiday column with new function

## shifts_to_hours ----

system.time(shifts_hours <- shifts_to_hours(unique_shift_names))
system.time(shifts_current_hours <- shifts_to_hours(unique_shift_names_current))
# current function cannot deal with hour fractions other than half. So to compare
# new and old functions we convert everything to half or whole hours.
system.time(shifts_onlyhalfhour_hours_current <- shifts_to_hours_current(unique_shift_names_current |> gsub("(?<=\\.)[^5_]*", "", x = _, perl = TRUE) |> unique() |> shift_names_to_codes() |> unnest(codes) |> rename(name = shift_name, code = codes)))
system.time(shifts_onlyhalfhour_hours <- shifts_to_hours(unique_shift_names_current |> gsub("(?<=\\.)[^5_]*", "", x = _, perl = TRUE) |> unique()))
all.equal(shifts_onlyhalfhour_hours |> 
            arrange(shift_name) |> 
            mutate(shift_hours = lapply(shift_hours, \(x) x |> arrange(hour_of_week)), 
                   codes = lapply(codes, \(x) sort(x))), 
          shifts_onlyhalfhour_hours_current |> 
            arrange(name) |> 
            mutate(shift_hours = lapply(shift_hours, \(x) x |> arrange(hour_of_week)), 
                   codes = lapply(codes, \(x) sort(x))))

# take into account different shift types "a", "n", "s"
shifts_to_hours(c("a_mo_fr_8_8", "n_mo_fr_8_8", "s_mo_fr_8_8"))
shifts_to_hours_current(tibble(name = c("a_mo_fr_8_8", "n_mo_fr_8_8", "s_mo_fr_8_8")) |> mutate(code = name))

## shifts_to_text ----

system.time(shift_texts <- shifts_to_text(unique_shift_names))
system.time(shift_current_texts <- shifts_to_text(unique_shift_names_current))
# current function cannot deal with comma separated shift_name. So to compare
# new and old functions we convert everything to codes.
system.time(shift_currentcodes_texts_current <- shifts_to_text_old(unique_shift_names_current |> shift_names_to_codes() |> unnest(codes) |> pull(codes) |> unique()))
system.time(shift_currentcodes_texts <- shifts_to_text(unique_shift_names_current |> shift_names_to_codes() |> unnest(codes) |> pull(codes) |> unique()))
all.equal(shift_currentcodes_texts, shift_currentcodes_texts_current)

## resources_process ----

date_range <- c("2020-09-30", "2020-12-31")

resources_processed <- resources |> 
  resources_process(
    get_coverage_shapes = FALSE, 
    add_link_chain = TRUE, 
    geocode_locations = FALSE, 
    decode_shifts = TRUE,
    add_shift_hours = TRUE
  )

resources_current_processed <- resources_current |> 
  resources_process(
    get_coverage_shapes = FALSE, 
    add_link_chain = TRUE, 
    geocode_locations = FALSE, 
    decode_shifts = TRUE,
    add_shift_hours = TRUE
  )

resources_current_processed_current <- resources_current |> 
  resources_process_current(
    get_coverage_shapes = FALSE, 
    add_link_chain = TRUE, 
    geocode_locations = FALSE, 
    decode_shifts = TRUE,
    add_shift_hours = TRUE
  )
# length mismatch in shift_decoded due to new holiday column
# shift_text string mismatches due to concatenating consecutive days with equal time range
all.equal(
  resources_current_processed[,names(resources_current_processed_current)] |> 
    mutate(shift_hours = lapply(shift_hours, \(x) if (!is.null(x)) x |> arrange(hour_of_week)), 
           codes = lapply(codes, \(x) sort(x))), 
  resources_current_processed_current |> 
    mutate(shift_hours = lapply(shift_hours, \(x) if (!is.null(x)) x |> arrange(hour_of_week)), 
           codes = lapply(codes, \(x) sort(x)))
)
# different shift texts:
resources_current_processed |>
  distinct(shift_name, shift_text) |>
  left_join(
    resources_current_processed_current |>
      distinct(shift_name, shift_text_current = shift_text)
  ) |>
  filter(shift_text != shift_text_current) |> view()


## resources_to_daterange ----

resources_daterange <- resources_processed |> 
  resources_to_daterange(
    date_range = date_range, 
    holidays = holidays
  )

resources_daterange_no_holidays <- resources_processed |> 
  resources_to_daterange(
    date_range = date_range
  )

resources_current_daterange <- resources_current_processed |> 
  left_join(timeline, join_by(schedule_name, holiday), relationship = "many-to-many") |> 
  select(-holiday) |>
  resources_to_daterange(
    date_range = date_range
  )

resources_current_daterange_current <- resources_current_processed |> 
  left_join(timeline, join_by(schedule_name, holiday), relationship = "many-to-many") |> 
  select(-holiday) |> 
  nest(.by = start_date) |> 
  drop_na(start_date) |> 
  arrange(start_date) |> 
  pull(data, start_date) |> 
  resources_to_daterange_current(
    date_range = date_range
  )

all.equal(
  resources_current_daterange[, names(resources_current_daterange_current)], 
  resources_current_daterange_current
)

## try to find edge cases for shifts_to_text ----
# different shift types
shifts_to_text(c(
  "a_1_2_0_0_1_1_0_3_8_9",
  "n_1_2_0_0_1_1_0_3_8_9",
  "s_1_2_0_0_1_1_0_3_8_9",
  "1_1_2_0_0_1_1_0_3_8_9",
  "1.1_1_2_0_0_1_1_0_3_8_9"
))

# invalid
shifts_to_text("_1_2_0_0_1_1_0_3_8_9")
shifts_to_text(" _1_2_0_0_1_1_0_3_8_9")
shifts_to_text("a_1.1_2_0_0_1_1_0_3_8_9")
shifts_to_text("a_a_2_0_0_1_1_0_3_8_9")
shifts_to_text("a_1_2_0_0_1_1_0_3_8_25")
shifts_to_text("a_1_2_0_0_1_1_0_3_8_0")
shifts_to_text("a_1_2_0_0_1_1_0_3_25_8")

# new function concatenates consecutive days with same time range. Old function
# did not. Can be easily changed if old style is preferred for old style shift names
shifts_to_text(c("a_mo_tu_8_9,a_fr_sa_8_9", "a_1_1_0_0_1_1_0_0_8_9"))
shifts_to_text_old(c("old_style"), shift_definitions = tibble(name = c("old_style", "old_style"), code = c("a_mo_tu_8_9", "a_fr_sa_8_9")))             

# consecutive days are shortened as much as possible to include sunday to monday.
# exception is when shift_codes are provided seperately (first example below).
shifts_to_text(c(
  "a_mo_tu_8_15,a_fr_su_8_15,a_mo_tu_23_9,a_fr_su_23_9", 
  "a_fr_tu_8_15,a_fr_tu_23_9", 
  "a_1_1_0_0_1_1_1_0_8_15,a_1_1_0_0_1_1_1_0_23_9"
))
shifts_to_text_old("a_fr_tu_8_15")
shifts_to_text("a_1_1_0_2_3_1_1_1_23_9")

# default shift definition
shifts_to_text("24 uur")

# zero days
shifts_to_text("a_0_0_0_0_0_0_0_0_8_9")
# just holiday
shifts_to_text("a_0_0_0_0_0_0_0_1_8_9")

# hour fractions
shifts_to_text(c(
  "a_1_0_0_0_0_0_0_0_8.123_9.684",
  "a_1_0_0_0_0_0_0_0_8.934_19.345"
))
shifts_to_text_old(c(
  "a_mo_mo_8.123_9.684",
  "a_mo_mo_8.934_19.345"
))


#output as expected
shifts_to_hours_old(tibble(name = "test", code = "a_fr_tu_8_15"))
shifts_to_hours("a_fr_tu_8_15")

#output NOT as expected
shifts_to_hours_old(tibble(name = "test", code = "a_tu_fr_8_15"))
shifts_to_hours("a_tu_fr_8_15")

#output as expected
shifts_to_hours_old(tibble(name = "test", code = "a_mo_mo_8.123_9.684"))
shifts_to_hours("a_mo_mo_8.123_9.684")

#output as expected
shifts_to_hours_old(tibble(name = "test", code = "a_mo_mo_8.934_19.345"))
shifts_to_hours("a_mo_mo_8.934_19.345")

shifts_to_hours_old(tibble(name = "test", code = "24 uur"))
shifts_to_hours("24 uur")




shifts_to_hours_old(tibble(name = c("test", "test"), code = c("a_mo_tu_8_9", "a_fr_sa_8_9")))
shifts_to_hours(c("a_mo_tu_8_9", "a_fr_sa_8_9"))


