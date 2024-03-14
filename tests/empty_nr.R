source("Library/init.R")
database <- import("Library/database/database.R")

connections <- database$get_connections("etl.mk_limburg")

nr_counts <- connections$etl.mk_limburg$get(
  "SELECT COUNT(*), PERSNR_UITGIFTECENTRALIST, NAAM_UITGIFTECENTRALIST
   FROM v_a_arc_rit GROUP BY PERSNR_UITGIFTECENTRALIST, NAAM_UITGIFTECENTRALIST"

)  
