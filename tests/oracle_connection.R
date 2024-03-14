
source("Library/init.R")
library(RJDBC)

#mk_limburg
drv <- JDBC("oracle.jdbc.OracleDriver", classPath="/usr/lib/jvm/java-8-openjdk-amd64/jre/lib/ojdbc8.jar")
remote_connection <- dbConnect(drv, "jdbc:oracle:thin:@//10.130.11.235:1521/lbdw1", "gmsa273lb", secrets$get("oracle", "gmsa273lb"))


#mknn
drv <- JDBC("oracle.jdbc.OracleDriver", classPath="/usr/lib/jvm/java-8-openjdk-amd64/jre/lib/ojdbc8.jar")
mknn_con <- dbConnect(drv, "jdbc:oracle:thin:@//10.130.11.235:1521/nndw1", "gmsa284nn", secrets$get("oracle", "gmsa284nn"))