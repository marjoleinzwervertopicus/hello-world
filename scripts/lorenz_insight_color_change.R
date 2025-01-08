source("Library/init.R") 
database <- import("Library/database/database.R")
connections <- database$get_connections("jb_lorenz")

lorenz_old_main_color <- "#009640"
graph_old_dark_green <- "#007432"
graph_old_green <- "#019d4a"
graph_old_light_green <- "#02c663"
old_progress_colors <- c("#02c663", "#00A754", "#007432")


#dashboards kleurvertaling
"#005223" -> "#0F2E17"
"#007432"-> "#184924"
"#00A754" -> "#427549"
"#02C663" -> "#69A172"
"#8DE7A6" -> "#CDE0D0"





#new color
connections$customer$set("UPDATE insight SET color = '#427549'")

#old color
connections$customer$set("UPDATE insight SET color = '#009640'")


