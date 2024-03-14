tibble(x = c("‘aasdas’", "“as”adad”")) %>% 
  mutate_if(~"character" %in% class(.), function(x) gsub("‘", "'", x)) %>% 
  mutate_if(~"character" %in% class(.), function(x) gsub("’", "'", x)) %>% 
  mutate_if(~"character" %in% class(.), function(x) gsub("“", "'", x)) %>% 
  mutate_if(~"character" %in% class(.), function(x) gsub("”", "'", x))




tibble(x = c("‘aasdas’", "“as”adad”")) %>% 
  mutate_if(~"character" %in% class(.), function(x) gsub("‘|’|“|”", "'", x))


tibble(x = c("‘aasdas’", "“as”adad”")) %>% 
  mutate(across(where(~"character" %in% class(.)), ~gsub("‘|’|“|”", "'", .)))


no_date_names <- "a"

test <- tibble(a = c("Ja", "ja"), b = c("Ja", "ja"))

test %>% mutate_at(no_date_names, ~ifelse(. %in% c("ja"), "Ja", .))

test %>% mutate(across(no_date_names, ~ifelse(. %in% c("ja"), "Ja", .)))


test <- tibble(a = c(1, 2, 3))

test %>% arrange(across(a))

