Sys.setlocale(locale = "en_US.utf8")
# source("clients/proigia/voorspellen_hap_2023/model.R")
source("Library/init_analysis.R")


test <- data_per_uur %>% filter(datum == "2020-10-25", datum_uur == "2")

data_per_uur %>% filter(datum == "2021-03-28") %>% View()

hour_7 <- data_per_uur %>% filter(datum_uur == 7) %>% filter(datum_weekdag %in% c("Saturday", "Sunday"))
sum(hour_7$bellers_totaal)

hour_0 <- data_per_uur %>% filter(datum_uur == 0)


day_hour_means <- data_per_uur %>%
  filter(!is_feestdag) %>%
  filter(is_open) %>%
  group_by(datum_weekdag, datum_uur) %>%
  summarize(mean = mean(bellers_totaal))

data_per_uur %>%
  filter(is_feestdag) %>%
  mutate(is_feestdag_doordeweeks = datum_weekdag %in% c("Saturday", "Sunday")) %>%
  select(is_feestdag_doordeweeks, datum_weekdag, datum_uur, bellers_totaal) %>%
  inner_join(day_hour_means, by = c("datum_uur", "datum_weekdag")) %>%
  mutate(diff = bellers_totaal - mean) %>%
  group_by(is_feestdag_doordeweeks) %>%
  summarize(mean = mean(diff)) %>%
  select(x = is_feestdag_doordeweeks, y = mean) %>%
  visualize$graph(interactive = T, labels = list(x = "is_feestdag_doordeweeks", y = "mean diff with average"), types = list(bar = T))


#variance feestdagen
data_per_uur %>%
  filter(is_feestdag) %>%
  group_by(feestdagnaam) %>%
  summarize(var = sd(bellers_totaal)) %>%
  select(x = feestdagnaam, y = var) %>%
  visualize$graph(interactive = T, labels = list(x = "feestdag", y = "sd bellers totaal"), types = list(bar = T))
  


#doordeweekse feestdagen vergeleken met niet-feestdagen
data_per_uur %>%
  filter(!is_feestdag) %>%
  group_by(datum_weekdag, datum_uur) %>%
  summarise(y = mean(bellers_totaal, na.rm = T)) %>%
  select(x = datum_uur, y = y, group = datum_weekdag) %>%
  visualize$graph(interactive = T, labels = list(x = "uur van de dag", y = "gemiddelde aantal calls"), types = list(line = TRUE)) %>%
  visualize$graph(input_2 = doordeweekse_feestdag, interactive = T, types = list(line = TRUE))

doordeweekse_feestdag <- data_per_uur %>%
  filter(is_feestdag & !datum_weekdag %in% c("Saturday", "Sunday")) %>%
  group_by(datum_uur) %>%
  summarise(y = mean(bellers_totaal, na.rm = T)) %>%
  select(x = datum_uur, y = y)


#bellers buiten openingtijden? Nee
sum(data_per_uur$bellers_totaal[!data_per_uur$is_open])
unique(data_per_uur$datum_uur[!data_per_uur$is_open])


sum(train_data$bellers_totaal[!train_data$is_open])
unique(train_data$datum_uur[!train_data$is_open])

sum(train_data$gesprekken_totaal[!train_data$is_open])


#laatste week train data
#zitten er feestdagen in? Ja, za 25 dec en zo 26 dec
#wat voor weekdag is de laatste dag? vrijdag
train_data %>%
  filter(datum > max(datumtijd) %m-% weeks(4)) %>%
  select(x = datumtijd, y = bellers_totaal) %>%
  visualize$graph(options = list(line = TRUE), interactive = TRUE)



sum(data_per_uur$gesprekken_totaal[!data_per_uur$is_open])


#number of values for each hour of the day
data_per_uur_source %>%
  mutate(datum_uur = as.character(tijd)) %>%
  mutate(datum_jaar = as.numeric(format(datum_tijd, "%Y"))) %>%
  filter(datum_jaar == "2017") %>%
  mutate(is_zomertijd = datum_tijd >= as.POSIXct("2017-03-26 03:00:00") & datum_tijd < as.POSIXct("2017-10-29 03:00:00")) %>%
  # mutate(datum_uur = as.numeric(format(datum_tijd, "%H"))) %>%
  group_by(datum_uur, is_zomertijd) %>%
  summarize(mean = mean(aantal_bellers)) %>%
  group_by(is_zomertijd) %>%
  select(x = datum_uur, y = mean, group = is_zomertijd) %>%
  visualize$graph(options = list(line = TRUE), interactive = TRUE)


#number of values for each hour of the day
data_per_uur_source %>%
  mutate(datum_uur = as.numeric(format(datum_tijd, "%H"))) %>%
  group_by(datum_uur) %>%
  summarize(n = n()) %>%
  select(x = datum_uur, y = n) %>%
  visualize$graph(options = list(line = TRUE), interactive = TRUE)


#zomer/wintertijd gemiddelden per uur van de dag (source)
data_per_uur_source %>%
  mutate(datum_jaar = as.numeric(format(datum_tijd, "%Y"))) %>%
  filter(datum_jaar == "2017") %>%
  mutate(is_zomertijd = datum_tijd >= as.POSIXct("2017-03-26 03:00:00") & datum_tijd < as.POSIXct("2017-10-29 03:00:00")) %>%
  mutate(datum_uur = as.numeric(format(datum_tijd, "%H"))) %>%
  group_by(datum_uur, is_zomertijd) %>%
  summarize(mean = mean(aantal_bellers)) %>%
  group_by(is_zomertijd) %>%
  select(x = datum_uur, y = mean, group = is_zomertijd) %>%
  visualize$graph(options = list(line = TRUE), interactive = TRUE)

#zomer/wintertijd gemiddelden per uur van de dag
data_per_uur %>%
  filter(datum_jaar == "2017") %>%
  mutate(is_zomertijd = datumtijd >= as.POSIXct("2017-03-26 03:00:00") & datumtijd < as.POSIXct("2017-10-29 03:00:00")) %>%
  group_by(datum_uur, is_zomertijd) %>%
  summarize(mean = mean(bellers_totaal)) %>%
  group_by(is_zomertijd) %>%
  select(x = datum_uur, y = mean, group = is_zomertijd) %>%
  visualize$graph(options = list(line = TRUE), interactive = TRUE)



#zomer/wintertijd gemiddelden per uur van de dag
train_data %>%
  filter(datum_jaar == "2017") %>%
  mutate(is_zomertijd = datumtijd >= as.POSIXct("2017-03-26 03:00:00") & datumtijd < as.POSIXct("2017-10-29 03:00:00")) %>%
  group_by(datum_uur, is_zomertijd) %>%
  summarize(mean = mean(bellers_totaal)) %>%
  group_by(is_zomertijd) %>%
  select(x = datum_uur, y = mean, group = is_zomertijd) %>%
  visualize$graph(options = list(line = TRUE), interactive = TRUE)


test_data %>%
  filter(datum_jaar == "2022") %>%
  mutate(is_zomertijd = datumtijd >= as.POSIXct("2022-03-27 03:00:00") & datumtijd < as.POSIXct("2022-10-30 03:00:00")) %>%
  group_by(datum_uur, is_zomertijd) %>%
  summarize(mean = mean(bellers_totaal)) %>%
  group_by(is_zomertijd) %>%
  select(x = datum_uur, y = mean, group = is_zomertijd) %>%
  visualize$graph(options = list(line = TRUE), interactive = TRUE)


#zomer/wintertijd gemiddelden per uur van de dag
data_per_uur %>%
  filter(datum_jaar == "2017") %>%
  mutate(is_zomertijd = datumtijd >= as.POSIXct("2017-03-26 02:00:00") & datumtijd < as.POSIXct("2017-10-29 03:00:00")) %>%
  group_by(datum_uur, is_zomertijd) %>%
  summarize(mean = mean(bellers_totaal)) %>%
  group_by(is_zomertijd) %>%
  select(x = datum_uur, y = mean, group = is_zomertijd) %>%
  visualize$graph(options = list(line = TRUE), interactive = TRUE)



a <- data_per_uur[!data_per_uur$is_open & data_per_uur$bellers_totaal > 0, ]


#montly average for each year
data_per_uur %>%
  group_by(datum_maand, datum_jaar) %>%
  summarize(mean = mean(bellers_totaal)) %>%
  group_by(datum_jaar) %>%
  select(y = mean, x = datum_maand, group = datum_jaar) %>%
  mutate(group = as.character(group)) %>%
  visualize$graph(options = list(line = TRUE), interactive = T)


#iteraction effect day of week + max_temp?
train_data %>%
  group_by(datum) %>%
  mutate(weer_gevoelstemp_max_round = round(max(weer_gevoelstemp_max)))





data_per_uur_alleen_open <- data_per_uur[data_per_uur$is_open, ]

mean(data_per_uur$bellers_totaal)


#temp test data
test_data %>%
  select(x = datumtijd, y = weer_gevoelstemp_max) %>%
  visualize$graph(interactive = T, types = list(line = TRUE))


#rain test data
test_data %>%
  select(x = datumtijd, y = weer_neerslag_mm_uur) %>%
  visualize$graph(interactive = T, types = list(line = TRUE))

#variance for hour of each day
data_per_uur_alleen_open %>%
  filter(!is_feestdag) %>%
  group_by(datum_weekdag, datum_uur) %>%
  summarise(var = var(bellers_totaal, na.rm = T)) %>%
  select(x = datum_uur, y = var, group = datum_weekdag) %>%
  visualize$graph(interactive = T, labels = list(x = "uur van de dag", y = "variance"), types = list(line = TRUE))

#averange variance per day
data_per_uur_alleen_open %>%
  filter(!is_feestdag) %>%
  group_by(datum_weekdag, datum_uur) %>%
  summarise(var = var(bellers_totaal, na.rm = T)) %>%
  group_by(datum_weekdag) %>%
  summarise(mean = var(var, na.rm = T)) %>%
  select(x = datum_weekdag, y = mean, group = datum_weekdag) %>%
  visualize$graph(interactive = T, labels = list(x = "uur van de dag", y = "variance"), types = list(bar = TRUE))



#gemiddelde week
# data_per_uur_alleen_open %>%
#   filter(!is_feestdag, datum_weekdag == "Monday") %>%
#   group_by(datum_uur) %>%
#   summarise(y = mean(bellers_totaal, na.rm = T)) %>%
#   select(x = datum_uur, y = y) %>%
#   visualize$graph(interactive = T, labels = list(x = "uur van de dag", y = "gemiddelde aantal calls"), types = list(bar = TRUE))
# 

#zaterdag en zondag zijn drukker
#warme maanden zijn drukker?
plot_seasonal_diagnostics(
  data_per_uur_alleen_open %>% filter(!is_feestdag),
  datumtijd,
  bellers_totaal,
  .interactive = T,
  .feature_set = c("wday.lbl", "month.lbl", "year"))


#Hoe vergelijken feestdagen met weekend dagen?
#Aantal bellers is iets hoger op feestdagen
data_per_uur %>%
  filter(datum_weekdag %in% c("Saturday", "Sunday")) %>%
  summarize(mean = mean(bellers_totaal))

data_per_uur %>%
  filter(is_feestdag) %>%
  summarize(mean = mean(bellers_totaal))

#show all data
data_per_uur %>%
  # filter(datum < "2017-01-07") %>%
  mutate(x = format(datumtijd, format = "%Y-%m-%d %H")) %>%
  select(x = x, y = bellers_totaal) %>%
  visualize$graph(interactive = T, types = list(line = T))


#show data 1 year
data_per_uur %>%
  mutate(x = format(datumtijd, format = "%Y-%m-%d %H")) %>%
  select(x = x, y = bellers_totaal) %>%
  visualize$graph(interactive = T, types = list(line = T))

#for every day of the week, show average number of calls for each hour
#vrijdag avond is de drukste avond. Significant verschil?
#avond is drukker dan ochtend
#zaterdag is drukker dan zondag
data_per_uur %>%
  filter(is_open) %>%
  filter(!is_feestdag) %>%
  group_by(datum_weekdag, datum_uur) %>%
  summarise(y = mean(bellers_totaal, na.rm = T)) %>%
  select(x = datum_uur, y = y, group = datum_weekdag) %>%
  visualize$graph(interactive = T, labels = list(x = "uur van de dag", y = "gemiddelde aantal calls"), types = list(line = TRUE))

#monthly seasonality?
data_per_uur_alleen_open %>%
  # filter(!is_feestdag) %>%
  group_by(datum_maand, datum_jaar) %>%
  summarise(y = mean(bellers_totaal, na.rm = T)) %>%
  ungroup() %>%
  mutate(jaar_maand = paste0(datum_jaar,"-", datum_maand)) %>%
  arrange(jaar_maand) %>%
  select(x = jaar_maand, y = y) %>%
  visualize$graph(interactive = T)

data_per_uur_alleen_open %>%
  mutate(datum_jaar = as.numeric(datum_jaar)) %>%
  group_by(datum_maand, datum_jaar) %>%
  summarise(y = mean(bellers_totaal, na.rm = T)) %>%
  ungroup() %>%
  group_by(datum_maand) %>%
  select(datum_jaar = datum_jaar, y = y, datum_maand = datum_maand) %>%
  visualize$graph(interactive = T, types = list(bar = TRUE), options = list(x_variable = "datum_jaar"))

#feestdagen vs weekend
#vergelijkbaar patroon
data_per_uur_alleen_open %>%
  select(bellers_totaal, datum_weekdag, is_feestdag, datum_uur) %>%
  filter(datum_weekdag %in% c("zaterdag", "zondag") | is_feestdag) %>%
  mutate(soort_dag = ifelse(datum_weekdag %in% c("Saturday", "Sunday"), datum_weekdag, "feestdag")) %>%
  group_by(soort_dag, datum_uur) %>%
  summarise(y = mean(bellers_totaal, na.rm = T)) %>%
  select(x = datum_uur, y = y, group = soort_dag) %>%
  visualize$graph(interactive = T, labels = list(x = "uur van de dag", y = "gemiddelde aantal calls"), types = list(line = TRUE))

#mean for each month
data_per_uur %>%
  mutate(x = format(datumtijd, format = "%Y-%m")) %>%
  group_by(x) %>%
  summarise(y = mean(bellers_totaal)) %>%
  arrange(x) %>%
  visualize$graph(interactive = T, options = list(y_lim = c(0, 25)))

#mean for each year
data_per_uur %>%
  group_by(datum_jaar) %>%
  summarise(y = mean(bellers_totaal)) %>%
  arrange(datum_jaar) %>%
  select(x = datum_jaar, y) %>%
  visualize$graph(interactive = T)


#hour 16
# dataset %>%
#   mutate(datetime = aannametijd) %>%
#   select(datetime) %>% 
#   filter(hour(datetime) == 16) %>%
#   mutate(minutes = minute(datetime)) %>%
#   group_by(minutes) %>%
#   summarize(y = n()) %>%
#   rename(x = minutes) %>%
#   visualize$graph(interactive = T)

#calls are accepted when post is supposed to be closed?
# hourly_data %>%
#   filter(!weekdays(datetime) %in% c("zaterdag", "zondag") & hour(datetime) > 8 & hour(datetime) < 16) %>%
#   filter(!format(datetime, format = "%d-%m-%Y") %in% holiday_dates) 

# hourly_data[hour(hourly_data$datetime) == 16, ] %>% 
#   rename(y = value, x = datetime) %>%
#   mutate(x = format(x,format = "%d-%m-%Y %H:%M:%S")) %>%
#   visualize$graph(interactive = T)


#16:00 - 17:00 on weekends, because not open on mo-vr
# hourly_data[hour(hourly_data$datetime) == 16, ] %>%
#   group_by(value) %>%
#   summarise(y = n()) %>%
#   rename(x = value) %>%
#   visualize$graph(interactive = T, types = list(bar = T), labels = list(x = "aantal calls in 1 uur", y = "aantal voorkomens", title = "calls tussen 16:00-17:00"))


#16:00 - 17:00 on weekends has very high number of occasions with 1 call per hour


#per hour, get the number of times 1 call was made in that hour
# hourly_data %>%
#   mutate(datetime = hour(datetime)) %>%
#   filter(value == 1) %>%
#   group_by(datetime) %>%
#   summarise(y = n()) %>%
#   rename(x = datetime) %>%
#   visualize$graph(interactive = T, types = list(bar = T))


# hourly_data %>%
#   # filter(value == 1) %>%
#   filter(hour(datetime) == 16) %>%
#   mutate(day_of_week = weekdays(datetime)) %>%
#   group_by(day_of_week) %>%
#   summarise(n = n())
