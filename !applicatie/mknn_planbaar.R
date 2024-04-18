source("Library/init.R")
connections <- import("Library/database/database.R")
connections <- connections$get_connections(c("mknn"))

data <- import("Library/modules/ambulance_logistics_edaz/calculate_db.R")$create(
  connections$mknn,
  table_name ="dispatch_task_gms")

data$count(
  date_filter = c(as.Date("2022-09-01"), as.Date("2022-10-31")),
  time = "daily",
  time_column = "receive_task",
  filters =     list(
    urgency_dispatcher = "B2",
    provider_name = 
      c("Groningen", 
        "Friesland", 
        "Drenthe",
        "MAI"),
    vehicle_type = 
      c("Zorgambulance",
        "Middencomplex",
        "Ambulance",
        "MAI")),
  groups = "vehicle_type",
  exclude_excluded = T)


b <- connections$customer$get("SELECT count(*) as y, receive_task_date as x, vehicle_type FROM dispatch_task_gms WHERE receive_task_datetime BETWEEN '2022-10-01' AND '2022-10-31 23:59:59' GROUP BY receive_task_date, vehicle_type")

a <- connections$customer$get("SELECT count(*) as y, receive_task_date as x, vehicle_type FROM dispatch_task_gms WHERE ( ( ( urgency_dispatcher IN ('B2') and provider_name IN ('Groningen' , 'Friesland' , 'Drenthe' , 'MAI') ) and vehicle_type IN ('Zorgambulance' , 'Middencomplex' , 'Ambulance' , 'MAI') ) and exclude IN (FALSE) ) AND receive_task_datetime BETWEEN '2022-10-01' AND '2022-10-01 23:59:59' GROUP BY receive_task_date, vehicle_type")

d <- connections$customer$get("SELECT count(*) as y, receive_task_date as x, vehicle_type FROM dispatch_task_gms WHERE ( ( ( urgency_dispatcher IN ('B2') and provider_name IN ('Groningen' , 'Friesland' , 'Drenthe' , 'MAI') ) and vehicle_type IN ('Zorgambulance' , 'Middencomplex' , 'Ambulance' , 'MAI') ) and exclude IN (FALSE) ) AND receive_task_datetime > '2022-10-03 23:59:59' GROUP BY receive_task_date, vehicle_type")


#mais after start okt 2022
c <- connections$customer$get("SELECT count(*) as y, receive_task_date as x FROM dispatch_task_gms WHERE ( ( ( urgency_dispatcher IN ('B2') and provider_name IN ('Groningen' , 'Friesland' , 'Drenthe' , 'MAI') ) and vehicle_type IN ('MAI') ) and exclude IN (FALSE) ) AND receive_task_datetime > '2022-10-01' GROUP BY receive_task_date")


unique_vehicle_types <- connections$customer$get("SELECT DISTINCT(vehicle_type) FROM dispatch_task_gms WHERE receive_task_datetime > '2022-10-03 23:59:59'")

