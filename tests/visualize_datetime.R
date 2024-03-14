hcGopts <- getOption("highcharter.global")
hcGopts$useUTC <- TRUE
options(highcharter.global = hcGopts)

#gaat goed?
tibble(
  x = seq(
    from = ymd_hms("2022-01-01 00:00:00"), 
    to =  ymd_hms("2023-01-01 00:00:00"), 
    by = "1 hour")) %>% 
  mutate(y = 20) %>%
  visualize$graph(interactive = T)


hcGopts <- getOption("highcharter.global")
hcGopts$useUTC <- FALSE
options(highcharter.global = hcGopts)


#gaat fout, gaat goed als je global optie veranderd
tibble(
  x = seq(
    from = ymd_hms("2022-01-01 00:00:00", tz = "CET"), 
    to =  ymd_hms("2023-01-01 00:00:00", tz = "CET"), 
    by = "1 hour")) %>% 
  mutate(y = 20) %>%
  visualize$graph(interactive = T)


#gaat goed met UTC = false
tibble(
  x = seq(
    from = ymd_hms("2022-03-27 00:00:00", tz = "CET"), 
    to =  ymd_hms("2022-03-28 00:00:00", tz = "CET"), 
    by = "1 hour")) %>% 
  mutate(y = 20) %>%
  visualize$graph(interactive = T)


tibble(
  x = seq(
    from = ymd_hms("2022-10-30 00:00:00", tz = "CET"), 
    to =  ymd_hms("2022-10-31 00:00:00", tz = "CET"), 
    by = "1 hour")) %>% 
  mutate(y = 20) %>%
  visualize$graph(interactive = T)



