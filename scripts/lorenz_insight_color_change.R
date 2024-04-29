source("Library/init.R") 
database <- import("Library/database/database.R")
connections <- database$get_connections("jb_lorenz")

lorenz_old_main_color <- "#009640"
graph_old_dark_green <- "#007432"
graph_old_green <- "#019d4a"
graph_old_light_green <- "#02c663"
old_progress_colors <- c("#02c663", "#00A754", "#007432")


#dashboard  kleur vertaling
"#005223" -> "#132b19"
"#007432"-> "#1D4427"
"#00A754" -> "#516954"
"#02C663" -> "#7c8e7f"
"#8DE7A6" -> "#d3d9d4"

#dashboard wonen kleurvertaling 2
"#005223" -> "#183A21"
"#007432"-> "#245631"
"#00A754" -> "#3F6C4B"
"#02C663" -> "#649571"
"#8DE7A6" -> "#89BE97"

#dashboard wonen kleurvertaling 3
"#005223" -> "#122B19"
"#007432"-> "#245631"
"#00A754" -> "#4B815A"
"#02C663" -> "#78A584"
"#8DE7A6" -> "#A3CCAE"




"#275c34"
lorenz_groen1 <- "#1D4427"
lorenz_groen2 <- "#516954"
lorenz_groen2 <- "#7c8e7f"
lorenz_groen3 <- "#d3d9d4"

"#45644D"
"#1D4427"

lorenz_site_achtergrond_licht <- "#faf9f5"
lorenz_achetrgron_donker <- "#F2F1ED"


connections$customer$set("UPDATE insight SET color = '#4A7455'")

"#009640"
