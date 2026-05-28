
#!/bin/bash

# DIR="/home/devise/insights/production"
# DIR="/home/marjolein@devise.nl/RStudio/hello-world/scripts/html/"
DIR="/home/devise/insights/test/rav_ijsselland"

files=$(grep -R --include="*.html" -l -E "library\(tidyverse\)" "$DIR")

echo "Files to be edited:"
echo "$files"


echo "$files" | while read -r file; do
    sed -i \
      -e "s/library(tidyverse)/library(tidyr)\nlibrary(dplyr)\nlibrary(purrr)\nlibrary(tibble)/g" \
       "$file"
done
 
echo "Done"
