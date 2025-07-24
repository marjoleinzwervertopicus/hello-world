Sys.setenv("RSTUDIO_PANDOC" = "/opt/quarto/bin/tools/x86_64/pandoc")

# Sys.setenv("RSTUDIO_PANDOC" = "/usr/lib/rstudio-server/bin/quarto/bin/tools/x86_64/pandoc")
file.exists("/usr/lib/rstudio-server/bin/quarto/bin/tools/x86_64/pandoc")

file.exists("/usr/bin/pandoc")
Sys.getenv("RSTUDIO_PANDOC")
rmarkdown::pandoc_exec()
rmarkdown::find_pandoc()
rmarkdown::pandoc_version()
library(rmarkdown)
rmarkdown::pandoc_available(version = "2.19.2")
rmarkdown::pandoc_available(version = "3.1.11")
rmarkdown::pandoc_available(version = "2.2.1")

#/usr/bin/pandoc for container
#/usr/lib/rstudio-server/bin/quarto/bin/tools/x86_64/pandoc for maio rstudio

pandoc::pandoc_rstudio_version()



system("pandoc -v")

#echo $RSTUDIO_PANDOC
