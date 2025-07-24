source("Library/init.R")
library(glue)

get_stamenmap_tile <- function (z, x, y) 
{
  url_static = "https://api.maptiler.com/maps/63a90e7b-12b3-437e-b2d9-4a06d71110bf/256/{z}/{x}/{y}@2x.png?key=zWrMgYjvEMqg7SDr5zEY"
  url <- glue(url_static)
  response <- httr::GET(url)
  
  if(response$status_code != 200) browser()
  tile <- httr::content(response)
  
  tile <- aperm(tile, c(2, 1, 3))
  tile <- apply(tile, 2, rgb)
  
  lonlat_upperleft <- XY2LonLat(x, y, z)
  lonlat_lowerright <- XY2LonLat(x, y, z, 255L, 255L)
  bbox <- c(left = lonlat_upperleft$lon, bottom = lonlat_lowerright$lat, 
            right = lonlat_lowerright$lon, top = lonlat_upperleft$lat)
  bb <- tibble(ll.lat = unname(bbox["bottom"]), ll.lon = unname(bbox["left"]), 
               ur.lat = unname(bbox["top"]), ur.lon = unname(bbox["right"]))
  class(tile) <- c("raster")
  attr(tile, "bb") <- bb
  tile
}

XY2LonLat <- function(X, Y, zoom, x = 0, y = 0, xpix = 255, ypix = 255) {
  n <- 2^zoom
  lon_deg <- (X + x/xpix)/n * 360 - 180
  
  tmp <- tanh(pi * (1 - 2 * (Y + y/ypix)/n))
  ShiftLat <- function(tmp) {
    lat <- 2 * pi * (-1:1) + asin(tmp)
    lat[which(-pi/2 < lat & lat <= pi/2)] * 180/pi
  }
  lat_deg <- ShiftLat(tmp)
  data.frame(lon = lon_deg, lat = lat_deg)
}


input <- readRDS("~/RStudio/hello-world/scripts/input.RDS")

count <- 1
output <- lapply(input, 
       function(v) {
         warning(count)
         count <<- count + 1
         v <- as.numeric(v)
         get_stamenmap_tile(11, v[1], v[2])
       })