map <- d3(list(
  zoom = list(
    enabled = TRUE, 
    buttons = TRUE,
    extent = list(1, 10)),
  layerEnablerTitle = "Details overzichtskaart")) %>% 
  d3_setLabelStyle(list(textSize = '8pt',
                        padding = "3px",
                        backgroundEnabled = TRUE,
                        borderColor = '#000000')) %>%
  d3_setTooltipStyle(list(textSize = "9pt",
                          padding = "10px",
                          backgroundEnabled = TRUE,
                          borderColor = '#000000',
                          borderRadius = '5px'))


map <- map %>%
  d3_tiles(list(url='https://api.maptiler.com/maps/fa82a3f1-cb87-403f-9b33-76051d42702f/256/{level}/{col}/{row}.png?key=nyTHIDBi17rAY2e6YESm',
                initZoomLvl = 8,
                name = "Kaartdetails"))


map <- map %>%
  d3_preload_polygons(location = regions_file)
